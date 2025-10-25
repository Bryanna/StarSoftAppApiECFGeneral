import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../lib/screens/configuracion/configuracion_controller.dart';
import '../lib/controllers/dynamic_home_controller.dart';

/// Test que muestra cómo se usan AMBOS endpoints configurados
class TestBothEndpointsScreen extends StatelessWidget {
  const TestBothEndpointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test: Ambos Endpoints'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configuración de endpoints
            _EndpointsConfigurationCard(),

            const SizedBox(height: 16),

            // Test de carga de datos
            _DataLoadingTestCard(),

            const SizedBox(height: 16),

            // Resultados
            _ResultsCard(),
          ],
        ),
      ),
    );
  }
}

class _EndpointsConfigurationCard extends StatelessWidget {
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

                // URL Base
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
                        'URL Base del ERP:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.baseERPUrl.isEmpty
                            ? 'No configurada'
                            : controller.baseERPUrl,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Endpoints configurados
                const Text(
                  'Endpoints Configurados:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),

                if (controller.erpEndpoints.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: const Text(
                      'No hay endpoints configurados',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                else
                  ...controller.erpEndpoints.entries.map((entry) {
                    final fullUrl = controller.getFullEndpointUrl(entry.key);
                    final isARS = entry.key.toLowerCase().contains('ars');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isARS ? Colors.green[50] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isARS ? Colors.green[200]! : Colors.blue[200]!,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isARS
                                      ? Colors.green[100]
                                      : Colors.blue[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  entry.key.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isARS
                                        ? Colors.green[700]
                                        : Colors.blue[700],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isARS)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'PRIORIDAD',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ruta: ${entry.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'URL Completa: $fullUrl',
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: isARS
                                  ? Colors.green[700]
                                  : Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 16),

                // Botón para configurar endpoints
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Configurar ambos endpoints
                      controller.baseERPUrl = 'http://137.184.7.44:3390/api';
                      controller.baseERPUrlCtrl.text = controller.baseERPUrl;

                      // Agregar endpoint ARS (prioridad 1)
                      controller.addEndpoint('ars', '/ars/full');

                      // Agregar endpoint ARS alternativo (prioridad 2)
                      controller.addEndpoint('ars_alt', '/ars/full');

                      // Agregar otros endpoints
                      controller.addEndpoint('invoices', '/invoices/full');
                      controller.addEndpoint('clients', '/clients');

                      controller.update();

                      Get.snackbar(
                        'Endpoints Configurados',
                        'Se configuraron ${controller.erpEndpoints.length} endpoints',
                        backgroundColor: Colors.green[100],
                        colorText: Colors.green[700],
                      );
                    },
                    icon: const Icon(Icons.auto_fix_high),
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
    );
  }
}

class _DataLoadingTestCard extends StatelessWidget {
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
                    Icon(Icons.cloud_download, color: Colors.purple[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Test de Carga de Datos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Información sobre prioridad de endpoints
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orden de Prioridad de Endpoints:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. ars → /ars/full (PRINCIPAL)',
                        style: TextStyle(color: Colors.orange[600]),
                      ),
                      Text(
                        '2. ars_alt → /ars/full (ALTERNATIVO)',
                        style: TextStyle(color: Colors.orange[600]),
                      ),
                      Text(
                        '3. invoices → /invoices (FALLBACK)',
                        style: TextStyle(color: Colors.orange[600]),
                      ),
                      Text(
                        '4. Primer endpoint disponible',
                        style: TextStyle(color: Colors.orange[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Botones de test
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.loading
                            ? null
                            : () {
                                controller.loadFromRealEndpoint();
                              },
                        icon: const Icon(Icons.cloud_download),
                        label: const Text(
                          'Cargar desde Endpoint Real (Prioridad ARS)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005285),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.loading
                            ? null
                            : () {
                                controller.refresh();
                              },
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          'Cargar Normal (según configuración)',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResultsCard extends StatelessWidget {
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
                    Icon(Icons.analytics, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Resultados de la Carga',
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
                        'No hay datos cargados.\nConfigura los endpoints y haz clic en "Cargar desde Endpoint Real".',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else ...[
                  // Resumen
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
                          'Datos Cargados Exitosamente:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '📊 Total facturas: ${controller.allInvoices.length}',
                        ),
                        Text(
                          '🏷️ Tabs generados: ${controller.dynamicTabs.length}',
                        ),
                        Text(
                          '🔖 Con tipo_tab_envio_factura: ${controller.allInvoices.where((inv) => inv.tipoTabEnvioFactura != null).length}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tipos de tab encontrados
                  if (controller.allInvoices.any(
                    (inv) => inv.tipoTabEnvioFactura != null,
                  ))
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
                            'Tipos de Tab Encontrados en el Response:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...controller.allInvoices
                              .where((inv) => inv.tipoTabEnvioFactura != null)
                              .map((inv) => inv.tipoTabEnvioFactura!)
                              .toSet()
                              .map(
                                (tipo) => Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '📋 "$tipo"',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
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
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tabs Dinámicos Generados:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...controller.dynamicTabs.map(
                            (tab) => Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${tab.icon} ${tab.label} (${tab.count})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple[700],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
