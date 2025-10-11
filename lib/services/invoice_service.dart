import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/invoice.dart';
import '../models/erp_invoice.dart';
import '../models/erp_invoice_extensions.dart';
import '../models/ui_types.dart';
import 'fake_data_service.dart';
import '../screens/configuracion/configuracion_controller.dart';
import 'firestore_service.dart';
import 'firebase_auth_service.dart';

class InvoiceService {
  final FirestoreService _db = FirestoreService();
  final FirebaseAuthService _auth = FirebaseAuthService();

  // Obtiene facturas reales desde el endpoint ERP configurado o datos fake
  Future<List<ERPInvoice>> fetchInvoices(InvoiceCategory category) async {
    try {
      // Verificar si debemos usar datos fake
      final useFakeData = await _shouldUseFakeData();

      if (useFakeData) {
        debugPrint('[InvoiceService] Using fake data (configured in settings)');
        return await _generateFakeInvoices(category);
      }

      // Intentar obtener datos reales del ERP
      debugPrint('[InvoiceService] Attempting to fetch real data from ERP');
      final erpUrl = await _getERPUrl();

      if (erpUrl == null || erpUrl.isEmpty || erpUrl == 'Sin configurar') {
        throw ERPNotConfiguredException('URL del ERP no configurado');
      }

      // Realizar llamada HTTP al ERP
      return await _fetchFromERP(erpUrl, category);
    } on ERPNotConfiguredException {
      rethrow;
    } on NoInvoicesFoundException {
      rethrow;
    } on ERPConnectionException {
      rethrow;
    } on TimeoutException catch (e) {
      debugPrint('[InvoiceService] Timeout: ${e.message ?? '20s'}');
      throw ERPConnectionException(
        'Timeout conectando al ERP (${e.message ?? '20s'})',
      );
    } catch (e, s) {
      debugPrint('[InvoiceService] Error al obtener facturas: $e');
      debugPrint('$s');
      throw ERPConnectionException('Error conectando al ERP: $e');
    }
  }

  // Verifica si debemos usar datos fake desde la configuración
  Future<bool> _shouldUseFakeData() async {
    try {
      // Primero intentar obtener del controller si está registrado
      if (Get.isRegistered<ConfiguracionController>()) {
        final controller = Get.find<ConfiguracionController>();
        return controller.useFakeData;
      }

      // Si no está registrado, obtener directamente de Firestore
      final uid = _auth.currentUser?.uid;
      if (uid == null) return true; // Default a fake si no hay usuario

      final userDoc = await _db.doc('users/$uid').get();
      final userData = userDoc.data();
      final companyRnc = userData?['companyRnc'] as String?;

      if (companyRnc == null) return true; // Default a fake si no hay empresa

      final companyDoc = await _db.doc('companies/$companyRnc').get();
      final companyData = companyDoc.data();

      return companyData?['useFakeData'] ?? true; // Default a fake
    } catch (e) {
      debugPrint('[InvoiceService] Error checking fake data config: $e');
      return true; // Default a fake en caso de error
    }
  }

  // Obtiene la URL del ERP desde la configuración
  Future<String?> _getERPUrl() async {
    try {
      // Primero intentar obtener del controller si está registrado
      if (Get.isRegistered<ConfiguracionController>()) {
        final controller = Get.find<ConfiguracionController>();
        return controller.urlERPEndpoint;
      }

      // Si no está registrado, obtener directamente de Firestore
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final userDoc = await _db.doc('users/$uid').get();
      final userData = userDoc.data();
      final companyRnc = userData?['companyRnc'] as String?;

      if (companyRnc == null) return null;

      final companyDoc = await _db.doc('companies/$companyRnc').get();
      final companyData = companyDoc.data();

      return companyData?['urlERPEndpoint'] as String?;
    } catch (e) {
      debugPrint('[InvoiceService] Error getting ERP URL: $e');
      return null;
    }
  }

  // Realiza la llamada HTTP al ERP
  Future<List<ERPInvoice>> _fetchFromERP(
    String erpUrl,
    InvoiceCategory category,
  ) async {
    debugPrint('[InvoiceService] Fetching from ERP: $erpUrl');

    try {
      final uri = Uri.parse(erpUrl);
      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 60));

      debugPrint('[InvoiceService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('[InvoiceService] Starting JSON decode...');
        final jsonData = json.decode(response.body);
        debugPrint('[InvoiceService] JSON decoded, starting parse...');
        final invoices = _parseERPResponse(jsonData);
        debugPrint(
          '[InvoiceService] Parse completed with ${invoices.length} invoices',
        );

        if (invoices.isEmpty) {
          throw NoInvoicesFoundException(
            'No hay facturas disponibles en el ERP',
          );
        }

        debugPrint(
          '[InvoiceService] Successfully fetched ${invoices.length} invoices from ERP',
        );
        return invoices;
      } else if (response.statusCode == 404) {
        throw NoInvoicesFoundException(
          'No se encontraron facturas en el ERP (404)',
        );
      } else {
        throw ERPConnectionException(
          'Error del servidor ERP: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } on TimeoutException {
      debugPrint('[InvoiceService] Timeout de 20 segundos excedido');
      throw ERPConnectionException('Timeout conectando al ERP (20s)');
    } on FormatException catch (e) {
      debugPrint('[InvoiceService] Error parsing JSON: $e');
      throw ERPConnectionException('Formato de respuesta inválido del ERP');
    } on http.ClientException catch (e) {
      debugPrint('[InvoiceService] HTTP ClientException: $e');
      throw ERPConnectionException(
        'Error de red o conexión con el ERP: ${e.message}',
      );
    } catch (e) {
      if (e is ERPConnectionException || e is NoInvoicesFoundException) {
        rethrow;
      }
      debugPrint('[InvoiceService] Unexpected HTTP Error: $e');
      throw ERPConnectionException(
        'Error inesperado de conexión con el ERP: $e',
      );
    }
  }

  // Parsea la respuesta del ERP al formato de ERPInvoice
  List<ERPInvoice> _parseERPResponse(dynamic jsonData) {
    try {
      debugPrint(
        '[InvoiceService] Parsing response type: ${jsonData.runtimeType}',
      );

      List<dynamic>? itemsList;

      // Caso 1: La respuesta es un objeto con un campo "data" que contiene el array
      if (jsonData is Map<String, dynamic>) {
        final keys = jsonData.keys.toList();
        debugPrint('[InvoiceService] Response is a Map, keys: $keys');

        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          itemsList = jsonData['data'];
          debugPrint(
            '[InvoiceService] Found "data" array with ${itemsList!.length} items',
          );
        }
        // Caso 2: La respuesta es un objeto con un campo "invoices"
        else if (jsonData.containsKey('invoices') &&
            jsonData['invoices'] is List) {
          itemsList = jsonData['invoices'];
          debugPrint(
            '[InvoiceService] Found "invoices" array with ${itemsList!.length} items',
          );
        }
        // Caso 3: La respuesta es un objeto con un campo "facturas"
        else if (jsonData.containsKey('facturas') &&
            jsonData['facturas'] is List) {
          itemsList = jsonData['facturas'];
          debugPrint(
            '[InvoiceService] Found "facturas" array with ${itemsList!.length} items',
          );
        }
      }
      // Caso 4: La respuesta es directamente un array
      else if (jsonData is List) {
        itemsList = jsonData;
        debugPrint(
          '[InvoiceService] Response is a direct array with ${itemsList.length} items',
        );
      }

      // Si no encontramos una lista, lanzar error
      if (itemsList == null) {
        debugPrint('[InvoiceService] No valid array found in response');
        throw FormatException(
          'No se encontró un array de facturas en la respuesta',
        );
      }

      // Parsear cada item con manejo de errores individual
      final List<ERPInvoice> invoices = [];
      int errorCount = 0;

      for (int i = 0; i < itemsList.length; i++) {
        try {
          final item = itemsList[i];
          if (item is! Map<String, dynamic>) {
            continue;
          }

          // Mostrar el primer item para debug
          if (i == 0) {
            debugPrint(
              '[InvoiceService] First item keys: ${item.keys.toList()}',
            );
            debugPrint(
              '[InvoiceService] First item sample: ${item.toString().substring(0, item.toString().length > 500 ? 500 : item.toString().length)}',
            );
          }

          // Usar el modelo ERPInvoice directamente
          final erpInvoice = ERPInvoice.fromJson(item);

          if (i == 0) {
            debugPrint(
              '[InvoiceService] Successfully parsed ERP invoice: ${erpInvoice.encf}',
            );

            // Debug crítico: verificar si el ERP envía detalle_factura
            debugPrint('');
            debugPrint('🔍 ERP RESPONSE DEBUG:');
            debugPrint('🔍 Raw item keys: ${item.keys.toList()}');
            debugPrint('🔍 Raw DetalleFactura: ${item['DetalleFactura']}');
            debugPrint('🔍 Raw detalleFactura: ${item['detalleFactura']}');
            debugPrint('🔍 Raw detalle_factura: ${item['detalle_factura']}');
            debugPrint('');

            debugPrint(
              '[InvoiceService] Parsed invoice detalleFactura: ${erpInvoice.detalleFactura?.substring(0, erpInvoice.detalleFactura!.length > 100 ? 100 : erpInvoice.detalleFactura!.length) ?? 'NULL'}...',
            );
            debugPrint(
              '[InvoiceService] Parsed invoice has ${erpInvoice.detalles.length} parsed details',
            );
          }

          // Agregar directamente sin conversión
          invoices.add(erpInvoice);
        } catch (e, stackTrace) {
          errorCount++;
          if (errorCount <= 3) {
            debugPrint('[InvoiceService] Error parsing item $i: $e');
            if (i < 3) {
              // Mostrar stack trace solo para los primeros 3 errores
              debugPrint(
                '[InvoiceService] Stack trace: ${stackTrace.toString().split('\n').take(5).join('\n')}',
              );
            }
          }
          continue;
        }
      }

      if (errorCount > 0) {
        debugPrint('[InvoiceService] Total items with errors: $errorCount');
      }

      if (invoices.isEmpty && itemsList.isNotEmpty) {
        throw FormatException('No se pudo parsear ninguna factura del ERP');
      }

      debugPrint(
        '[InvoiceService] Successfully parsed ${invoices.length} invoices',
      );
      return invoices;
    } catch (e, stackTrace) {
      debugPrint('[InvoiceService] Error parsing ERP response: $e');
      debugPrint('[InvoiceService] Stack trace: $stackTrace');
      throw FormatException('Error al parsear respuesta del ERP: $e');
    }
  }

  // Genera datos fake para testing
  Future<List<ERPInvoice>> _generateFakeInvoices(
    InvoiceCategory category,
  ) async {
    debugPrint(
      '[InvoiceService] Generando datos desde ejemplos.json para: $category',
    );

    try {
      // Para 'todos', cargamos el dataset completo sin filtrar
      if (category == InvoiceCategory.todos) {
        final all = await FakeDataService.generateFakeInvoicesFromJson();
        debugPrint(
          '[InvoiceService] Loaded ${all.length} invoices (todos) from ejemplos.json',
        );
        // Convertir Datum a ERPInvoice
        return all.map((datum) => _convertDatumToERPInvoice(datum)).toList();
      }

      final categoryKey = _mapCategory(category);
      final fakeInvoices = await FakeDataService.generateFakeInvoicesByCategory(
        categoryKey,
      );

      debugPrint(
        '[InvoiceService] Loaded ${fakeInvoices.length} invoices from ejemplos.json for $category',
      );
      // Convertir Datum a ERPInvoice
      return fakeInvoices
          .map((datum) => _convertDatumToERPInvoice(datum))
          .toList();
    } catch (e) {
      debugPrint('[InvoiceService] Error generating fake data from JSON: $e');
      return [];
    }
  }

  String _mapCategory(InvoiceCategory category) {
    switch (category) {
      case InvoiceCategory.todos:
        return 'todos';
      case InvoiceCategory.pacientes:
        return 'pacientes';
      case InvoiceCategory.ars:
        return 'ars';
      case InvoiceCategory.enviados:
        return 'enviados';
      case InvoiceCategory.notasCredito:
        return 'notascredito';
      case InvoiceCategory.notasDebito:
        return 'notasdebito';
      case InvoiceCategory.gastos:
        return 'gastos';
      case InvoiceCategory.rechazados:
        return 'rechazados';
    }
  }

  // Convierte Datum a ERPInvoice para compatibilidad con datos fake
  ERPInvoice _convertDatumToERPInvoice(Datum datum) {
    return ERPInvoice(
      fFacturaSecuencia: datum.fFacturaSecuencia,
      version: datum.version,
      tipoecf: datum.tipoecf,
      encf: datum.encf,
      fechavencimientosecuencia: datum.fechavencimientosecuencia?.name,
      fechaemision: datum.fechaemision?.name,
      rncemisor: datum.rncemisor,
      razonsocialemisor: datum.razonsocialemisor?.name,
      nombrecomercial: datum.nombrecomercial?.name,
      direccionemisor: datum.direccionemisor?.name,
      municipio: datum.municipio,
      provincia: datum.provincia,
      telefonoemisor1: datum.telefonoemisor1?.toString(),
      correoemisor: datum.correoemisor,
      website: datum.website?.toString(),
      rnccomprador: datum.rnccomprador,
      razonsocialcomprador: datum.razonsocialcomprador?.name,
      direccioncomprador: datum.direccioncomprador,
      montototal: datum.montototal,
      montogravadototal: datum.montogravadototal,
      totalitbis: datum.totalitbis,
      montoexento: datum.montoexento,
      tipomoneda: datum.tipomoneda,
      fechahorafirma: datum.fechahorafirma?.toString(),
      codigoseguridad: datum.codigoseguridad?.toString(),
      linkOriginal: datum.linkOriginal,
      tipoComprobante: datum.tipoComprobante,
    );
  }

  // (Legacy) Método removido: ahora las facturas fake provienen de ejemplos.json via FakeDataService.
}

// Excepciones personalizadas para manejo de errores específicos
class ERPNotConfiguredException implements Exception {
  final String message;
  ERPNotConfiguredException(this.message);

  @override
  String toString() => 'ERPNotConfiguredException: $message';
}

class NoInvoicesFoundException implements Exception {
  final String message;
  NoInvoicesFoundException(this.message);

  @override
  String toString() => 'NoInvoicesFoundException: $message';
}

class ERPConnectionException implements Exception {
  final String message;
  ERPConnectionException(this.message);

  @override
  String toString() => 'ERPConnectionException: $message';
}
