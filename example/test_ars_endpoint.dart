import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../lib/controllers/dynamic_home_controller.dart';
import '../lib/screens/configuracion/configuracion_controller.dart';

/// Test específico para el endpoint de ARS
class TestARSEndpointScreen extends StatelessWidget {
  const TestARSEndpointScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test: Endpoint ARS'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configuración del endpoint ARS
            _ARSConfigurationCard(),

            const SizedBox(height: 16),

            // Test de conexión
            _ARSConnectionTestCard(),

            const SizedBox(height: 16),

            // Datos cargados
            _ARSDataCard(),
          ],
        ),
      ),
    );
  }
}

class _ARSConfigurationCard extends StatelessWidget {
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
                    Icon(Icons.settings, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Configuración Endpoint ARS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // URL Base actual
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
                        'URL Base Actual:',
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

                // URL del endpoint ARS
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'URL Endpoint ARS:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.getFullEndpointUrl('ars'),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Configurar manualmente el endpoint de ARS
                        controller.baseERPUrl =
                            'https://cempsavid.duckdns.org/api';
                        controller.baseERPUrlCtrl.text = controller.baseERPUrl;
                        controller.addEndpoint('ars', '/ars/full');
                        controller.addEndpoint('ars_alt', '/ars/full');
                        controller.update();

                        Get.snackbar(
                          'ARS Configurado',
                          'Endpoint de ARS configurado: ${controller.getFullEndpointUrl('ars')}',
                          backgroundColor: Colors.green[100],
                          colorText: Colors.green[700],
                        );
                      },
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text('Auto-Configurar ARS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[100],
                        foregroundColor: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => controller.saveConfiguration(),
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[100],
                        foregroundColor: Colors.green[700],
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

class _ARSConnectionTestCard extends StatelessWidget {
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
                    Icon(Icons.wifi_tethering, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Test de Conexión',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Estado de la conexión
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
                              : Icons.check_circle_outline,
                          color: controller.hasConnectionError
                              ? Colors.red[700]
                              : Colors.green[700],
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.loading
                              ? 'Conectando al endpoint ARS...'
                              : controller.hasConnectionError
                              ? 'Error: ${controller.errorMessage ?? "No se pudo conectar"}'
                              : 'Conectado correctamente - ${controller.allInvoices.length} facturas cargadas',
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
                        label: const Text('Cargar desde Endpoint Real ARS'),
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
                          'Cargar Datos Normales (según config)',
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

class _ARSDataCard extends StatelessWidget {
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
                    Icon(Icons.data_usage, color: Colors.purple[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Datos del Endpoint ARS',
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
                        'No hay datos cargados.\nHaz clic en "Probar Conexión" para cargar datos del endpoint ARS.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else ...[
                  // Resumen de datos
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
                          'Resumen de Datos:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total facturas: ${controller.allInvoices.length}',
                        ),
                        Text(
                          'Tabs generados: ${controller.dynamicTabs.length}',
                        ),
                        Text(
                          'Facturas con tipo_tab_envio_factura: ${controller.allInvoices.where((inv) => inv.tipoTabEnvioFactura != null).length}',
                        ),
                        const SizedBox(height: 8),
                        if (controller.allInvoices.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tipos de Tab encontrados:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                                ...controller.allInvoices
                                    .where(
                                      (inv) => inv.tipoTabEnvioFactura != null,
                                    )
                                    .map((inv) => inv.tipoTabEnvioFactura!)
                                    .toSet()
                                    .map(
                                      (tipo) => Text(
                                        '• $tipo',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange[600],
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Muestra de facturas ARS
                  const Text(
                    'Muestra de Facturas (primeras 3):',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),

                  ...controller.allInvoices.take(3).map((invoice) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ENCF: ${invoice.encf ?? "N/A"}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Tipo Tab: ${invoice.tipoTabEnvioFactura}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[700],
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
