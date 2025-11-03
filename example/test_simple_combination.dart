import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../lib/controllers/dynamic_home_controller.dart';
import '../lib/screens/configuracion/configuracion_controller.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Test Simple Combination',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const TestSimpleCombinationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Test simple para verificar que ambos endpoints se combinen correctamente
class TestSimpleCombinationScreen extends StatelessWidget {
  const TestSimpleCombinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test: Combinación Simple'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explicación
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Problema a Resolver',
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
                      'Solo se ven datos de ARS, no de invoices. Ambos endpoints devuelven la misma estructura pero con diferentes valores en tipo_tab_envio_factura:',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• /ars/full → "tipo_tab_envio_factura": "FacturaArs"',
                          ),
                          Text(
                            '• /invoices/full → "tipo_tab_envio_factura": "FacturaPaciente"',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Configuración
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
                          'Paso 1: Configurar Ambos Endpoints',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

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
                              Text('Base URL: ${controller.baseERPUrl}'),
                              Text(
                                'Endpoints: ${controller.erpEndpoints.length}',
                              ),
                              const SizedBox(height: 8),
                              ...controller.erpEndpoints.entries.map((entry) {
                                final fullUrl = controller.getFullEndpointUrl(
                                  entry.key,
                                );
                                return Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: entry.key == 'ars'
                                            ? Colors.green[100]
                                            : Colors.blue[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        entry.key.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: entry.key == 'ars'
                                              ? Colors.green[700]
                                              : Colors.blue[700],
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
                              // Configurar exactamente los 2 endpoints que mencionas
                              controller.baseERPUrl =
                                  'https://cempsavid.duckdns.org/api';
                              controller.baseERPUrlCtrl.text =
                                  controller.baseERPUrl;

                              // Limpiar endpoints existentes
                              controller.erpEndpoints.clear();

                              // Agregar exactamente los 2 endpoints
                              controller.addEndpoint('ars', '/ars/full');
                              controller.addEndpoint(
                                'invoices',
                                '/invoices/full',
                              );

                              controller.update();

                              Get.snackbar(
                                'Configurado',
                                'Configurados 2 endpoints: ARS + Invoices',
                                backgroundColor: Colors.green[100],
                                colorText: Colors.green[700],
                              );
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('Configurar 2 Endpoints'),
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
            ),

            const SizedBox(height: 16),

            // Test de combinación
            GetBuilder<DynamicHomeController>(
              init: DynamicHomeController(),
              builder: (controller) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paso 2: Cargar y Combinar Datos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Estado
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: controller.loading
                                ? Colors.blue[50]
                                : controller.hasConnectionError
                                ? Colors.red[50]
                                : Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              if (controller.loading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Icon(
                                  controller.hasConnectionError
                                      ? Icons.error
                                      : Icons.check_circle,
                                  color: controller.hasConnectionError
                                      ? Colors.red[700]
                                      : Colors.green[700],
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.loading
                                      ? 'Combinando datos de ambos endpoints...'
                                      : controller.hasConnectionError
                                      ? 'Error: ${controller.errorMessage}'
                                      : 'Datos combinados: ${controller.allInvoices.length} facturas',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: controller.loading
                                ? null
                                : () {
                                    controller.loadFromRealEndpoint();
                                  },
                            icon: const Icon(Icons.refresh),
                            label: const Text(
                              'Combinar Datos de Ambos Endpoints',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
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

            // Resultados
            GetBuilder<DynamicHomeController>(
              builder: (controller) {
                if (controller.loading) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (controller.allInvoices.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          const Text('No hay datos para mostrar'),
                          const Text(
                            'Configura los endpoints y carga los datos',
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Análisis de datos
                final arsInvoices = controller.allInvoices
                    .where((inv) => inv.tipoTabEnvioFactura == 'FacturaArs')
                    .length;
                final pacienteInvoices = controller.allInvoices
                    .where(
                      (inv) => inv.tipoTabEnvioFactura == 'FacturaPaciente',
                    )
                    .length;
                final otherInvoices =
                    controller.allInvoices.length -
                    arsInvoices -
                    pacienteInvoices;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paso 3: Resultados de la Combinación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Estadísticas
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
                                'Análisis de Datos Combinados:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '📊 Total facturas: ${controller.allInvoices.length}',
                              ),
                              Text('🏥 FacturaArs: $arsInvoices'),
                              Text('👤 FacturaPaciente: $pacienteInvoices'),
                              if (otherInvoices > 0)
                                Text('❓ Otros tipos: $otherInvoices'),
                              const SizedBox(height: 8),
                              Text(
                                '🏷️ Tabs generados: ${controller.dynamicTabs.length}',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Verificación del problema
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (arsInvoices > 0 && pacienteInvoices > 0)
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: (arsInvoices > 0 && pacienteInvoices > 0)
                                  ? Colors.green[200]!
                                  : Colors.red[200]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                (arsInvoices > 0 && pacienteInvoices > 0)
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: (arsInvoices > 0 && pacienteInvoices > 0)
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  (arsInvoices > 0 && pacienteInvoices > 0)
                                      ? '✅ PROBLEMA RESUELTO: Se ven datos de ambos endpoints'
                                      : '❌ PROBLEMA PERSISTE: Solo se ven datos de un endpoint',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        (arsInvoices > 0 &&
                                            pacienteInvoices > 0)
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tabs dinámicos
                        if (controller.dynamicTabs.isNotEmpty) ...[
                          const Text(
                            'Tabs Dinámicos Generados:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: controller.dynamicTabs.map((tab) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${tab.icon} ${tab.label} (${tab.count})',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Muestra de datos
                        const Text(
                          'Muestra de Datos (primeras 5 facturas):',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),

                        ...controller.allInvoices.take(5).map((invoice) {
                          final isArs =
                              invoice.tipoTabEnvioFactura == 'FacturaArs';
                          final isPaciente =
                              invoice.tipoTabEnvioFactura == 'FacturaPaciente';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isArs
                                  ? Colors.green[50]
                                  : isPaciente
                                  ? Colors.blue[50]
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isArs
                                    ? Colors.green[200]!
                                    : isPaciente
                                    ? Colors.blue[200]!
                                    : Colors.grey[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isArs
                                        ? Colors.green[100]
                                        : isPaciente
                                        ? Colors.blue[100]
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    invoice.tipoTabEnvioFactura ?? 'NULL',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: isArs
                                          ? Colors.green[700]
                                          : isPaciente
                                          ? Colors.blue[700]
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'ENCF: ${invoice.encf} | Cliente: ${invoice.razonsocialcomprador ?? "N/A"}',
                                    style: const TextStyle(fontSize: 12),
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
