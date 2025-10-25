import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../lib/screens/configuracion/configuracion_controller.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Debug Direct Calls',
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      home: const DebugDirectCallsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Test que hace llamadas HTTP directas a ambos endpoints para verificar qué devuelven
class DebugDirectCallsScreen extends StatefulWidget {
  const DebugDirectCallsScreen({super.key});

  @override
  State<DebugDirectCallsScreen> createState() => _DebugDirectCallsScreenState();
}

class _DebugDirectCallsScreenState extends State<DebugDirectCallsScreen> {
  bool _loading = false;
  String _debugLog = '';
  Map<String, dynamic> _results = {};

  final String _baseUrl = 'http://137.184.7.44:3390/api';
  final String _arsEndpoint = '/ars/full';
  final String _invoicesEndpoint = '/invoices/full';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug: Llamadas Directas'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explicación
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bug_report, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Debug: Llamadas HTTP Directas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Este test hace llamadas HTTP directas a ambos endpoints para verificar exactamente qué datos devuelve cada uno.',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Endpoints a probar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Endpoints a Probar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _EndpointCard(
                      name: 'ARS Full',
                      url: '$_baseUrl$_arsEndpoint',
                      description:
                          'Debería devolver facturas con "tipo_tab_envio_factura": "FacturaArs"',
                      color: Colors.green,
                    ),

                    const SizedBox(height: 8),

                    _EndpointCard(
                      name: 'Invoices Full',
                      url: '$_baseUrl$_invoicesEndpoint',
                      description:
                          'Debería devolver facturas con "tipo_tab_envio_factura": "FacturaPaciente"',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Configuración del controller
            GetBuilder<ConfiguracionController>(
              init: ConfiguracionController(),
              builder: (controller) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Configuración del Controller',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Configurar exactamente como debe ser
                              controller.baseERPUrl = _baseUrl;
                              controller.baseERPUrlCtrl.text =
                                  controller.baseERPUrl;

                              // Limpiar y configurar endpoints
                              controller.erpEndpoints.clear();
                              controller.addEndpoint('ars', _arsEndpoint);
                              controller.addEndpoint(
                                'invoices',
                                _invoicesEndpoint,
                              );

                              controller.update();

                              Get.snackbar(
                                'Configurado',
                                'Controller configurado con ambos endpoints',
                                backgroundColor: Colors.green[100],
                                colorText: Colors.green[700],
                              );
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('Configurar Controller'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                              foregroundColor: Colors.blue[700],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Estado actual del controller
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Base URL: ${controller.baseERPUrl}'),
                              Text(
                                'Endpoints configurados: ${controller.erpEndpoints.length}',
                              ),
                              ...controller.erpEndpoints.entries.map((entry) {
                                return Text(
                                  '• ${entry.key}: ${controller.getFullEndpointUrl(entry.key)}',
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Botón de test
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ejecutar Test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _runDirectCallsTest,
                        icon: _loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(
                          _loading
                              ? 'Ejecutando...'
                              : 'Hacer Llamadas Directas',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Log de debug
            if (_debugLog.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.terminal),
                          const SizedBox(width: 8),
                          const Text(
                            'Debug Log',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _debugLog = '';
                                _results = {};
                              });
                            },
                            icon: const Icon(Icons.clear),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _debugLog,
                          style: const TextStyle(
                            color: Colors.green,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Resultados
            if (_results.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resultados',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Resultado ARS
                      if (_results.containsKey('ars'))
                        _ResultCard(
                          title: 'Endpoint ARS',
                          url: '$_baseUrl$_arsEndpoint',
                          result: _results['ars'],
                          color: Colors.green,
                        ),

                      const SizedBox(height: 12),

                      // Resultado Invoices
                      if (_results.containsKey('invoices'))
                        _ResultCard(
                          title: 'Endpoint Invoices',
                          url: '$_baseUrl$_invoicesEndpoint',
                          result: _results['invoices'],
                          color: Colors.blue,
                        ),

                      const SizedBox(height: 12),

                      // Análisis combinado
                      if (_results.containsKey('ars') &&
                          _results.containsKey('invoices'))
                        _CombinedAnalysis(
                          arsResult: _results['ars'],
                          invoicesResult: _results['invoices'],
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _runDirectCallsTest() async {
    setState(() {
      _loading = true;
      _debugLog = '';
      _results = {};
    });

    _addToLog('🚀 INICIANDO TEST DE LLAMADAS DIRECTAS');
    _addToLog('');

    // Test endpoint ARS
    _addToLog('📞 Llamando a endpoint ARS...');
    final arsResult = await _callEndpoint('$_baseUrl$_arsEndpoint', 'ARS');
    _results['ars'] = arsResult;

    await Future.delayed(const Duration(milliseconds: 500));

    // Test endpoint Invoices
    _addToLog('');
    _addToLog('📞 Llamando a endpoint Invoices...');
    final invoicesResult = await _callEndpoint(
      '$_baseUrl$_invoicesEndpoint',
      'Invoices',
    );
    _results['invoices'] = invoicesResult;

    _addToLog('');
    _addToLog('🏁 TEST COMPLETADO');

    setState(() {
      _loading = false;
    });
  }

  Future<Map<String, dynamic>> _callEndpoint(String url, String name) async {
    try {
      _addToLog('   URL: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      _addToLog('   Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Analizar estructura
        int count = 0;
        List<dynamic>? dataArray;

        if (jsonData is List) {
          dataArray = jsonData;
          count = jsonData.length;
        } else if (jsonData is Map<String, dynamic>) {
          // Buscar array dentro del objeto
          for (final key in jsonData.keys) {
            if (jsonData[key] is List) {
              dataArray = jsonData[key];
              count = dataArray!.length;
              break;
            }
          }
        }

        _addToLog('   ✅ Éxito: $count registros');

        // Analizar tipos de tab
        final Map<String, int> tabTypes = {};
        if (dataArray != null) {
          for (final item in dataArray) {
            if (item is Map<String, dynamic>) {
              final tabType = item['tipo_tab_envio_factura'] as String?;
              if (tabType != null) {
                tabTypes[tabType] = (tabTypes[tabType] ?? 0) + 1;
              }
            }
          }
        }

        _addToLog('   📊 Tipos de tab encontrados:');
        for (final entry in tabTypes.entries) {
          _addToLog('      • ${entry.key}: ${entry.value}');
        }

        return {
          'success': true,
          'statusCode': response.statusCode,
          'count': count,
          'tabTypes': tabTypes,
          'sampleData': dataArray?.isNotEmpty == true ? dataArray!.first : null,
        };
      } else {
        _addToLog('   ❌ Error HTTP: ${response.statusCode}');
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': 'HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      _addToLog('   💥 Excepción: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  void _addToLog(String message) {
    setState(() {
      _debugLog += '$message\n';
    });
  }
}

class _EndpointCard extends StatelessWidget {
  final String name;
  final String url;
  final String description;
  final MaterialColor color;

  const _EndpointCard({
    required this.name,
    required this.url,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold, color: color[700]),
          ),
          const SizedBox(height: 4),
          Text(
            url,
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(fontSize: 12, color: color[600])),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String url;
  final Map<String, dynamic> result;
  final MaterialColor color;

  const _ResultCard({
    required this.title,
    required this.url,
    required this.result,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final success = result['success'] as bool;
    final count = result['count'] as int?;
    final tabTypes = result['tabTypes'] as Map<String, int>?;
    final error = result['error'] as String?;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: success ? color[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: success ? color[200]! : Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? color[700] : Colors.red[700],
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: success ? color[700] : Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            url,
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 8),
          if (success) ...[
            Text('📊 Total registros: ${count ?? 0}'),
            if (tabTypes != null && tabTypes.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Text('🏷️ Tipos de tab:'),
              ...tabTypes.entries.map((entry) {
                return Text('   • ${entry.key}: ${entry.value}');
              }),
            ],
          ] else ...[
            Text(
              'Error: ${error ?? "Desconocido"}',
              style: TextStyle(color: Colors.red[700]),
            ),
          ],
        ],
      ),
    );
  }
}

class _CombinedAnalysis extends StatelessWidget {
  final Map<String, dynamic> arsResult;
  final Map<String, dynamic> invoicesResult;

  const _CombinedAnalysis({
    required this.arsResult,
    required this.invoicesResult,
  });

  @override
  Widget build(BuildContext context) {
    final arsSuccess = arsResult['success'] as bool;
    final invoicesSuccess = invoicesResult['success'] as bool;
    final arsCount = arsResult['count'] as int? ?? 0;
    final invoicesCount = invoicesResult['count'] as int? ?? 0;
    final arsTabTypes = arsResult['tabTypes'] as Map<String, int>? ?? {};
    final invoicesTabTypes =
        invoicesResult['tabTypes'] as Map<String, int>? ?? {};

    final bothWork = arsSuccess && invoicesSuccess;
    final totalRecords = arsCount + invoicesCount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bothWork ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: bothWork ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                bothWork ? Icons.merge_type : Icons.error,
                color: bothWork ? Colors.green[700] : Colors.red[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Análisis Combinado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: bothWork ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (bothWork)
            ..._buildSuccessContent(
              totalRecords,
              arsCount,
              invoicesCount,
              arsTabTypes,
              invoicesTabTypes,
            )
          else ...[
            Text(
              '❌ Problema detectado:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            if (!arsSuccess) const Text('   • Endpoint ARS falló'),
            if (!invoicesSuccess) const Text('   • Endpoint Invoices falló'),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildSuccessContent(
    int totalRecords,
    int arsCount,
    int invoicesCount,
    Map<String, int> arsTabTypes,
    Map<String, int> invoicesTabTypes,
  ) {
    // Combinar tipos de tab
    final allTabTypes = <String, int>{};
    arsTabTypes.forEach((key, value) {
      allTabTypes[key] = (allTabTypes[key] ?? 0) + value;
    });
    invoicesTabTypes.forEach((key, value) {
      allTabTypes[key] = (allTabTypes[key] ?? 0) + value;
    });

    return [
      const Text('✅ Ambos endpoints funcionan correctamente'),
      Text('📊 Total registros combinados: $totalRecords'),
      Text('   • ARS: $arsCount registros'),
      Text('   • Invoices: $invoicesCount registros'),

      const SizedBox(height: 8),
      const Text('🏷️ Tipos de tab combinados:'),

      ...allTabTypes.entries.map((entry) {
        return Text('   • ${entry.key}: ${entry.value}');
      }),

      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          allTabTypes.length > 1
              ? '🎉 PROBLEMA RESUELTO: Se detectan múltiples tipos de tab'
              : '⚠️ Solo se detecta un tipo de tab',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
      ),
    ];
  }
}
