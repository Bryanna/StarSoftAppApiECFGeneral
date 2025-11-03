import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../lib/controllers/dynamic_home_controller.dart';
import '../lib/screens/configuracion/configuracion_controller.dart';

/// Test de debug para verificar que se llamen AMBOS endpoints
class TestDebugEndpointsScreen extends StatelessWidget {
  const TestDebugEndpointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug: Verificar Endpoints'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configuración clara
            _EndpointsSetupCard(),

            const SizedBox(height: 16),

            // Test con debug
            _DebugTestCard(),

            const SizedBox(height: 16),

            // Instrucciones
            _InstructionsCard(),
          ],
        ),
      ),
    );
  }
}

class _EndpointsSetupCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConfiguracionController>(
      init: ConfiguracionController(),
      builder: (controller) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.settings_ethernet, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Configuración de Endpoints',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // URLs que se van a configurar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Endpoints que se configurarán:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 8),

                      _EndpointInfo(
                        name: 'ARS',
                        baseUrl: 'https://cempsavid.duckdns.org/api',
                        path: '/ars/full',
                        fullUrl: 'https://cempsavid.duckdns.org/api/ars/full',
                        description:
                            'Datos de facturas ARS con tipo_tab_envio_factura',
                      ),

                      const SizedBox(height: 8),

                      _EndpointInfo(
                        name: 'INVOICES',
                        baseUrl: 'https://cempsavid.duckdns.org/api',
                        path: '/invoices/full',
                        fullUrl:
                            'https://cempsavid.duckdns.org/api/invoices/full',
                        description: 'Datos de facturas generales',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Estado actual
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estado Actual:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('URL Base: ${controller.baseERPUrl}'),
                      Text(
                        'Endpoints configurados: ${controller.erpEndpoints.length}',
                      ),
                      if (controller.erpEndpoints.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...controller.erpEndpoints.entries.map((entry) {
                          return Text(
                            '• ${entry.key}: ${entry.value} → ${controller.getFullEndpointUrl(entry.key)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Botón de configuración
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Configurar URL base
                      controller.baseERPUrl =
                          'https://cempsavid.duckdns.org/api';
                      controller.baseERPUrlCtrl.text = controller.baseERPUrl;

                      // Limpiar endpoints existentes
                      final keysToRemove = List<String>.from(
                        controller.erpEndpoints.keys,
                      );
                      for (final key in keysToRemove) {
                        controller.removeEndpoint(key);
                      }

                      // Configurar EXACTAMENTE los 2 endpoints que queremos
                      controller.addEndpoint('ars', '/ars/full');
                      controller.addEndpoint('invoices', '/invoices/full');

                      controller.update();

                      Get.snackbar(
                        'Endpoints Configurados',
                        'ARS (/ars/full) + INVOICES (/invoices/full) configurados',
                        backgroundColor: Colors.green[100],
                        colorText: Colors.green[700],
                        duration: const Duration(seconds: 3),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('Configurar ARS + INVOICES/FULL'),
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
    );
  }
}

class _EndpointInfo extends StatelessWidget {
  final String name;
  final String baseUrl;
  final String path;
  final String fullUrl;
  final String description;

  const _EndpointInfo({
    required this.name,
    required this.baseUrl,
    required this.path,
    required this.fullUrl,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(description, style: const TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Base: $baseUrl',
            style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
          ),
          Text(
            'Path: $path',
            style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
          ),
          Text(
            'Full: $fullUrl',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _DebugTestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DynamicHomeController>(
      init: DynamicHomeController(),
      builder: (controller) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.bug_report, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Test con Debug Detallado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Estado de la carga
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: controller.loading
                        ? Colors.blue[50]
                        : controller.hasConnectionError
                        ? Colors.red[50]
                        : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: controller.loading
                          ? Colors.blue[200]!
                          : controller.hasConnectionError
                          ? Colors.red[200]!
                          : Colors.green[200]!,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (controller.loading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(
                              controller.hasConnectionError
                                  ? Icons.error_outline
                                  : Icons.check_circle_outline,
                              color: controller.hasConnectionError
                                  ? Colors.red[700]
                                  : Colors.green[700],
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.loading
                                  ? 'Llamando a ambos endpoints...'
                                  : controller.hasConnectionError
                                  ? 'Error en la combinación'
                                  : 'Endpoints combinados exitosamente',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: controller.loading
                                    ? Colors.blue[700]
                                    : controller.hasConnectionError
                                    ? Colors.red[700]
                                    : Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (!controller.loading &&
                          !controller.hasConnectionError &&
                          controller.allInvoices.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Resultados:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          '• Total facturas: ${controller.allInvoices.length}',
                        ),
                        Text(
                          '• Con tipo_tab_envio_factura: ${controller.allInvoices.where((inv) => inv.tipoTabEnvioFactura != null).length}',
                        ),
                        Text(
                          '• Sin tipo_tab_envio_factura: ${controller.allInvoices.where((inv) => inv.tipoTabEnvioFactura == null).length}',
                        ),
                        Text(
                          '• Tabs generados: ${controller.dynamicTabs.length}',
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Botón de test
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.loading
                        ? null
                        : () {
                            controller.loadFromRealEndpoint();
                          },
                    icon: const Icon(Icons.cloud_download),
                    label: const Text('LLAMAR A AMBOS ENDPOINTS (con debug)'),
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
      },
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'Instrucciones para Debug',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'Para verificar que se llamen ambos endpoints:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 8),

            _InstructionStep(
              number: '1',
              text: 'Haz clic en "Configurar ARS + INVOICES/FULL"',
            ),
            _InstructionStep(
              number: '2',
              text: 'Haz clic en "LLAMAR A AMBOS ENDPOINTS"',
            ),
            _InstructionStep(
              number: '3',
              text: 'Abre la consola de debug (F12 en navegador)',
            ),
            _InstructionStep(
              number: '4',
              text: 'Busca los logs que empiecen con "🔗" y "✅"',
            ),
            _InstructionStep(
              number: '5',
              text: 'Verifica que aparezcan AMBAS URLs llamadas',
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Deberías ver en la consola:\n'
                '🔗 Endpoint 1: https://cempsavid.duckdns.org/api/ars/full\n'
                '🔗 Endpoint 2: https://cempsavid.duckdns.org/api/invoices/full\n'
                '✅ ÉXITO - Endpoint: [cada URL]\n'
                '✅ Facturas obtenidas: [número]',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Colors.orange[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String number;
  final String text;

  const _InstructionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.orange[600],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.orange[700])),
          ),
        ],
      ),
    );
  }
}
