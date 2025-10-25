import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../lib/screens/configuracion/configuracion_controller.dart';

/// Ejemplo de uso de la nueva configuración de endpoints ERP
///
/// Esta configuración permite:
/// 1. Definir una URL base para el ERP (ej: http://137.184.7.44:3390/api)
/// 2. Configurar endpoints específicos (ej: /ars/full, /invoices, /clients)
/// 3. Obtener URLs completas combinando base + endpoint
///
/// Ejemplo de configuración:
/// - URL Base: http://137.184.7.44:3390/api
/// - Endpoints:
///   - ars: /ars/full → http://137.184.7.44:3390/api/ars/full
///   - ars_alt: /ars/full → http://137.184.7.44:3390/api/ars/full
///   - invoices: /invoices → http://137.184.7.44:3390/api/invoices
///   - clients: /clients → http://137.184.7.44:3390/api/clients
///   - products: /products → http://137.184.7.44:3390/api/products

class ERPEndpointsUsageExample extends StatelessWidget {
  const ERPEndpointsUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplo: Configuración ERP Endpoints')),
      body: GetBuilder<ConfiguracionController>(
        init: ConfiguracionController(),
        builder: (controller) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Configuración actual
                _ConfigurationDisplay(controller: controller),

                const SizedBox(height: 24),

                // Ejemplos de uso
                _UsageExamples(controller: controller),

                const SizedBox(height: 24),

                // Botones de prueba
                _TestButtons(controller: controller),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ConfigurationDisplay extends StatelessWidget {
  final ConfiguracionController controller;
  const _ConfigurationDisplay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración Actual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // URL Base
            _InfoRow(
              label: 'URL Base ERP:',
              value: controller.baseERPUrl,
              icon: Icons.dns,
            ),

            const SizedBox(height: 12),

            // Endpoints configurados
            const Text(
              'Endpoints Configurados:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            if (controller.erpEndpoints.isEmpty)
              const Text(
                'No hay endpoints configurados',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...controller.erpEndpoints.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _InfoRow(
                    label: '${entry.key}:',
                    value: entry.value,
                    icon: Icons.api,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _UsageExamples extends StatelessWidget {
  final ConfiguracionController controller;
  const _UsageExamples({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'URLs Completas Generadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (controller.erpEndpoints.isEmpty)
              const Text(
                'Configura endpoints para ver las URLs generadas',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...controller.erpEndpoints.keys.map((key) {
                final fullUrl = controller.getFullEndpointUrl(key);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fullUrl,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _TestButtons extends StatelessWidget {
  final ConfiguracionController controller;
  const _TestButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones de Prueba',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _addSampleEndpoints(controller),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Endpoints de Ejemplo'),
                ),

                ElevatedButton.icon(
                  onPressed: () => _clearEndpoints(controller),
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar Endpoints'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade700,
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () => _testEndpoint(controller, 'ars'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Probar Endpoint ARS'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addSampleEndpoints(ConfiguracionController controller) {
    // Configurar URL base
    controller.baseERPUrlCtrl.text = 'http://137.184.7.44:3390/api';
    controller.baseERPUrl = 'http://137.184.7.44:3390/api';

    // Agregar endpoints de ejemplo
    controller.addEndpoint('ars', '/ars/full');
    controller.addEndpoint('ars_alt', '/ars/full');
    controller.addEndpoint('invoices', '/invoices');
    controller.addEndpoint('clients', '/clients');
    controller.addEndpoint('products', '/products');

    Get.snackbar(
      'Endpoints Agregados',
      'Se agregaron endpoints de ejemplo',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade700,
    );
  }

  void _clearEndpoints(ConfiguracionController controller) {
    final keys = List<String>.from(controller.erpEndpoints.keys);
    for (final key in keys) {
      controller.removeEndpoint(key);
    }

    Get.snackbar(
      'Endpoints Eliminados',
      'Se eliminaron todos los endpoints',
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade700,
    );
  }

  void _testEndpoint(ConfiguracionController controller, String endpointKey) {
    final url = controller.getFullEndpointUrl(endpointKey);

    Get.dialog(
      AlertDialog(
        title: Text('Endpoint: $endpointKey'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('URL Completa:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(url, style: const TextStyle(fontFamily: 'monospace')),
            ),
            const SizedBox(height: 16),
            const Text(
              'En una implementación real, aquí harías una petición HTTP a esta URL.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.blue.shade600),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }
}
