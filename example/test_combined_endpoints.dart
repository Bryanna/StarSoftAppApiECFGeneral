import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../lib/screens/configuracion/configuracion_controller.dart';
import '../lib/controllers/dynamic_home_controller.dart';

/// Test que demuestra la combinación de datos de múltiples endpoints
class TestCombinedEndpointsScreen extends StatelessWidget {
  const TestCombinedEndpointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test: Endpoints Combinados'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explicación
            _ExplanationCard(),

            const SizedBox(height: 16),

            // Configuración
            _ConfigurationCard(),

            const SizedBox(height: 16),

            // Test de combinación
            _CombinationTestCard(),

            const SizedBox(height: 16),

            // Resultados combinados
            _CombinedResultsCard(),
          ],
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.merge_type, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Combinación de Endpoints',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'Este test demuestra cómo el sistema combina datos de múltiples endpoints:',
              style: TextStyle(color: Colors.blue[700]),
            ),
            const SizedBox(height: 8),

            _ExplanationStep(
              number: '1',
              title: 'Endpoint ARS',
              description: 'http://137.184.7.44:3390/api/ars/full',
              subtitle: 'Datos de facturas ARS con tipo_tab_envio_factura',
            ),
            _ExplanationStep(
              number: '2',
              title: 'Endpoint Invoices',
              description: 'http://137.184.7.44:3390/api/invoices',
              subtitle: 'Datos de facturas generales',
            ),
            _ExplanationStep(
              number: '3',
              title: 'Combinación',
              description: 'Se combinan ambos resultados',
              subtitle: 'Se eliminan duplicados por ENCF',
            ),
            _ExplanationStep(
              number: '4',
              title: 'Tabs Dinámicos',
              description: 'Se generan tabs basados en todos los datos',
              subtitle: 'Incluye datos de ambos endpoints',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExplanationStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final String subtitle;

  const _ExplanationStep({
    required this.number,
    required this.title,
    required this.description,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.blue[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigurationCard extends StatelessWidget {
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
                    Icon(Icons.settings, color: Colors.green[700]),
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
                      Text(
                        'Estado Actual:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
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
                            '• ${entry.key}: ${controller.getFullEndpointUrl(entry.key)}',
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

                // Botón para configurar ambos endpoints
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Configurar URL base
                      controller.baseERPUrl = 'http://137.184.7.44:3390/api';
                      controller.baseERPUrlCtrl.text = controller.baseERPUrl;

                      // Configurar ambos endpoints
                      controller.addEndpoint('ars', '/ars/full');
                      controller.addEndpoint('invoices', '/invoices/full');

                      // Opcional: agregar más endpoints
                      controller.addEndpoint('clients', '/clients');

                      controller.update();

                      Get.snackbar(
                        'Endpoints Configurados',
                        'ARS + Invoices + Clients configurados para combinación',
                        backgroundColor: Colors.green[100],
                        colorText: Colors.green[700],
                      );
                    },
                    icon: const Icon(Icons.merge_type),
                    label: const Text('Configurar Endpoints para Combinación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[100],
                      foregroundColor: Colors.green[700],
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

class _CombinationTestCard extends StatelessWidget {
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
                    Icon(Icons.call_merge, color: Colors.purple[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Test de Combinación',
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
                  child: Row(
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
                              : Icons.merge_type,
                          color: controller.hasConnectionError
                              ? Colors.red[700]
                              : Colors.green[700],
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.loading
                              ? 'Combinando datos de múltiples endpoints...'
                              : controller.hasConnectionError
                              ? 'Error: ${controller.errorMessage ?? "No se pudo combinar datos"}'
                              : 'Datos combinados exitosamente - ${controller.allInvoices.length} facturas totales',
                          style: TextStyle(
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
                    icon: const Icon(Icons.call_merge),
                    label: const Text('Combinar Datos de Todos los Endpoints'),
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

class _CombinedResultsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DynamicHomeController>(
      builder: (controller) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Resultados Combinados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (controller.loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (controller.allInvoices.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'No hay datos combinados.\nConfigura los endpoints y haz clic en "Combinar Datos".',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else ...[
                  // Estadísticas de combinación
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
                          'Estadísticas de Combinación:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '🔢 Total facturas combinadas: ${controller.allInvoices.length}',
                        ),
                        Text(
                          '🏷️ Tabs dinámicos generados: ${controller.dynamicTabs.length}',
                        ),
                        Text(
                          '📋 Con tipo_tab_envio_factura: ${controller.allInvoices.where((inv) => inv.tipoTabEnvioFactura != null).length}',
                        ),
                        Text(
                          '🔗 Sin tipo_tab_envio_factura: ${controller.allInvoices.where((inv) => inv.tipoTabEnvioFactura == null).length}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Análisis por fuente de datos
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
                          'Análisis por Fuente de Datos:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Facturas que probablemente vienen de ARS (tienen tipoTabEnvioFactura)
                        Text(
                          '🏥 Probablemente de ARS: ${controller.allInvoices.where((inv) => inv.tipoTabEnvioFactura != null).length}',
                          style: TextStyle(color: Colors.blue[600]),
                        ),

                        // Facturas que probablemente vienen de Invoices (no tienen tipoTabEnvioFactura)
                        Text(
                          '📄 Probablemente de Invoices: ${controller.allInvoices.where((inv) => inv.tipoTabEnvioFactura == null).length}',
                          style: TextStyle(color: Colors.blue[600]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tabs generados
                  if (controller.dynamicTabs.isNotEmpty)
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
                            'Tabs Dinámicos de Datos Combinados:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: controller.dynamicTabs
                                .map(
                                  (tab) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${tab.icon} ${tab.label} (${tab.count})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Muestra de facturas combinadas
                  const Text(
                    'Muestra de Facturas Combinadas (primeras 5):',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),

                  ...controller.allInvoices.take(5).map((invoice) {
                    final isFromARS = invoice.tipoTabEnvioFactura != null;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isFromARS
                              ? Colors.green[300]!
                              : Colors.blue[300]!,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: isFromARS ? Colors.green[50] : Colors.blue[50],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isFromARS
                                      ? Colors.green[100]
                                      : Colors.blue[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isFromARS ? 'ARS' : 'INVOICES',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: isFromARS
                                        ? Colors.green[700]
                                        : Colors.blue[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ENCF: ${invoice.encf ?? "N/A"}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Cliente: ${invoice.razonsocialcomprador ?? "N/A"}',
                          ),
                          Text('Tipo ECF: ${invoice.tipoecf ?? "N/A"}'),
                          if (invoice.tipoTabEnvioFactura != null)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Tipo Tab: ${invoice.tipoTabEnvioFactura}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
