import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Test Individual Endpoints',
      theme: ThemeData(primarySwatch: Colors.purple, useMaterial3: true),
      home: const TestIndividualEndpointsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Test para llamar individualmente a cada endpoint y ver qué devuelve
class TestIndividualEndpointsScreen extends StatefulWidget {
  const TestIndividualEndpointsScreen({super.key});

  @override
  State<TestIndividualEndpointsScreen> createState() =>
      _TestIndividualEndpointsScreenState();
}

class _TestIndividualEndpointsScreenState
    extends State<TestIndividualEndpointsScreen> {
  bool _loading = false;
  Map<String, Map<String, dynamic>> _results = {};

  final List<Map<String, String>> _endpoints = [
    {
      'name': 'ARS Full',
      'url': 'https://cempsavid.duckdns.org/api/ars/full',
      'description': 'Endpoint de facturas ARS con tipo_tab_envio_factura',
    },
    {
      'name': 'Invoices Full',
      'url': 'https://cempsavid.duckdns.org/api/invoices/full',
      'description': 'Endpoint de facturas generales (full)',
    },
    {
      'name': 'Invoices',
      'url': 'https://cempsavid.duckdns.org/api/invoices',
      'description': 'Endpoint de facturas generales (sin /full)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test: Endpoints Individuales'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explicación
            Card(
              color: Colors.purple[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.api, color: Colors.purple[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Test de Endpoints Individuales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Este test llama a cada endpoint por separado para ver exactamente qué datos devuelve cada uno.',
                      style: TextStyle(color: Colors.purple[700]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Lista de endpoints a probar
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
                    ..._endpoints.map((endpoint) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              endpoint['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              endpoint['url']!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              endpoint['description']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botón de test
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _testAllEndpoints,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  _loading
                      ? 'Probando endpoints...'
                      : 'Probar Todos los Endpoints',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Resultados
            if (_results.isNotEmpty) ...[
              const Text(
                'Resultados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ..._endpoints.map((endpoint) {
                final result = _results[endpoint['url']];
                if (result == null) return const SizedBox.shrink();

                final success = result['success'] as bool;
                final statusCode = result['statusCode'] as int?;
                final count = result['count'] as int?;
                final error = result['error'] as String?;
                final sampleData =
                    result['sampleData'] as Map<String, dynamic>?;
                final responseStructure =
                    result['responseStructure'] as String?;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Icon(
                              success ? Icons.check_circle : Icons.error,
                              color: success
                                  ? Colors.green[700]
                                  : Colors.red[700],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                endpoint['name']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: success
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                              ),
                            ),
                            if (statusCode != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: success
                                      ? Colors.green[100]
                                      : Colors.red[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'HTTP $statusCode',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: success
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // URL
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            endpoint['url']!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (success) ...[
                          // Información de éxito
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Datos Obtenidos:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (count != null)
                                  Text('📊 Total de registros: $count'),
                                if (responseStructure != null) ...[
                                  const SizedBox(height: 4),
                                  Text('🏗️ Estructura: $responseStructure'),
                                ],
                              ],
                            ),
                          ),

                          // Muestra de datos
                          if (sampleData != null) ...[
                            const SizedBox(height: 12),
                            ExpansionTile(
                              title: const Text('Muestra de Datos'),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Campos disponibles:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: sampleData.keys.map((key) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  key ==
                                                      'tipo_tab_envio_factura'
                                                  ? Colors.orange[100]
                                                  : Colors.blue[100],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              key,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color:
                                                    key ==
                                                        'tipo_tab_envio_factura'
                                                    ? Colors.orange[700]
                                                    : Colors.blue[700],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 12),

                                      // Campos importantes
                                      if (sampleData.containsKey('ENCF'))
                                        Text('🔑 ENCF: ${sampleData['ENCF']}'),
                                      if (sampleData.containsKey('encf'))
                                        Text('🔑 encf: ${sampleData['encf']}'),
                                      if (sampleData.containsKey(
                                        'tipo_tab_envio_factura',
                                      ))
                                        Text(
                                          '🏷️ tipo_tab_envio_factura: ${sampleData['tipo_tab_envio_factura']}',
                                        ),
                                      if (sampleData.containsKey('TipoECF'))
                                        Text(
                                          '📋 TipoECF: ${sampleData['TipoECF']}',
                                        ),
                                      if (sampleData.containsKey('tipoecf'))
                                        Text(
                                          '📋 tipoecf: ${sampleData['tipoecf']}',
                                        ),
                                      if (sampleData.containsKey(
                                        'RazonSocialComprador',
                                      ))
                                        Text(
                                          '👤 Cliente: ${sampleData['RazonSocialComprador']}',
                                        ),
                                      if (sampleData.containsKey(
                                        'razonsocialcomprador',
                                      ))
                                        Text(
                                          '👤 Cliente: ${sampleData['razonsocialcomprador']}',
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ] else ...[
                          // Información de error
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Error:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  error ?? 'Error desconocido',
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testAllEndpoints() async {
    setState(() {
      _loading = true;
      _results = {};
    });

    for (final endpoint in _endpoints) {
      final url = endpoint['url']!;

      try {
        print('🌐 Probando endpoint: $url');

        final response = await http
            .get(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 30));

        print('📡 Respuesta HTTP ${response.statusCode} para $url');

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);

          // Analizar estructura de respuesta
          String responseStructure = '';
          int count = 0;
          Map<String, dynamic>? sampleData;

          if (jsonData is List) {
            responseStructure = 'Array directo';
            count = jsonData.length;
            if (jsonData.isNotEmpty && jsonData.first is Map<String, dynamic>) {
              sampleData = jsonData.first;
            }
          } else if (jsonData is Map<String, dynamic>) {
            responseStructure =
                'Objeto con claves: ${jsonData.keys.join(', ')}';

            // Buscar arrays dentro del objeto
            for (final key in jsonData.keys) {
              if (jsonData[key] is List) {
                final list = jsonData[key] as List;
                count = list.length;
                responseStructure += ' (array en "$key")';
                if (list.isNotEmpty && list.first is Map<String, dynamic>) {
                  sampleData = list.first;
                }
                break;
              }
            }
          }

          print('✅ Éxito: $count registros, estructura: $responseStructure');

          _results[url] = {
            'success': true,
            'statusCode': response.statusCode,
            'count': count,
            'responseStructure': responseStructure,
            'sampleData': sampleData,
          };
        } else {
          print('❌ Error HTTP ${response.statusCode}');
          _results[url] = {
            'success': false,
            'statusCode': response.statusCode,
            'error': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          };
        }
      } catch (e) {
        print('💥 Excepción para $url: $e');
        _results[url] = {'success': false, 'error': e.toString()};
      }

      // Pequeña pausa entre requests
      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      _loading = false;
    });
  }
}
