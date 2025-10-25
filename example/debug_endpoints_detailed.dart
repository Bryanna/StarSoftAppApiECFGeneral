import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../lib/screens/configuracion/configuracion_controller.dart';

/// Test detallado para diagnosticar por qué no se ven datos de ambos endpoints
class DebugEndpointsDetailedScreen extends StatefulWidget {
  const DebugEndpointsDetailedScreen({super.key});

  @override
  State<DebugEndpointsDetailedScreen> createState() =>
      _DebugEndpointsDetailedScreenState();
}

class _DebugEndpointsDetailedScreenState
    extends State<DebugEndpointsDetailedScreen> {
  bool loading = false;
  Map<String, dynamic> testResults = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug: Endpoints Detallado'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test individual de cada endpoint
            _IndividualEndpointTestCard(),

            const SizedBox(height: 16),

            // Resultados del test
            if (testResults.isNotEmpty) _TestResultsCard(),
          ],
        ),
      ),
    );
  }

  Widget _IndividualEndpointTestCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Test Individual de Endpoints',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Información de endpoints a probar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Endpoints que se probarán individualmente:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('1. http://137.184.7.44:3390/api/ars/full'),
                  Text('2. http://137.184.7.44:3390/api/invoices/full'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botón de test
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: loading ? null : _testBothEndpointsIndividually,
                icon: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  loading
                      ? 'Probando...'
                      : 'Probar Ambos Endpoints Individualmente',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005285),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _TestResultsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Resultados del Test',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ...testResults.entries.map((entry) {
              final endpointName = entry.key;
              final result = entry.value as Map<String, dynamic>;
              final success = result['success'] as bool;
              final error = result['error'] as String?;
              final count = result['count'] as int? ?? 0;
              final url = result['url'] as String;
              final sampleData = result['sampleData'] as Map<String, dynamic>?;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: success ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: success ? Colors.green[200]! : Colors.red[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          success ? Icons.check_circle : Icons.error,
                          color: success ? Colors.green[700] : Colors.red[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          endpointName.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: success
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'URL: $url',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),

                    if (success) ...[
                      Text('✅ Facturas obtenidas: $count'),
                      if (sampleData != null) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Muestra de datos (primer registro):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ENCF: ${sampleData['encf'] ?? "N/A"}'),
                              Text(
                                'Tipo ECF: ${sampleData['tipoecf'] ?? "N/A"}',
                              ),
                              Text(
                                'Cliente: ${sampleData['razonsocialcomprador'] ?? "N/A"}',
                              ),
                              Text(
                                'tipo_tab_envio_factura: ${sampleData['tipo_tab_envio_factura'] ?? "NULL"}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      sampleData['tipo_tab_envio_factura'] !=
                                          null
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                              ),
                              if (sampleData.containsKey('montototal'))
                                Text('Monto: ${sampleData['montototal']}'),
                            ],
                          ),
                        ),
                      ],
                    ] else ...[
                      Text(
                        '❌ Error: $error',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _testBothEndpointsIndividually() async {
    setState(() {
      loading = true;
      testResults.clear();
    });

    final endpoints = {
      'ars': 'http://137.184.7.44:3390/api/ars/full',
      'invoices': 'http://137.184.7.44:3390/api/invoices/full',
    };

    for (final entry in endpoints.entries) {
      final name = entry.key;
      final url = entry.value;

      debugPrint('');
      debugPrint('🧪 TESTING ENDPOINT: $name');
      debugPrint('🧪 URL: $url');
      debugPrint('');

      try {
        final response = await http
            .get(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 30));

        debugPrint('🧪 Response Status: ${response.statusCode}');
        debugPrint('🧪 Response Length: ${response.body.length} characters');

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);

          // Analizar estructura de respuesta
          List<dynamic>? dataList;

          if (jsonData is Map<String, dynamic>) {
            if (jsonData.containsKey('data') && jsonData['data'] is List) {
              dataList = jsonData['data'];
            } else if (jsonData.containsKey('invoices') &&
                jsonData['invoices'] is List) {
              dataList = jsonData['invoices'];
            } else if (jsonData.containsKey('facturas') &&
                jsonData['facturas'] is List) {
              dataList = jsonData['facturas'];
            }
          } else if (jsonData is List) {
            dataList = jsonData;
          }

          if (dataList != null && dataList.isNotEmpty) {
            final firstItem = dataList.first as Map<String, dynamic>;

            debugPrint('🧪 Data structure found: ${dataList.length} items');
            debugPrint('🧪 First item keys: ${firstItem.keys.toList()}');
            debugPrint(
              '🧪 Has tipo_tab_envio_factura: ${firstItem.containsKey('tipo_tab_envio_factura')}',
            );
            debugPrint(
              '🧪 tipo_tab_envio_factura value: ${firstItem['tipo_tab_envio_factura']}',
            );

            testResults[name] = {
              'success': true,
              'url': url,
              'count': dataList.length,
              'sampleData': firstItem,
              'error': null,
            };
          } else {
            debugPrint('🧪 No data array found in response');
            testResults[name] = {
              'success': false,
              'url': url,
              'count': 0,
              'sampleData': null,
              'error': 'No data array found in response structure',
            };
          }
        } else {
          debugPrint(
            '🧪 HTTP Error: ${response.statusCode} - ${response.reasonPhrase}',
          );
          testResults[name] = {
            'success': false,
            'url': url,
            'count': 0,
            'sampleData': null,
            'error': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          };
        }
      } catch (e) {
        debugPrint('🧪 Exception: $e');
        testResults[name] = {
          'success': false,
          'url': url,
          'count': 0,
          'sampleData': null,
          'error': e.toString(),
        };
      }
    }

    setState(() {
      loading = false;
    });

    // Mostrar resumen en snackbar
    final arsSuccess = testResults['ars']?['success'] ?? false;
    final invoicesSuccess = testResults['invoices']?['success'] ?? false;
    final arsCount = testResults['ars']?['count'] ?? 0;
    final invoicesCount = testResults['invoices']?['count'] ?? 0;

    Get.snackbar(
      'Test Completado',
      'ARS: ${arsSuccess ? "$arsCount facturas" : "ERROR"} | '
          'Invoices: ${invoicesSuccess ? "$invoicesCount facturas" : "ERROR"}',
      backgroundColor: (arsSuccess && invoicesSuccess)
          ? Colors.green[100]
          : Colors.orange[100],
      colorText: (arsSuccess && invoicesSuccess)
          ? Colors.green[700]
          : Colors.orange[700],
      duration: const Duration(seconds: 5),
    );
  }
}
