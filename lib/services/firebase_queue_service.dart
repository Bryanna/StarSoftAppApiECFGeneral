import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facturacion/models/erp_invoice_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/invoice_queue_item.dart';
import '../models/erp_invoice.dart';

class FirebaseQueueService {
  static final FirebaseQueueService _instance =
      FirebaseQueueService._internal();
  factory FirebaseQueueService() => _instance;
  FirebaseQueueService._internal();

  static FirebaseQueueService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream de la cola actual del usuario
  Stream<List<InvoiceQueueItem>> get queueStream {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint('[FirebaseQueueService] Usuario no autenticado');
        return Stream.value([]);
      }

      debugPrint(
        '[FirebaseQueueService] Obteniendo cola para usuario: $userId',
      );

      return _firestore
          .collection('invoice_queue')
          .where('user_id', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            debugPrint(
              '[FirebaseQueueService] Documentos recibidos: ${snapshot.docs.length}',
            );
            final items = snapshot.docs
                .map((doc) {
                  try {
                    return InvoiceQueueItem.fromFirestore(doc.data(), doc.id);
                  } catch (e) {
                    debugPrint(
                      '[FirebaseQueueService] Error parseando documento ${doc.id}: $e',
                    );
                    return null;
                  }
                })
                .where((item) => item != null)
                .cast<InvoiceQueueItem>()
                .toList();

            // Ordenar localmente por fecha de creación (más reciente primero)
            items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return items;
          })
          .handleError((error) {
            debugPrint('[FirebaseQueueService] Error en stream: $error');
            return <InvoiceQueueItem>[];
          });
    } catch (e) {
      debugPrint('[FirebaseQueueService] Error creando stream: $e');
      return Stream.value([]);
    }
  }

  // Agregar facturas a la cola (lote)
  Future<void> addInvoicesToQueue(List<ERPInvoice> invoices) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');

    debugPrint(
      '[FirebaseQueueService] Agregando ${invoices.length} facturas a la cola',
    );

    // Obtener la posición actual más alta
    final lastPosition = await _getLastPosition(userId);

    final batch = _firestore.batch();

    for (int i = 0; i < invoices.length; i++) {
      final invoice = invoices[i];
      final queueItem = InvoiceQueueItem(
        id: '', // Se asignará automáticamente
        invoiceId: invoice.encf ?? '',
        encf: invoice.encf ?? '',
        numeroFactura: invoice.numeroFactura ?? '',
        invoiceData: _convertInvoiceToMap(invoice),
        status: QueueStatus.pending,
        createdAt: DateTime.now(),
        position: lastPosition + i + 1,
      );

      final docRef = _firestore.collection('invoice_queue').doc();
      batch.set(docRef, {...queueItem.toFirestore(), 'user_id': userId});
    }

    await batch.commit();
    debugPrint(
      '[FirebaseQueueService] ${invoices.length} facturas agregadas a la cola',
    );

    // Iniciar procesamiento automático
    _startQueueProcessor();
  }

  // Obtener la última posición en la cola
  Future<int> _getLastPosition(String userId) async {
    final query = await _firestore
        .collection('invoice_queue')
        .where('user_id', isEqualTo: userId)
        .orderBy('position', descending: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return 0;
    return query.docs.first.data()['position'] ?? 0;
  }

  // Convertir ERPInvoice a Map para almacenar
  Map<String, dynamic> _convertInvoiceToMap(ERPInvoice invoice) {
    return {
      'encf': invoice.encf,
      'numeroFactura': invoice.numeroFactura,
      'fechaemision': invoice.fechaemision,
      'montototal': invoice.montototal,
      'rncemisor': invoice.rncemisor,
      'razonsocialemisor': invoice.razonsocialemisor,
      'rnccomprador': invoice.rnccomprador,
      'razonsocialcomprador': invoice.razonsocialcomprador,
      // Agregar todos los campos necesarios para el scenario
      'version': invoice.version,
      'tipoingresos': invoice.tipoingresos,
      'tipopago': invoice.tipopago,
      'formapago1': invoice.formapago1,
      'montopago1': invoice.montopago1,
      'detalles': invoice.detalles
          .map(
            (d) => {
              'referencia': d.referencia,
              'descripcion': d.descripcion,
              'cantidad': d.cantidad,
              'precio': d.precio,
              'total': d.total,
            },
          )
          .toList(),
    };
  }

  // Procesador de cola (ejecuta automáticamente)
  bool _isProcessing = false;

  void _startQueueProcessor() {
    if (_isProcessing) return;
    _processQueue();
  }

  Future<void> _processQueue() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || _isProcessing) return;

    _isProcessing = true;
    debugPrint('[FirebaseQueueService] Iniciando procesamiento de cola');

    try {
      while (true) {
        // Obtener el siguiente item pendiente
        final nextItem = await _getNextPendingItem(userId);
        if (nextItem == null) {
          debugPrint('[FirebaseQueueService] No hay más items pendientes');
          break;
        }

        debugPrint('[FirebaseQueueService] Procesando: ${nextItem.encf}');

        // Marcar como procesando
        await _updateQueueItem(nextItem.id, {
          'status': QueueStatus.processing.name,
          'processed_at': Timestamp.now(),
        });

        try {
          // Enviar a DGII
          final response = await _sendInvoiceToDGII(nextItem);

          // Actualizar con resultado
          await _updateQueueItem(nextItem.id, {
            'status': _getStatusFromResponse(response).name,
            'dgii_response': response,
            'error_message': null,
          });

          debugPrint(
            '[FirebaseQueueService] ✅ ${nextItem.encf} procesado exitosamente',
          );
        } catch (e) {
          debugPrint(
            '[FirebaseQueueService] ❌ Error procesando ${nextItem.encf}: $e',
          );

          // Manejar reintentos
          final newRetryCount = nextItem.retryCount + 1;
          if (newRetryCount < 3) {
            await _updateQueueItem(nextItem.id, {
              'status': QueueStatus.retrying.name,
              'retry_count': newRetryCount,
              'error_message': e.toString(),
            });

            // Esperar antes del siguiente intento
            await Future.delayed(Duration(seconds: newRetryCount * 5));
          } else {
            await _updateQueueItem(nextItem.id, {
              'status': QueueStatus.failed.name,
              'error_message': 'Máximo de reintentos alcanzado: $e',
            });
          }
        }

        // Pequeña pausa entre envíos
        await Future.delayed(Duration(seconds: 2));
      }
    } finally {
      _isProcessing = false;
      debugPrint('[FirebaseQueueService] Procesamiento de cola finalizado');
    }
  }

  // Obtener siguiente item pendiente
  Future<InvoiceQueueItem?> _getNextPendingItem(String userId) async {
    final query = await _firestore
        .collection('invoice_queue')
        .where('user_id', isEqualTo: userId)
        .where(
          'status',
          whereIn: [QueueStatus.pending.name, QueueStatus.retrying.name],
        )
        .orderBy('position')
        .orderBy('created_at')
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    return InvoiceQueueItem.fromFirestore(doc.data(), doc.id);
  }

  // Actualizar item en la cola
  Future<void> _updateQueueItem(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    await _firestore.collection('invoice_queue').doc(itemId).update(updates);
  }

  // Enviar factura a DGII (usando la lógica existente)
  Future<Map<String, dynamic>> _sendInvoiceToDGII(
    InvoiceQueueItem queueItem,
  ) async {
    // Recrear ERPInvoice desde los datos almacenados
    final invoiceData = queueItem.invoiceData;

    // Crear scenario usando la lógica existente del HomeController
    final scenario = await _createScenarioFromData(invoiceData);

    final requestBody = {
      'scenarios': [scenario],
    };

    debugPrint('[FirebaseQueueService] Enviando a DGII: ${queueItem.encf}');

    final response = await http.post(
      Uri.parse('https://ecf-fe.dgii.gov.do/testecf/rest/test-scenarios-json'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      debugPrint(
        '[FirebaseQueueService] ✅ Respuesta DGII: ${response.statusCode}',
      );
      return responseData;
    } else {
      debugPrint(
        '[FirebaseQueueService] ❌ Error DGII: ${response.statusCode} - ${response.body}',
      );
      throw Exception('Error DGII: ${response.statusCode} - ${response.body}');
    }
  }

  // Crear scenario desde datos almacenados (simplificado)
  Future<Map<String, dynamic>> _createScenarioFromData(
    Map<String, dynamic> data,
  ) async {
    final scenario = <String, dynamic>{};

    // Usar los mismos valores de prueba que tienes configurados
    scenario['Version'] = data['version'] ?? '1.0';
    scenario['TipoeCF'] = '32'; // TEMPORAL: coincide con E320000000213
    scenario['eNCF'] = 'E320000000213'; // NÚMERO DE PRUEBA TEMPORAL
    scenario['TipoIngresos'] = data['tipoingresos'] ?? '01';
    scenario['TipoPago'] = data['tipopago'] ?? '1';

    if (data['formapago1'] != null) {
      scenario['FormaPago[1]'] = data['formapago1'];
    }
    if (data['montopago1'] != null) {
      scenario['MontoPago[1]'] = data['montopago1'];
    }

    // Emisor
    if (data['rncemisor'] != null) scenario['RNCEmisor'] = data['rncemisor'];
    if (data['razonsocialemisor'] != null) {
      scenario['RazonSocialEmisor'] = data['razonsocialemisor'];
    }
    if (data['fechaemision'] != null) {
      final fechaEmision = data['fechaemision'].toString();
      // Convertir formato de fecha de MM/dd/yyyy o dd/MM/yyyy a dd-MM-yyyy
      final formattedDate = fechaEmision.replaceAll('/', '-');
      scenario['FechaEmision'] = formattedDate;
    }

    // Comprador
    if (data['rnccomprador'] != null) {
      scenario['RNCComprador'] = data['rnccomprador'];
    }
    if (data['razonsocialcomprador'] != null) {
      scenario['RazonSocialComprador'] = data['razonsocialcomprador'];
    }

    // Totales
    scenario['MontoTotal'] = data['montototal'] ?? '0.00';

    // CasoPrueba
    final rncEmisor = data['rncemisor'] ?? '';
    final encf = 'E320000000213';
    if (rncEmisor.isNotEmpty) {
      scenario['CasoPrueba'] = '$rncEmisor$encf';
    }

    // Items (simplificado)
    final detalles = data['detalles'] as List<dynamic>? ?? [];
    for (int i = 0; i < detalles.length; i++) {
      final detalle = detalles[i];
      final index = i + 1;

      scenario['NumeroLinea[$index]'] =
          detalle['referencia'] ?? index.toString();
      scenario['IndicadorFacturacion[$index]'] = '4';
      scenario['NombreItem[$index]'] = detalle['descripcion'] ?? '';
      scenario['IndicadorBienoServicio[$index]'] = '2';
      scenario['CantidadItem[$index]'] =
          detalle['cantidad']?.toString() ?? '1.00';
      scenario['PrecioUnitarioItem[$index]'] =
          detalle['precio']?.toString() ?? '0.00';
      scenario['MontoItem[$index]'] = detalle['total']?.toString() ?? '0.00';
    }

    return scenario;
  }

  // Determinar status desde respuesta DGII
  QueueStatus _getStatusFromResponse(Map<String, dynamic> response) {
    // Analizar la respuesta de DGII para determinar el status
    // Esto dependerá del formato exacto de respuesta de la DGII

    try {
      // Ejemplo de lógica (ajustar según respuesta real)
      final status = response['status']?.toString().toLowerCase();
      final errors = response['errors'] as List?;

      if (errors != null && errors.isNotEmpty) {
        return QueueStatus.rejected;
      }

      if (status == 'approved' || status == 'success') {
        return QueueStatus.approved;
      }

      if (status == 'rejected' || status == 'error') {
        return QueueStatus.rejected;
      }

      return QueueStatus.completed;
    } catch (e) {
      debugPrint('[FirebaseQueueService] Error interpretando respuesta: $e');
      return QueueStatus.completed;
    }
  }

  // Limpiar cola (items completados/fallidos)
  Future<void> clearCompletedItems() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final query = await _firestore
        .collection('invoice_queue')
        .where('user_id', isEqualTo: userId)
        .where(
          'status',
          whereIn: [
            QueueStatus.completed.name,
            QueueStatus.approved.name,
            QueueStatus.failed.name,
          ],
        )
        .get();

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    debugPrint(
      '[FirebaseQueueService] Items completados eliminados de la cola',
    );
  }

  // Cancelar item específico
  Future<void> cancelQueueItem(String itemId) async {
    await _firestore.collection('invoice_queue').doc(itemId).delete();
  }

  // Reintentar item fallido
  Future<void> retryFailedItem(String itemId) async {
    await _updateQueueItem(itemId, {
      'status': QueueStatus.pending.name,
      'retry_count': 0,
      'error_message': null,
    });

    _startQueueProcessor();
  }
}
