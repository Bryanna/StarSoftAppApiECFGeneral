import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class QueueProcessorService {
  static final QueueProcessorService _instance =
      QueueProcessorService._internal();
  factory QueueProcessorService() => _instance;
  QueueProcessorService._internal();

  static QueueProcessorService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isProcessing = false;
  bool _isCurrentlyProcessingItem = false; // Para evitar procesamiento paralelo
  StreamSubscription? _queueSubscription;

  // Iniciar el procesador automático
  void startProcessing() {
    if (_isProcessing) {
      debugPrint('[QueueProcessor] Ya está procesando');
      return;
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      debugPrint('[QueueProcessor] ❌ Usuario no autenticado');
      return;
    }

    debugPrint(
      '[QueueProcessor] 🚀 Iniciando procesador automático para usuario: $userId',
    );
    _isProcessing = true;

    // Escuchar cambios en la cola
    _queueSubscription = _firestore
        .collection('invoice_queue')
        .where('user_id', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen(
          (snapshot) {
            debugPrint(
              '[QueueProcessor] 📊 Snapshot recibido: ${snapshot.docs.length} items pendientes',
            );
            if (snapshot.docs.isNotEmpty) {
              debugPrint(
                '[QueueProcessor] 🔄 Procesando ${snapshot.docs.length} items pendientes',
              );
              _processNextItem();
            } else {
              debugPrint('[QueueProcessor] ✅ No hay items pendientes');
            }
          },
          onError: (error) {
            debugPrint('[QueueProcessor] ❌ Error en stream: $error');
          },
        );

    // También procesar items existentes inmediatamente
    _processExistingItems();
  }

  // Procesar items existentes al iniciar
  Future<void> _processExistingItems() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final query = await _firestore
          .collection('invoice_queue')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (query.docs.isNotEmpty) {
        debugPrint(
          '[QueueProcessor] 🔍 Encontrados ${query.docs.length} items pendientes existentes',
        );
        _processNextItem();
      } else {
        debugPrint('[QueueProcessor] 📭 No hay items pendientes existentes');
      }
    } catch (e) {
      debugPrint('[QueueProcessor] ❌ Error verificando items existentes: $e');
    }
  }

  // Detener el procesador
  void stopProcessing() {
    debugPrint('[QueueProcessor] Deteniendo procesador');
    _isProcessing = false;
    _queueSubscription?.cancel();
    _queueSubscription = null;
  }

  // Procesar el siguiente item en la cola (UNO POR UNO)
  Future<void> _processNextItem() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || !_isProcessing) {
      debugPrint(
        '[QueueProcessor] ⏹️ No se puede procesar: userId=$userId, isProcessing=$_isProcessing',
      );
      return;
    }

    // IMPORTANTE: Solo procesar un item a la vez
    if (_isCurrentlyProcessingItem) {
      debugPrint(
        '[QueueProcessor] ⏸️ Ya hay un item siendo procesado, esperando...',
      );
      return;
    }

    _isCurrentlyProcessingItem = true;

    try {
      // Obtener el siguiente item pendiente (sin orderBy para evitar índices)
      debugPrint('[QueueProcessor] 🔍 Buscando siguiente item pendiente...');
      final query = await _firestore
          .collection('invoice_queue')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        debugPrint('[QueueProcessor] No hay items pendientes');
        return;
      }

      final doc = query.docs.first;
      final data = doc.data();

      debugPrint(
        '[QueueProcessor] 🎯 Procesando factura: ${data['numero_factura']} (${data['encf']})',
      );

      // Marcar como procesando
      await doc.reference.update({
        'status': 'processing',
        'processed_at': FieldValue.serverTimestamp(),
      });

      try {
        // Enviar a DGII
        final result = await _sendToDGII(data);
        final response = result['response'] as Map<String, dynamic>;
        final requestData = result['request'] as Map<String, dynamic>;

        // Determinar el status final
        final finalStatus = _determineStatus(response);

        // Actualizar con resultado incluyendo el request enviado
        await doc.reference.update({
          'status': finalStatus,
          'dgii_response': response,
          'dgii_request_data': requestData, // Guardar el request real enviado
          'error_message': null,
        });

        debugPrint(
          '[QueueProcessor] ✅ ${data['encf']} procesado: $finalStatus',
        );
      } catch (e) {
        debugPrint('[QueueProcessor] ❌ Error procesando ${data['encf']}: $e');

        // Manejar reintentos
        final retryCount = (data['retry_count'] ?? 0) + 1;
        if (retryCount < 3) {
          await doc.reference.update({
            'status': 'pending', // Volver a pending para reintento
            'retry_count': retryCount,
            'error_message': e.toString(),
          });

          debugPrint(
            '[QueueProcessor] Reintentando ${data['encf']} (intento $retryCount)',
          );

          // Esperar antes del siguiente intento
          await Future.delayed(Duration(seconds: retryCount * 5));
        } else {
          await doc.reference.update({
            'status': 'failed',
            'error_message': 'Máximo de reintentos alcanzado: $e',
          });
        }
      }

      // Pequeña pausa entre envíos
      debugPrint(
        '[QueueProcessor] ⏱️ Pausa de 2 segundos antes del siguiente...',
      );
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('[QueueProcessor] 💥 Error general en _processNextItem: $e');
    } finally {
      // IMPORTANTE: Liberar el flag para permitir el siguiente procesamiento
      _isCurrentlyProcessingItem = false;
      debugPrint(
        '[QueueProcessor] 🔓 Item procesado, liberando para el siguiente',
      );

      // SOLO procesar el siguiente si hay más items pendientes
      if (_isProcessing) {
        debugPrint(
          '[QueueProcessor] 🔍 Verificando si hay más items pendientes...',
        );

        // Verificar si realmente hay más items pendientes
        final hasMorePending = await _hasMorePendingItems();
        if (hasMorePending) {
          debugPrint(
            '[QueueProcessor] 🔄 Hay más items, procesando siguiente...',
          );
          // Pequeña pausa adicional antes de buscar el siguiente
          await Future.delayed(const Duration(milliseconds: 500));
          _processNextItem();
        } else {
          debugPrint(
            '[QueueProcessor] ✅ No hay más items pendientes, procesamiento completado',
          );
        }
      }
    }
  }

  // Enviar a DGII usando el endpoint de Firebase
  Future<Map<String, dynamic>> _sendToDGII(
    Map<String, dynamic> queueData,
  ) async {
    final invoiceData =
        queueData['invoice_data'] as Map<String, dynamic>? ?? {};

    // Obtener el endpoint desde Firebase
    final endpoint = await _getEndpointFromFirebase();
    if (endpoint == null) {
      throw Exception('No se pudo obtener el endpoint de Firebase');
    }

    // Crear scenario usando los datos de la factura
    final scenario = await _createScenario(invoiceData);

    final requestBody = {
      'scenarios': [scenario],
    };

    // === LOGS DETALLADOS DEL REQUEST ===
    debugPrint('[QueueProcessor] =====================================');
    debugPrint('[QueueProcessor] 📤 ENVIANDO A DGII: ${queueData['encf']}');
    debugPrint('[QueueProcessor] 🌐 Endpoint: $endpoint');
    debugPrint('[QueueProcessor] =====================================');

    // Log del scenario individual (más legible)
    debugPrint('[QueueProcessor] 📋 SCENARIO INDIVIDUAL:');
    final scenarioJson = JsonEncoder.withIndent('  ').convert(scenario);
    debugPrint(scenarioJson);

    debugPrint('[QueueProcessor] =====================================');

    // Log del request body completo
    debugPrint('[QueueProcessor] 📦 REQUEST BODY COMPLETO:');
    final requestJson = JsonEncoder.withIndent('  ').convert(requestBody);
    debugPrint(requestJson);

    debugPrint('[QueueProcessor] =====================================');

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    // === LOGS DETALLADOS DE LA RESPUESTA ===
    debugPrint('[QueueProcessor] =====================================');
    debugPrint('[QueueProcessor] 📥 RESPUESTA DE LA DGII:');
    debugPrint('[QueueProcessor] 🔢 Status Code: ${response.statusCode}');
    debugPrint('[QueueProcessor] 📄 Headers: ${response.headers}');
    debugPrint('[QueueProcessor] =====================================');

    if (response.statusCode == 200) {
      debugPrint('[QueueProcessor] ✅ Respuesta exitosa (200)');

      try {
        final responseData = jsonDecode(response.body);
        debugPrint('[QueueProcessor] 📋 RESPONSE BODY (JSON):');
        final responseJson = JsonEncoder.withIndent('  ').convert(responseData);
        debugPrint(responseJson);
        debugPrint('[QueueProcessor] =====================================');

        // Retornar tanto el request como la respuesta
        return {
          'response': responseData,
          'request': {
            'endpoint': endpoint,
            'method': 'POST',
            'headers': {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            'scenarios': [scenario],
          },
        };
      } catch (e) {
        debugPrint('[QueueProcessor] ❌ Error parseando JSON response: $e');
        debugPrint('[QueueProcessor] 📄 Raw Response Body:');
        debugPrint(response.body);
        debugPrint('[QueueProcessor] =====================================');
        throw Exception('Error parseando respuesta JSON: $e');
      }
    } else {
      debugPrint('[QueueProcessor] ❌ Error HTTP: ${response.statusCode}');
      debugPrint('[QueueProcessor] 📄 Error Response Body:');
      debugPrint(response.body);
      debugPrint('[QueueProcessor] =====================================');

      // Intentar parsear el error como JSON para mejor análisis
      try {
        final errorData = jsonDecode(response.body);
        final errorJson = JsonEncoder.withIndent('  ').convert(errorData);
        debugPrint('[QueueProcessor] 📋 ERROR BODY (JSON):');
        debugPrint(errorJson);
        debugPrint('[QueueProcessor] =====================================');

        // Retornar el error parseado para análisis
        return {
          'response': {
            'status': response.statusCode,
            'data': errorData,
            'message': 'Request failed with status code ${response.statusCode}',
          },
          'request': {
            'endpoint': endpoint,
            'method': 'POST',
            'headers': {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            'scenarios': [scenario],
          },
        };
      } catch (e) {
        debugPrint('[QueueProcessor] ❌ Error body no es JSON válido');
        throw Exception(
          'Error DGII: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }

  // Crear scenario para DGII (usando eNCF de prueba)
  Future<Map<String, dynamic>> _createScenario(
    Map<String, dynamic> invoiceData,
  ) async {
    final scenario = <String, dynamic>{};

    // === ORDEN CORRECTO SEGÚN XSD ===

    // 1. Version (required)
    scenario['Version'] = invoiceData['version'] ?? '1.0';

    // 2. TipoeCF (required) - Extraer del NCF del ERP
    final tipoeCF = _extractTipoeCF(invoiceData);
    scenario['TipoeCF'] = tipoeCF;

    // 3. ENCF (required) - Generar único basado en NCF del ERP
    final encf = _generateUniqueENCF(invoiceData);
    scenario['ENCF'] = encf;

    // === Obtener datos del emisor desde Firebase ===
    Map<String, dynamic> companyData = {};
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final companyRnc = userData['companyRnc'] as String?;

          if (companyRnc != null && companyRnc.isNotEmpty) {
            final companyDoc = await _firestore
                .collection('companies')
                .doc(companyRnc)
                .get();

            if (companyDoc.exists) {
              companyData = companyDoc.data()!;
              debugPrint(
                '[QueueProcessor] Datos de empresa obtenidos desde Firebase',
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[QueueProcessor] Error obteniendo datos de empresa: $e');
    }

    // === 4. DATOS DEL EMISOR (PRIORIDAD A FIREBASE) ===

    // RNCEmisor (required)
    final rncEmisorFirebase = companyData['rnc'] as String?;
    final rncEmisor = rncEmisorFirebase ?? invoiceData['rncemisor'] ?? '';
    if (rncEmisor.isNotEmpty) {
      scenario['RNCEmisor'] = rncEmisor;
      debugPrint(
        '[QueueProcessor] 🏢 RNCEmisor: $rncEmisor (Firebase: ${rncEmisorFirebase != null})',
      );
    }

    // RazonSocialEmisor (required)
    final razonSocialFirebase = companyData['razonSocial'] as String?;
    final razonSocialEmisor =
        razonSocialFirebase ?? invoiceData['razonsocialemisor'] ?? '';
    if (razonSocialEmisor.isNotEmpty) {
      scenario['RazonSocialEmisor'] = razonSocialEmisor;
      debugPrint(
        '[QueueProcessor] 🏢 RazonSocialEmisor: $razonSocialEmisor (Firebase: ${razonSocialFirebase != null})',
      );
    }

    // DireccionEmisor
    final direccionFirebase = companyData['direccion'] as String?;
    if (direccionFirebase != null && direccionFirebase.isNotEmpty) {
      scenario['DireccionEmisor'] = direccionFirebase;
    }

    // === 5. FECHA DE EMISIÓN ===
    if (invoiceData['fechaemision'] != null) {
      final fechaEmision = invoiceData['fechaemision'].toString();
      // Convertir formato de fecha de MM/dd/yyyy o dd/MM/yyyy a dd-MM-yyyy
      final formattedDate = _formatDateForDGII(fechaEmision);
      scenario['FechaEmision'] = formattedDate;
    }

    // === 6. TIPO DE INGRESOS Y PAGO (DESPUÉS DEL EMISOR) ===
    scenario['TipoIngresos'] = invoiceData['tipoingresos'] ?? '01';
    scenario['TipoPago'] = invoiceData['tipopago'] ?? '1';

    // === 7. DATOS DEL COMPRADOR ===
    if (invoiceData['rnccomprador'] != null) {
      scenario['RNCComprador'] = invoiceData['rnccomprador'];
    }
    if (invoiceData['razonsocialcomprador'] != null) {
      scenario['RazonSocialComprador'] = invoiceData['razonsocialcomprador'];
    }

    // === 8. TOTALES ===
    scenario['MontoTotal'] = invoiceData['montototal'] ?? '0.00';

    // === 9. CASO DE PRUEBA (AL FINAL) ===
    final encfForCase = scenario['ENCF'] ?? '';
    if (rncEmisor.isNotEmpty && encfForCase.isNotEmpty) {
      scenario['CasoPrueba'] = '$rncEmisor$encfForCase';
      debugPrint('[QueueProcessor] 🎯 CasoPrueba: $rncEmisor$encfForCase');
    }

    // Items básicos (simplificado)
    scenario['NumeroLinea[1]'] = '1';
    scenario['IndicadorFacturacion[1]'] = '4';
    scenario['NombreItem[1]'] = 'Servicio Médico';
    scenario['IndicadorBienoServicio[1]'] = '2';
    scenario['CantidadItem[1]'] = '1.00';
    scenario['PrecioUnitarioItem[1]'] = invoiceData['montototal'] ?? '0.00';
    scenario['MontoItem[1]'] = invoiceData['montototal'] ?? '0.00';

    return scenario;
  }

  // Determinar status final basado en respuesta DGII
  String _determineStatus(Map<String, dynamic> response) {
    try {
      debugPrint('[QueueProcessor] 📊 Analizando respuesta DGII: $response');

      // === CASO 1: Error HTTP (400, 500, etc.) ===
      if (response.containsKey('status') && response['status'] is int) {
        final httpStatus = response['status'] as int;
        if (httpStatus >= 400) {
          debugPrint('[QueueProcessor] ❌ Error HTTP: $httpStatus');
          return 'rejected';
        }
      }

      // === CASO 2: Respuesta con estructura de error de DGII ===
      if (response.containsKey('data')) {
        final data = response['data'];

        // Si data es un string JSON, parsearlo
        if (data is String) {
          try {
            final parsedData = jsonDecode(data);
            return _analyzeDataResponse(parsedData);
          } catch (e) {
            debugPrint('[QueueProcessor] ❌ Error parseando data JSON: $e');
            return 'rejected';
          }
        }

        // Si data ya es un Map
        if (data is Map<String, dynamic>) {
          return _analyzeDataResponse(data);
        }
      }

      // === CASO 3: Respuesta directa (sin wrapper) ===
      return _analyzeDataResponse(response);
    } catch (e) {
      debugPrint('[QueueProcessor] ❌ Error interpretando respuesta: $e');
      return 'failed';
    }
  }

  // Analizar la respuesta de datos de DGII
  String _analyzeDataResponse(Map<String, dynamic> data) {
    // === CASO 1: Tiene código de error ===
    if (data.containsKey('codigo')) {
      final codigo = data['codigo'];
      debugPrint('[QueueProcessor] 📋 Código DGII: $codigo');

      if (codigo == 0) {
        debugPrint('[QueueProcessor] ✅ Código 0: Aprobado');
        return 'approved';
      } else {
        debugPrint('[QueueProcessor] ❌ Código $codigo: Rechazado');
        return 'rejected';
      }
    }

    // === CASO 2: Tiene mensajes (analizar contenido) ===
    if (data.containsKey('mensajes')) {
      final mensajes = data['mensajes'] as List?;
      if (mensajes != null && mensajes.isNotEmpty) {
        debugPrint(
          '[QueueProcessor] 📝 Analizando ${mensajes.length} mensaje(s) DGII:',
        );

        bool hasErrors = false;
        List<String> errorMessages = [];

        for (int i = 0; i < mensajes.length; i++) {
          final mensaje = mensajes[i];
          if (mensaje is Map<String, dynamic>) {
            final codigo = mensaje['codigo'] ?? '';
            final valor = mensaje['valor'] ?? mensaje['message'] ?? '';

            debugPrint(
              '[QueueProcessor] 💬 Mensaje ${i + 1}: [$codigo] $valor',
            );

            // Detectar palabras clave de error
            final valorLower = valor.toString().toLowerCase();
            if (_isErrorMessage(valorLower)) {
              hasErrors = true;
              errorMessages.add(valor.toString());
              debugPrint('[QueueProcessor] ❌ Mensaje de error detectado');
            }
          }
        }

        // Si hay mensajes de error, es rechazado
        if (hasErrors) {
          debugPrint(
            '[QueueProcessor] ❌ Total de errores encontrados: ${errorMessages.length}',
          );
          return 'rejected';
        } else {
          debugPrint('[QueueProcessor] ✅ Mensajes informativos, sin errores');
          return 'approved';
        }
      }
    }

    // === CASO 3: Tiene errores explícitos ===
    if (data.containsKey('errors') && data['errors'] != null) {
      final errors = data['errors'] as List?;
      if (errors != null && errors.isNotEmpty) {
        debugPrint('[QueueProcessor] ❌ Errores encontrados: ${errors.length}');
        return 'rejected';
      }
    }

    // === CASO 4: Status explícito ===
    if (data.containsKey('status')) {
      final status = data['status']?.toString().toLowerCase();
      debugPrint('[QueueProcessor] 📊 Status: $status');

      if (status == 'success' || status == 'approved' || status == 'ok') {
        return 'approved';
      } else if (status == 'error' ||
          status == 'rejected' ||
          status == 'fail') {
        return 'rejected';
      }
    }

    // === CASO 5: Sin errores explícitos ===
    debugPrint(
      '[QueueProcessor] ✅ Sin errores explícitos, considerando completado',
    );
    return 'completed';
  }

  // Detectar si un mensaje contiene palabras clave de error
  bool _isErrorMessage(String message) {
    final errorKeywords = [
      'error',
      'failed',
      'fail',
      'invalid',
      'inválido',
      'no válido',
      'no es válido',
      'estructura',
      'xml',
      'xsd',
      'rechazado',
      'rejected',
      'denied',
      'forbidden',
      'not found',
      'bad request',
      'unauthorized',
      'timeout',
      'exception',
      'problema',
      'incorrecto',
      'incorrect',
      'missing',
      'required',
      'requerido',
      'obligatorio',
    ];

    for (final keyword in errorKeywords) {
      if (message.contains(keyword)) {
        debugPrint(
          '[QueueProcessor] 🔍 Palabra clave de error encontrada: "$keyword"',
        );
        return true;
      }
    }

    return false;
  }

  // Obtener endpoint desde Firebase
  Future<String?> _getEndpointFromFirebase() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        debugPrint(
          '[QueueProcessor] ❌ Usuario no autenticado para obtener endpoint',
        );
        return null;
      }

      // Obtener datos del usuario
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        debugPrint('[QueueProcessor] ❌ Documento de usuario no existe');
        return null;
      }

      final userData = userDoc.data()!;
      final companyRnc = userData['companyRnc'] as String?;

      if (companyRnc == null || companyRnc.isEmpty) {
        debugPrint('[QueueProcessor] ❌ CompanyRnc no encontrado en usuario');
        return null;
      }

      // Obtener datos de la empresa
      final companyDoc = await _firestore
          .collection('companies')
          .doc(companyRnc)
          .get();
      if (!companyDoc.exists) {
        debugPrint(
          '[QueueProcessor] ❌ Documento de empresa no existe: $companyRnc',
        );
        return null;
      }

      final companyData = companyDoc.data()!;
      final baseEndpointUrl = companyData['baseEndpointUrl'] as String?;
      final envString = companyData['invoiceEnvironment'] as String?;

      if (baseEndpointUrl == null || baseEndpointUrl.isEmpty) {
        debugPrint(
          '[QueueProcessor] ❌ baseEndpointUrl no encontrado en empresa',
        );
        return null;
      }

      // Normalizar base y construir el endpoint respetando el ambiente
      final base = baseEndpointUrl.replaceAll(RegExp(r'/+$'), '');

      // Overrides opcionales desde Firestore
      final testPathOverride = (companyData['dgiiTestPath'] as String?)?.trim();
      final prodPathOverride = (companyData['dgiiProdPath'] as String?)?.trim();

      final env = (envString ?? '').toLowerCase();
      String pathSuffix;
      if (env == 'test' || env == 'certificacion') {
        if (testPathOverride != null && testPathOverride.isNotEmpty) {
          pathSuffix = testPathOverride.startsWith('/')
              ? testPathOverride
              : '/$testPathOverride';
        } else {
          // Certificación: sin segmento env, Test: usar "/test/api/"
          final envSegment = (env == 'certificacion') ? '' : '/test';
          pathSuffix = '${envSegment}/api/test-scenarios-json';
        }
      } else {
        // Producción
        if (prodPathOverride != null && prodPathOverride.isNotEmpty) {
          pathSuffix = prodPathOverride.startsWith('/')
              ? prodPathOverride
              : '/$prodPathOverride';
        } else {
          pathSuffix = '/prod/api/test-scenarios-json';
        }
      }

      final fullEndpoint = '$base$pathSuffix';
      debugPrint(
        '[QueueProcessor] ✅ Endpoint obtenido (${envString ?? 'certificacion'}): $fullEndpoint',
      );

      return fullEndpoint;
    } catch (e) {
      debugPrint(
        '[QueueProcessor] ❌ Error obteniendo endpoint desde Firebase: $e',
      );
      return null;
    }
  }

  // Verificar si hay más items pendientes
  Future<bool> _hasMorePendingItems() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final query = await _firestore
          .collection('invoice_queue')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      final hasPending = query.docs.isNotEmpty;
      debugPrint(
        '[QueueProcessor] 📊 Items pendientes encontrados: $hasPending',
      );
      return hasPending;
    } catch (e) {
      debugPrint('[QueueProcessor] ❌ Error verificando items pendientes: $e');
      return false;
    }
  }

  // Extraer TipoeCF del NCF del ERP
  String _extractTipoeCF(Map<String, dynamic> invoiceData) {
    // Priorizar el tipoecf provisto por el ERP si existe
    final providedTipo =
        (invoiceData['tipoecf'] ?? invoiceData['TipoeCF'] ?? '')
            .toString()
            .trim();
    if (providedTipo.isNotEmpty) {
      debugPrint('[QueueProcessor] 📋 TipoeCF provisto por ERP: $providedTipo');
      return providedTipo;
    }

    // Intentar inferir desde ENCF si es electrónico (E31/E32)
    final numeroFactura =
        invoiceData['numeroFactura'] ??
        invoiceData['encf'] ??
        invoiceData['NumeroFacturaInterna'] ??
        '';

    debugPrint('[QueueProcessor] 🔍 NCF/ENCF del ERP: $numeroFactura');

    if (numeroFactura.toString().startsWith('E31')) {
      debugPrint('[QueueProcessor] 📋 E31 detectado → TipoeCF: 31');
      return '31';
    }

    if (numeroFactura.toString().startsWith('E32')) {
      debugPrint('[QueueProcessor] 📋 E32 detectado → TipoeCF: 32');
      return '32';
    }

    // Si no es electrónico y no se proporciona, no forzar conversión
    debugPrint(
      '[QueueProcessor] 📋 TipoeCF no disponible, sin conversión forzada',
    );
    return '';
  }

  // Generar ENCF único basado en NCF del ERP
  String _generateUniqueENCF(Map<String, dynamic> invoiceData) {
    // Tomar ENCF directamente del ERP si existe, sin conversión
    final numeroFactura =
        invoiceData['encf'] ??
        invoiceData['numeroFactura'] ??
        invoiceData['NumeroFacturaInterna'] ??
        '';

    final ncfString = numeroFactura.toString();
    debugPrint('[QueueProcessor] 🔍 ENCF tomado del ERP: $ncfString');
    return ncfString;
  }

  // Formatear fecha para DGII (dd-MM-yyyy)
  String _formatDateForDGII(String dateString) {
    if (dateString.isEmpty) return dateString;

    // Si ya tiene el formato correcto (con guiones), devolverlo
    if (dateString.contains('-') && !dateString.contains('/')) {
      return dateString;
    }

    // Convertir barras a guiones
    final formattedDate = dateString.replaceAll('/', '-');

    debugPrint(
      '[QueueProcessor] 📅 Fecha formateada: $dateString → $formattedDate',
    );
    return formattedDate;
  }
}
