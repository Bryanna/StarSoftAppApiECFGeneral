import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/erp_endpoint.dart';
import '../models/erp_invoice.dart';
import '../models/erp_invoice_extensions.dart';
import '../models/invoice.dart';
import '../models/ui_types.dart';
import '../screens/configuracion/configuracion_controller.dart';
import 'erp_endpoint_service.dart';
import 'fake_data_service.dart';
import 'firebase_auth_service.dart';
import 'firestore_service.dart';

class InvoiceService {
  final FirestoreService _db = FirestoreService();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final ERPEndpointService _endpointService = ERPEndpointService();

  // Obtiene facturas reales desde el endpoint ERP configurado o datos fake
  Future<List<ERPInvoice>> fetchInvoices(
    InvoiceCategory category, {
    bool forceReal = false,
  }) async {
    try {
      // Verificar si debemos usar datos fake (a menos que se fuerce usar real)
      final useFakeData = forceReal ? false : await _shouldUseFakeData();

      debugPrint(
        '[InvoiceService] forceReal: $forceReal, useFakeData: $useFakeData',
      );

      if (useFakeData) {
        debugPrint('[InvoiceService] Using fake data (configured in settings)');
        return await _generateFakeInvoices(category);
      }

      // Intentar obtener datos reales del ERP combinando múltiples endpoints
      debugPrint(
        '[InvoiceService] Attempting to fetch and combine data from multiple ERP endpoints',
      );

      // Obtener URLs de ambos endpoints configurados (ARS + Invoices)
      final endpointUrls = await _getAllConfiguredEndpointUrls();

      debugPrint(
        '[InvoiceService] Found ${endpointUrls.length} endpoint URLs to call',
      );
      for (int i = 0; i < endpointUrls.length; i++) {
        debugPrint('[InvoiceService] URL ${i + 1}: ${endpointUrls[i]}');
      }

      if (endpointUrls.isEmpty) {
        debugPrint(
          '[InvoiceService] No endpoints configured, trying legacy system...',
        );
        // Fallback al sistema legacy de ERPEndpoint
        final endpoints = await _getConfiguredEndpoints();
        if (endpoints.isEmpty) {
          throw ERPNotConfiguredException('No hay endpoints ERP configurados');
        }

        final invoiceEndpoint = endpoints.firstWhere(
          (e) => e.type == EndpointType.invoices,
          orElse: () => endpoints.first,
        );
        return await _fetchFromERP(invoiceEndpoint.url, category);
      }

      // IMPORTANTE: Realizar llamadas HTTP a TODOS los endpoints y combinar resultados
      debugPrint(
        '[InvoiceService] Calling _fetchAndCombineFromMultipleEndpoints with ${endpointUrls.length} URLs',
      );
      return await _fetchAndCombineFromMultipleEndpoints(
        endpointUrls,
        category,
      );
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

  // Obtiene TODAS las URLs de endpoints configurados para combinar datos
  Future<List<String>> _getAllConfiguredEndpointUrls() async {
    try {
      final List<String> urls = [];

      debugPrint('[InvoiceService] Getting all configured endpoint URLs...');

      // Intentar obtener del controller si está registrado
      if (Get.isRegistered<ConfiguracionController>()) {
        final controller = Get.find<ConfiguracionController>();

        debugPrint(
          '[InvoiceService] Controller found with ${controller.erpEndpoints.length} endpoints',
        );
        debugPrint('[InvoiceService] Base URL: ${controller.baseERPUrl}');
        debugPrint(
          '[InvoiceService] Endpoints map: ${controller.erpEndpoints}',
        );

        // IMPORTANTE: Agregar TODOS los endpoints configurados, no solo algunos específicos
        for (final entry in controller.erpEndpoints.entries) {
          final key = entry.key;
          final endpoint = entry.value;
          final fullUrl = controller.getFullEndpointUrl(key);

          if (!urls.contains(fullUrl)) {
            urls.add(fullUrl);
            debugPrint('[InvoiceService] ✅ Added endpoint ($key): $fullUrl');
          } else {
            debugPrint(
              '[InvoiceService] ⚠️ Skipped duplicate URL ($key): $fullUrl',
            );
          }
        }
      } else {
        // Si no está registrado, intentar obtener directamente de Firestore
        final uid = _auth.currentUser?.uid;
        if (uid != null) {
          final userDoc = await _db.doc('users/$uid').get();
          final userData = userDoc.data();
          final companyRnc = userData?['companyRnc'] as String?;

          if (companyRnc != null) {
            debugPrint(
              '[InvoiceService] Reading from Firestore for company: $companyRnc',
            );

            final companyDoc = await _db.doc('companies/$companyRnc').get();
            final companyData = companyDoc.data();
            final baseERPUrl = companyData?['baseERPUrl'] as String?;

            debugPrint('[InvoiceService] Base URL from Firestore: $baseERPUrl');

            if (baseERPUrl != null) {
              // CORRECCIÓN: Leer desde la subcollection erp_endpoints
              debugPrint(
                '[InvoiceService] Reading from subcollection: companies/$companyRnc/erp_endpoints',
              );

              final endpointsSnapshot = await _db
                  .collection('companies/$companyRnc/erp_endpoints')
                  .get();

              debugPrint(
                '[InvoiceService] Found ${endpointsSnapshot.docs.length} endpoint documents in subcollection',
              );

              for (final doc in endpointsSnapshot.docs) {
                final data = doc.data();
                final url =
                    data['url']
                        as String?; // CORRECCIÓN: usar 'url' en lugar de 'endpoint'
                final name = data['name'] as String?;
                final type = data['type'] as String?;

                debugPrint(
                  '[InvoiceService] Processing endpoint doc: ${doc.id}',
                );
                debugPrint('[InvoiceService] Endpoint data: $data');

                if (url != null) {
                  if (!urls.contains(url)) {
                    urls.add(url);
                    debugPrint(
                      '[InvoiceService] ✅ Added endpoint from subcollection (${doc.id}): $url',
                    );
                    debugPrint('[InvoiceService] ✅ Name: $name, Type: $type');
                  } else {
                    debugPrint(
                      '[InvoiceService] ⚠️ Skipped duplicate URL from subcollection (${doc.id}): $url',
                    );
                  }
                } else {
                  debugPrint(
                    '[InvoiceService] ❌ No url field found in doc: ${doc.id}',
                  );
                }
              }

              // Fallback: También intentar leer desde el campo erpEndpoints del documento principal
              final erpEndpoints =
                  companyData?['erpEndpoints'] as Map<String, dynamic>?;
              if (erpEndpoints != null) {
                debugPrint(
                  '[InvoiceService] Also found erpEndpoints field in main document',
                );
                for (final entry in erpEndpoints.entries) {
                  final endpoint = entry.value as String;
                  final url = _buildFullUrl(baseERPUrl, endpoint);
                  if (!urls.contains(url)) {
                    urls.add(url);
                    debugPrint(
                      '[InvoiceService] ✅ Added endpoint from main document (${entry.key}): $url',
                    );
                  }
                }
              }

              debugPrint(
                '[InvoiceService] Total unique URLs collected: ${urls.length}',
              );
            } else {
              debugPrint(
                '[InvoiceService] ❌ No baseERPUrl found in company document',
              );
            }
          } else {
            debugPrint('[InvoiceService] ❌ No companyRnc found for user');
          }
        } else {
          debugPrint('[InvoiceService] ❌ No authenticated user');
        }
      }

      debugPrint('[InvoiceService] Total endpoints to fetch: ${urls.length}');
      return urls;
    } catch (e) {
      debugPrint(
        '[InvoiceService] Error getting all configured endpoint URLs: $e',
      );
      return [];
    }
  }

  // Obtiene la URL del endpoint configurado en ConfiguracionController (método legacy)
  Future<String?> _getConfiguredEndpointUrl() async {
    try {
      // Intentar obtener del controller si está registrado
      if (Get.isRegistered<ConfiguracionController>()) {
        final controller = Get.find<ConfiguracionController>();

        // Prioridad: ars > ars_alt > invoices > primer endpoint disponible
        if (controller.erpEndpoints.containsKey('ars')) {
          final url = controller.getFullEndpointUrl('ars');
          debugPrint('[InvoiceService] Using ARS endpoint: $url');
          return url;
        }

        if (controller.erpEndpoints.containsKey('ars_alt')) {
          final url = controller.getFullEndpointUrl('ars_alt');
          debugPrint('[InvoiceService] Using ARS_ALT endpoint: $url');
          return url;
        }

        if (controller.erpEndpoints.containsKey('invoices')) {
          final url = controller.getFullEndpointUrl('invoices');
          debugPrint('[InvoiceService] Using INVOICES endpoint: $url');
          return url;
        }

        // Si hay otros endpoints, usar el primero
        if (controller.erpEndpoints.isNotEmpty) {
          final firstKey = controller.erpEndpoints.keys.first;
          final url = controller.getFullEndpointUrl(firstKey);
          debugPrint(
            '[InvoiceService] Using first available endpoint ($firstKey): $url',
          );
          return url;
        }
      }

      // Si no está registrado, intentar obtener directamente de Firestore
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final userDoc = await _db.doc('users/$uid').get();
      final userData = userDoc.data();
      final companyRnc = userData?['companyRnc'] as String?;

      if (companyRnc == null) return null;

      final companyDoc = await _db.doc('companies/$companyRnc').get();
      final companyData = companyDoc.data();

      final baseERPUrl = companyData?['baseERPUrl'] as String?;
      final erpEndpoints =
          companyData?['erpEndpoints'] as Map<String, dynamic>?;

      if (baseERPUrl != null && erpEndpoints != null) {
        // Misma lógica de prioridad
        if (erpEndpoints.containsKey('ars')) {
          final endpoint = erpEndpoints['ars'] as String;
          final url = _buildFullUrl(baseERPUrl, endpoint);
          debugPrint(
            '[InvoiceService] Using ARS endpoint from Firestore: $url',
          );
          return url;
        }

        if (erpEndpoints.containsKey('ars_alt')) {
          final endpoint = erpEndpoints['ars_alt'] as String;
          final url = _buildFullUrl(baseERPUrl, endpoint);
          debugPrint(
            '[InvoiceService] Using ARS_ALT endpoint from Firestore: $url',
          );
          return url;
        }

        if (erpEndpoints.containsKey('invoices')) {
          final endpoint = erpEndpoints['invoices'] as String;
          final url = _buildFullUrl(baseERPUrl, endpoint);
          debugPrint(
            '[InvoiceService] Using INVOICES endpoint from Firestore: $url',
          );
          return url;
        }

        // Usar el primer endpoint disponible
        if (erpEndpoints.isNotEmpty) {
          final firstKey = erpEndpoints.keys.first;
          final endpoint = erpEndpoints[firstKey] as String;
          final url = _buildFullUrl(baseERPUrl, endpoint);
          debugPrint(
            '[InvoiceService] Using first available endpoint from Firestore ($firstKey): $url',
          );
          return url;
        }
      }

      return null;
    } catch (e) {
      debugPrint('[InvoiceService] Error getting configured endpoint URL: $e');
      return null;
    }
  }

  // Helper para construir URL completa
  String _buildFullUrl(String baseUrl, String endpoint) {
    final base = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$base$path';
  }

  // Obtiene los endpoints configurados del ERP (sistema legacy)
  Future<List<ERPEndpoint>> _getConfiguredEndpoints() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return [];

      final userDoc = await _db.doc('users/$uid').get();
      final userData = userDoc.data();
      final companyRnc = userData?['companyRnc'] as String?;

      if (companyRnc == null) return [];

      // Obtener endpoints configurados
      final endpoints = await _endpointService.getEndpoints(companyRnc);
      debugPrint(
        '[InvoiceService] Found ${endpoints.length} configured endpoints',
      );

      return endpoints;
    } catch (e) {
      debugPrint('[InvoiceService] Error getting configured endpoints: $e');
      return [];
    }
  }

  // Realiza llamadas HTTP a múltiples endpoints y combina los resultados
  Future<List<ERPInvoice>> _fetchAndCombineFromMultipleEndpoints(
    List<String> endpointUrls,
    InvoiceCategory category,
  ) async {
    debugPrint('');
    debugPrint('🔗 ===== COMBINANDO MÚLTIPLES ENDPOINTS =====');
    debugPrint('🔗 Total endpoints a llamar: ${endpointUrls.length}');
    for (int i = 0; i < endpointUrls.length; i++) {
      debugPrint('🔗 Endpoint ${i + 1}: ${endpointUrls[i]}');
    }
    debugPrint('🔗 ==========================================');
    debugPrint('');

    final List<ERPInvoice> allInvoices = [];
    final List<String> successfulEndpoints = [];
    final List<String> failedEndpoints = [];

    // Hacer llamadas a todos los endpoints en paralelo
    final futures = endpointUrls.map((url) => _fetchFromSingleEndpoint(url));
    final results = await Future.wait(futures, eagerError: false);

    // Procesar resultados
    for (int i = 0; i < endpointUrls.length; i++) {
      final url = endpointUrls[i];
      final result = results[i];

      debugPrint('');
      debugPrint('🔍 PROCESANDO RESULTADO ${i + 1}/${endpointUrls.length}');
      debugPrint('🔍 URL: $url');

      if (result != null && result.isNotEmpty) {
        // Analizar tipos de tab antes de agregar
        final tabTypes = <String, int>{};
        for (final invoice in result) {
          final tabType = invoice.tipoTabEnvioFactura;
          if (tabType != null) {
            tabTypes[tabType] = (tabTypes[tabType] ?? 0) + 1;
          }
        }

        allInvoices.addAll(result);
        successfulEndpoints.add(url);

        debugPrint('✅ ÉXITO - Facturas obtenidas: ${result.length}');
        debugPrint('✅ Tipos de tab encontrados:');
        for (final entry in tabTypes.entries) {
          debugPrint('   • ${entry.key}: ${entry.value}');
        }
        debugPrint('✅ Total acumulado hasta ahora: ${allInvoices.length}');
      } else {
        failedEndpoints.add(url);
        debugPrint('❌ ERROR - No se obtuvieron datos');
        if (result == null) {
          debugPrint('❌ Resultado es null (excepción en la llamada)');
        } else {
          debugPrint('❌ Resultado es lista vacía');
        }
      }
    }

    debugPrint('');
    debugPrint('🎯 ===== RESUMEN FINAL DE COMBINACIÓN =====');
    debugPrint('🎯 Total facturas combinadas: ${allInvoices.length}');
    debugPrint(
      '🎯 Endpoints exitosos: ${successfulEndpoints.length}/${endpointUrls.length}',
    );
    debugPrint('🎯 Endpoints fallidos: ${failedEndpoints.length}');

    // Análisis de tipos de tab en el resultado combinado
    final combinedTabTypes = <String, int>{};
    for (final invoice in allInvoices) {
      final tabType = invoice.tipoTabEnvioFactura;
      if (tabType != null) {
        combinedTabTypes[tabType] = (combinedTabTypes[tabType] ?? 0) + 1;
      }
    }

    debugPrint('🎯 Tipos de tab en resultado combinado:');
    for (final entry in combinedTabTypes.entries) {
      debugPrint('   • ${entry.key}: ${entry.value}');
    }
    debugPrint('🎯 ========================================');
    debugPrint('');

    // Si no se obtuvo ningún dato, lanzar error
    if (allInvoices.isEmpty) {
      if (failedEndpoints.length == endpointUrls.length) {
        throw ERPConnectionException(
          'No se pudo conectar a ninguno de los ${endpointUrls.length} endpoints configurados',
        );
      } else {
        throw NoInvoicesFoundException(
          'No se encontraron facturas en ninguno de los endpoints',
        );
      }
    }

    // Eliminar duplicados basados en ENCF
    final uniqueInvoices = _removeDuplicateInvoices(allInvoices);
    debugPrint(
      '[InvoiceService] After removing duplicates: ${uniqueInvoices.length} invoices',
    );

    // Debug final de tipos de tab después de eliminar duplicados
    final finalTabTypes = <String, int>{};
    for (final invoice in uniqueInvoices) {
      final tabType = invoice.tipoTabEnvioFactura;
      if (tabType != null) {
        finalTabTypes[tabType] = (finalTabTypes[tabType] ?? 0) + 1;
      }
    }

    debugPrint('');
    debugPrint('🏁 RESULTADO FINAL DESPUÉS DE ELIMINAR DUPLICADOS:');
    debugPrint('🏁 Total facturas únicas: ${uniqueInvoices.length}');
    debugPrint('🏁 Tipos de tab finales:');
    for (final entry in finalTabTypes.entries) {
      debugPrint('   • ${entry.key}: ${entry.value}');
    }
    debugPrint('');

    return uniqueInvoices;
  }

  // Realiza llamada HTTP a un solo endpoint (con manejo de errores)
  Future<List<ERPInvoice>?> _fetchFromSingleEndpoint(String erpUrl) async {
    debugPrint('');
    debugPrint('📡 LLAMANDO A ENDPOINT INDIVIDUAL: $erpUrl');

    try {
      final result = await _fetchFromERP(erpUrl, InvoiceCategory.todos);

      debugPrint('📡 ✅ Endpoint respondió con ${result.length} facturas');

      // Debug de tipos de tab en este endpoint
      final tabTypes = <String, int>{};
      for (final invoice in result) {
        final tabType = invoice.tipoTabEnvioFactura;
        if (tabType != null) {
          tabTypes[tabType] = (tabTypes[tabType] ?? 0) + 1;
        }
      }

      if (tabTypes.isNotEmpty) {
        debugPrint('📡 ✅ Tipos de tab en este endpoint:');
        for (final entry in tabTypes.entries) {
          debugPrint('     • ${entry.key}: ${entry.value}');
        }
      } else {
        debugPrint('📡 ⚠️ No se encontraron tipos de tab en este endpoint');
      }

      return result;
    } catch (e) {
      debugPrint('📡 ❌ Error fetching from $erpUrl: $e');
      return null;
    }
  }

  // Elimina facturas duplicadas basándose en el ENCF
  List<ERPInvoice> _removeDuplicateInvoices(List<ERPInvoice> invoices) {
    final Map<String, ERPInvoice> uniqueInvoices = {};

    for (final invoice in invoices) {
      final key = invoice.encf ?? 'no_encf_${invoice.hashCode}';

      // Si ya existe, mantener el que tenga más información
      if (uniqueInvoices.containsKey(key)) {
        final existing = uniqueInvoices[key]!;
        // Priorizar el que tenga tipoTabEnvioFactura
        if (invoice.tipoTabEnvioFactura != null &&
            existing.tipoTabEnvioFactura == null) {
          uniqueInvoices[key] = invoice;
        }
      } else {
        uniqueInvoices[key] = invoice;
      }
    }

    return uniqueInvoices.values.toList();
  }

  // Realiza la llamada HTTP al ERP (método original)
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
