import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../lib/models/ui_types.dart';
import '../lib/screens/configuracion/configuracion_controller.dart';
import '../lib/services/invoice_service.dart';

/// Test específico para debuggear por qué solo se ven datos de ARS
class DebugInvoicesOnlyScreen extends StatefulWidget {
  const DebugInvoicesOnlyScreen({super.key});

  @override
  State<DebugInvoicesOnlyScreen> createState() =>
      _DebugInvoicesOnlyScreenState();
}

class _DebugInvoicesOnlyScreenState extends State<DebugInvoicesOnlyScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  bool _loading = false;
  String _debugLog = '';
  Map<String, dynamic> _results = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug: Solo ARS, no Invoices'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explicación del problema
            Card(
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bug_report, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Problema Detectado',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Solo se están mostrando datos del endpoint ARS, no del endpoint de invoices.',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Este test va a debuggear paso a paso qué está pasando.',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Configuración actual
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
                          'Configuración Actual',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('URL Base: ${controller.baseERPUrl}'),
                              const SizedBox(height: 8),
                              Text(
                                'Endpoints configurados: ${controller.erpEndpoints.length}',
                              ),
                              const SizedBox(height: 8),
                              ...controller.erpEndpoints.entries.map((entry) {
                                final fullUrl = controller.getFullEndpointUrl(
                                  entry.key,
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: entry.key == 'ars'
                                              ? Colors.green[100]
                                              : entry.key == 'invoices'
                                              ? Colors.blue[100]
                                              : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          entry.key.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: entry.key == 'ars'
                                                ? Colors.green[700]
                                                : entry.key == 'invoices'
                                                ? Colors.blue[700]
                                                : Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          fullUrl,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Configurar ambos endpoints
                              controller.baseERPUrl =
                                  'https://cempsavid.duckdns.org/api';
                              controller.baseERPUrlCtrl.text =
                                  controller.baseERPUrl;
                              controller.addEndpoint('ars', '/ars/full');
                              controller.addEndpoint(
                                'invoices',
                                '/invoices/full',
                              );
                              controller.update();

                              Get.snackbar(
                                'Configurado',
                                'Endpoints ARS + Invoices configurados',
                                backgroundColor: Colors.green[100],
                                colorText: Colors.green[700],
                              );
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('Configurar Ambos Endpoints'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                              foregroundColor: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Test de debug
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Debug Test',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _runDebugTest,
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
                          _loading ? 'Debuggeando...' : 'Ejecutar Debug Test',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
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
                            tooltip: 'Limpiar log',
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

            // Resultados del debug
            if (_results.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resultados del Debug',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Resumen de endpoints
                      if (_results.containsKey('endpoints'))
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Endpoints Llamados:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...(_results['endpoints'] as List<String>).map((
                                url,
                              ) {
                                return Text('• $url');
                              }),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Resultados por endpoint
                      if (_results.containsKey('endpointResults'))
                        ...(_results['endpointResults'] as Map<String, dynamic>)
                            .entries
                            .map((entry) {
                              final url = entry.key;
                              final result =
                                  entry.value as Map<String, dynamic>;
                              final success = result['success'] as bool;
                              final count = result['count'] as int;
                              final error = result['error'] as String?;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: success
                                      ? Colors.green[50]
                                      : Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: success
                                        ? Colors.green[200]!
                                        : Colors.red[200]!,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          success
                                              ? Icons.check_circle
                                              : Icons.error,
                                          color: success
                                              ? Colors.green[700]
                                              : Colors.red[700],
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            url.contains('ars')
                                                ? 'ARS Endpoint'
                                                : 'Invoices Endpoint',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: success
                                                  ? Colors.green[700]
                                                  : Colors.red[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      url,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    if (success) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Facturas obtenidas: $count',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ] else if (error != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Error: $error',
                                        style: TextStyle(
                                          color: Colors.red[700],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),

                      const SizedBox(height: 12),

                      // Resumen final
                      if (_results.containsKey('totalInvoices'))
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resumen Final:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total facturas combinadas: ${_results['totalInvoices']}',
                              ),
                              Text(
                                'Con tipo_tab_envio_factura: ${_results['withTabType']}',
                              ),
                              Text(
                                'Sin tipo_tab_envio_factura: ${_results['withoutTabType']}',
                              ),
                            ],
                          ),
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

  Future<void> _runDebugTest() async {
    setState(() {
      _loading = true;
      _debugLog = '';
      _results = {};
    });

    _addToLog('🔍 INICIANDO DEBUG TEST...');
    _addToLog('');

    try {
      // Paso 1: Verificar configuración
      _addToLog('📋 PASO 1: Verificando configuración...');

      final controller = Get.find<ConfiguracionController>();
      _addToLog('   Base URL: ${controller.baseERPUrl}');
      _addToLog('   Endpoints configurados: ${controller.erpEndpoints.length}');

      final endpoints = <String>[];
      for (final entry in controller.erpEndpoints.entries) {
        final url = controller.getFullEndpointUrl(entry.key);
        endpoints.add(url);
        _addToLog('   • ${entry.key}: $url');
      }

      _results['endpoints'] = endpoints;

      if (endpoints.isEmpty) {
        _addToLog('❌ ERROR: No hay endpoints configurados');
        return;
      }

      _addToLog('');

      // Paso 2: Llamar a cada endpoint individualmente
      _addToLog('🌐 PASO 2: Llamando a cada endpoint individualmente...');

      final endpointResults = <String, Map<String, dynamic>>{};

      for (final url in endpoints) {
        _addToLog('');
        _addToLog('   Llamando a: $url');

        try {
          final invoices = await _invoiceService.fetchInvoices(
            InvoiceCategory.todos,
            forceReal: true,
          );

          _addToLog('   ✅ ÉXITO: ${invoices.length} facturas obtenidas');

          final withTabType = invoices
              .where((inv) => inv.tipoTabEnvioFactura != null)
              .length;
          final withoutTabType = invoices.length - withTabType;

          _addToLog('   📊 Con tipo_tab_envio_factura: $withTabType');
          _addToLog('   📊 Sin tipo_tab_envio_factura: $withoutTabType');

          endpointResults[url] = {
            'success': true,
            'count': invoices.length,
            'withTabType': withTabType,
            'withoutTabType': withoutTabType,
          };

          // Mostrar muestra de datos
          if (invoices.isNotEmpty) {
            final sample = invoices.first;
            _addToLog('   📄 Muestra - ENCF: ${sample.encf}');
            _addToLog(
              '   📄 Muestra - Cliente: ${sample.razonsocialcomprador}',
            );
            _addToLog(
              '   📄 Muestra - Tipo Tab: ${sample.tipoTabEnvioFactura ?? "NULL"}',
            );
          }
        } catch (e) {
          _addToLog('   ❌ ERROR: $e');
          endpointResults[url] = {
            'success': false,
            'count': 0,
            'error': e.toString(),
          };
        }
      }

      _results['endpointResults'] = endpointResults;

      _addToLog('');

      // Paso 3: Análisis de resultados
      _addToLog('📊 PASO 3: Análisis de resultados...');

      final successfulEndpoints = endpointResults.values
          .where((r) => r['success'] == true)
          .length;
      final totalInvoices = endpointResults.values
          .where((r) => r['success'] == true)
          .fold<int>(0, (sum, r) => sum + (r['count'] as int));

      _addToLog(
        '   Endpoints exitosos: $successfulEndpoints/${endpoints.length}',
      );
      _addToLog('   Total facturas: $totalInvoices');

      if (successfulEndpoints == 0) {
        _addToLog('   ❌ PROBLEMA: Ningún endpoint funcionó');
      } else if (successfulEndpoints == 1) {
        _addToLog('   ⚠️  PROBLEMA: Solo 1 endpoint funcionó');
        final workingEndpoint = endpointResults.entries.firstWhere(
          (e) => e.value['success'] == true,
        );
        _addToLog('   ⚠️  Endpoint funcionando: ${workingEndpoint.key}');
      } else {
        _addToLog('   ✅ BIEN: Múltiples endpoints funcionando');
      }

      _results['totalInvoices'] = totalInvoices;
      _results['successfulEndpoints'] = successfulEndpoints;

      _addToLog('');
      _addToLog('🏁 DEBUG TEST COMPLETADO');
    } catch (e) {
      _addToLog('');
      _addToLog('💥 ERROR GENERAL: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _addToLog(String message) {
    setState(() {
      _debugLog += '$message\n';
    });
  }
}
