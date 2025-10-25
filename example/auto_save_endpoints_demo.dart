import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../lib/screens/configuracion/configuracion_controller.dart';

/// Demo del guardado automático de endpoints
///
/// Características implementadas:
/// 1. ✅ Guardado automático con delay de 1 segundo
/// 2. ✅ TextField editables que funcionan correctamente
/// 3. ✅ Indicadores visuales de guardado
/// 4. ✅ Validación de nombres duplicados
/// 5. ✅ URLs completas generadas en tiempo real

class AutoSaveEndpointsDemoScreen extends StatelessWidget {
  const AutoSaveEndpointsDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo: Guardado Automático de Endpoints'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
      ),
      body: GetBuilder<ConfiguracionController>(
        init: ConfiguracionController(),
        builder: (controller) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instrucciones
                _InstructionsCard(),

                const SizedBox(height: 20),

                // Configuración URL Base
                _BaseUrlCard(controller: controller),

                const SizedBox(height: 20),

                // Endpoints configurados
                _EndpointsCard(controller: controller),

                const SizedBox(height: 20),

                // URLs generadas
                _GeneratedUrlsCard(controller: controller),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InstructionsCard extends StatelessWidget {
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
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Cómo Funciona el Guardado Automático',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _InstructionItem(
              icon: Icons.edit,
              text: 'Escribe en cualquier campo de endpoint',
            ),
            _InstructionItem(
              icon: Icons.timer,
              text: 'Espera 1 segundo después de dejar de escribir',
            ),
            _InstructionItem(
              icon: Icons.cloud_upload,
              text: 'Los cambios se guardan automáticamente en Firebase',
            ),
            _InstructionItem(
              icon: Icons.refresh,
              text: 'Las URLs completas se actualizan en tiempo real',
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.blue[600])),
          ),
        ],
      ),
    );
  }
}

class _BaseUrlCard extends StatelessWidget {
  final ConfiguracionController controller;
  const _BaseUrlCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'URL Base del ERP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: controller.baseERPUrlCtrl,
              decoration: InputDecoration(
                labelText: 'URL Base',
                hintText: 'http://137.184.7.44:3390/api',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.dns),
                suffixIcon: Icon(
                  Icons.auto_awesome,
                  color: Colors.green[600],
                  size: 20,
                ),
              ),
              onChanged: (value) {
                controller.baseERPUrl = value;
                controller.update();
                controller.saveEndpointsWithDelay();
              },
            ),

            const SizedBox(height: 8),
            Text(
              'Esta URL se combina con cada endpoint específico',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndpointsCard extends StatelessWidget {
  final ConfiguracionController controller;
  const _EndpointsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Endpoints Configurados',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showQuickAddDialog(context, controller),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    foregroundColor: Colors.green[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: Colors.green[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Los cambios se guardan automáticamente mientras escribes',
                      style: TextStyle(fontSize: 11, color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (controller.erpEndpoints.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No hay endpoints configurados\nAgrega algunos para probar el guardado automático',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...controller.erpEndpoints.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
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
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry.key.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () =>
                                controller.removeEndpoint(entry.key),
                            icon: const Icon(Icons.delete_outline, size: 16),
                            color: Colors.red[600],
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: controller.endpointControllers[entry.key],
                        decoration: InputDecoration(
                          labelText: 'Ruta del endpoint',
                          hintText: '/api/endpoint',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          isDense: true,
                          suffixIcon: Icon(
                            Icons.save_outlined,
                            size: 16,
                            color: Colors.green[600],
                          ),
                        ),
                        style: const TextStyle(fontSize: 12),
                        onChanged: (value) {
                          controller.updateEndpoint(entry.key, value);
                        },
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

  void _showQuickAddDialog(
    BuildContext context,
    ConfiguracionController controller,
  ) {
    final nameController = TextEditingController();
    final pathController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Agregar Endpoint Rápido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'ars, invoices, etc.',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pathController,
              decoration: const InputDecoration(
                labelText: 'Ruta',
                hintText: '/ars/full',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim().toLowerCase();
              final path = pathController.text.trim();

              if (name.isNotEmpty && path.isNotEmpty) {
                controller.addEndpoint(name, path);
                Get.back();

                Get.snackbar(
                  'Endpoint Agregado',
                  'Se guardó automáticamente: $name → $path',
                  backgroundColor: Colors.green[100],
                  colorText: Colors.green[700],
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

class _GeneratedUrlsCard extends StatelessWidget {
  final ConfiguracionController controller;
  const _GeneratedUrlsCard({required this.controller});

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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (controller.erpEndpoints.isEmpty)
              const Text(
                'Agrega endpoints para ver las URLs generadas',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...controller.erpEndpoints.keys.map((key) {
                final fullUrl = controller.getFullEndpointUrl(key);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.link, size: 14, color: Colors.green[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              fullUrl,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Simular copia al portapapeles
                              Get.snackbar(
                                'Copiado',
                                'URL copiada: $fullUrl',
                                duration: const Duration(seconds: 2),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            color: Colors.green[600],
                          ),
                        ],
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
