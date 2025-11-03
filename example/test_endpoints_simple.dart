import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../lib/screens/configuracion/configuracion_controller.dart';

/// Test simple para verificar que los endpoints se muestren correctamente
class TestEndpointsSimpleScreen extends StatelessWidget {
  const TestEndpointsSimpleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test: Endpoints Configuración'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
      ),
      body: GetBuilder<ConfiguracionController>(
        init: ConfiguracionController(),
        builder: (controller) {
          if (controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Estado actual
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estado de Configuración:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Company RNC: ${controller.companyRnc ?? "No configurado"}',
                        ),
                        Text('Base ERP URL: ${controller.baseERPUrl}'),
                        Text(
                          'Endpoints configurados: ${controller.erpEndpoints.length}',
                        ),
                        Text('Error: ${controller.errorMessage ?? "Ninguno"}'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // URL Base
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'URL Base del ERP:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: controller.baseERPUrlCtrl,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'https://cempsavid.duckdns.org/api',
                          ),
                          onChanged: (value) {
                            controller.baseERPUrl = value;
                            controller.update();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Endpoints configurados
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Endpoints Configurados:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () => _addTestEndpoint(controller),
                              child: const Text('Agregar Test'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (controller.erpEndpoints.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'No hay endpoints configurados',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ...controller.erpEndpoints.entries.map((entry) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
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
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          entry.key.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () => controller
                                            .removeEndpoint(entry.key),
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 16,
                                        ),
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ruta: ${entry.value}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'URL Completa: ${controller.getFullEndpointUrl(entry.key)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                        color: Colors.green[700],
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
                ),

                const SizedBox(height: 16),

                // Botón de guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.loading
                        ? null
                        : () {
                            controller.saveConfiguration();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005285),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: controller.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Guardar Configuración'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _addTestEndpoint(ConfiguracionController controller) {
    // Agregar algunos endpoints de prueba
    controller.addEndpoint('ars', '/ars/full');
    controller.addEndpoint('invoices', '/invoices/full');
    controller.addEndpoint('clients', '/clients');

    Get.snackbar(
      'Endpoints Agregados',
      'Se agregaron 3 endpoints de prueba',
      backgroundColor: Colors.green[100],
      colorText: Colors.green[700],
    );
  }
}
