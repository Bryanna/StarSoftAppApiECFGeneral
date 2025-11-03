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
      title: 'Test Current System',
      theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
      home: const TestCurrentSystemScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Test del sistema actual con debug mejorado
class TestCurrentSystemScreen extends StatelessWidget {
  const TestCurrentSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test: Sistema Actual'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instrucciones
            Card(
              color: Colors.teal[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.teal[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Test del Sistema Actual',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Este test usa el sistema actual con debug mejorado para ver exactamente qué está pasando con la combinación de endpoints.',
                      style: TextStyle(color: Colors.teal[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pasos:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                    Text(
                      '1. Configurar ambos endpoints\n2. Cargar datos\n3. Ver debug en consola\n4. Verificar resultados',
                      style: TextStyle(color: Colors.teal[600]),
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
                          '1. Configuración de Endpoints',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Configurar exactamente los 2 endpoints
                              controller.baseERPUrl =
                                  'https://cempsavid.duckdns.org/api';
                              controller.baseERPUrlCtrl.text =
                                  controller.baseERPUrl;

                              // Limpiar endpoints existentes
                              controller.erpEndpoints.clear();

                              // Agregar exactamente los 2 endpoints que mencionas
                              controller.addEndpoint('ars', '/ars/full');
                              controller.addEndpoint(
                                'invoices',
                                '/invoices/full',
                              );

                              controller.update();

                              Get.snackbar(
                                'Configurado',
                                'Configurados: ARS (/ars/full) + Invoices (/invoices/full)',
                                backgroundColor: Colors.green[100],
                                colorText: Colors.green[700],
                                duration: const Duration(seconds: 3),
                              );
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('Configurar 2 Endpoints'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[100],
                              foregroundColor: Colors.teal[700],
                            ),
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
                              Text(
                                'Estado Actual:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Base URL: ${controller.baseERPUrl}'),
                              Text(
                                'Endpoints: ${controller.erpEndpoints.length}',
                              ),
                              if (controller.erpEndpoints.isNotEmpty) ...[
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
                                                : Colors.blue[100],
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
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Carga de datos
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
                          '2. Cargar y Combinar Datos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Estado de carga
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
                                      ? 'Combinando datos... (revisa la consola para debug)'
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
                                    print(
                                      '🚀 INICIANDO CARGA CON DEBUG MEJORADO',
                                    );
                                    print(
                                      '🚀 Revisa la consola para ver el debug detallado',
                                    );
                                    controller.loadFromRealEndpoint();
                                  },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Cargar Datos (con Debug)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[700],
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
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Cargando datos...'),
                            Text('Revisa la consola para debug detallado'),
                          ],
                        ),
                      ),
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

                // Análisis detallado de los datos
                final arsInvoices = controller.allInvoices
                    .where((inv) => inv.tipoTabEnvioFactura == 'FacturaArs')
                    .toList();
                final pacienteInvoices = controller.allInvoices
                    .where(
                      (inv) => inv.tipoTabEnvioFactura == 'FacturaPaciente',
                    )
                    .toList();

                // Contar todos los tipos de tab
                final allTabTypes = <String, int>{};
                for (final invoice in controller.allInvoices) {
                  final tabType = invoice.tipoTabEnvioFactura;
                  if (tabType != null) {
                    allTabTypes[tabType] = (allTabTypes[tabType] ?? 0) + 1;
                  }
                }

                final problemResolved =
                    arsInvoices.isNotEmpty && pacienteInvoices.isNotEmpty;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '3. Resultados del Test',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Resultado principal
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: problemResolved
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: problemResolved
                                  ? Colors.green[200]!
                                  : Colors.red[200]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                problemResolved
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: problemResolved
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  problemResolved
                                      ? '✅ PROBLEMA RESUELTO: Se ven datos de ambos endpoints'
                                      : '❌ PROBLEMA PERSISTE: Solo se ven datos de un tipo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: problemResolved
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Estadísticas detalladas
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
                                'Estadísticas Detalladas:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '📊 Total facturas: ${controller.allInvoices.length}',
                              ),
                              Text('🏥 FacturaArs: ${arsInvoices.length}'),
                              Text(
                                '👤 FacturaPaciente: ${pacienteInvoices.length}',
                              ),

                              if (allTabTypes.length > 2) ...[
                                const SizedBox(height: 4),
                                const Text('🏷️ Otros tipos encontrados:'),
                                ...allTabTypes.entries
                                    .where(
                                      (e) => ![
                                        'FacturaArs',
                                        'FacturaPaciente',
                                      ].contains(e.key),
                                    )
                                    .map(
                                      (e) => Text('   • ${e.key}: ${e.value}'),
                                    ),
                              ],

                              const SizedBox(height: 8),
                              Text(
                                '🏷️ Tabs dinámicos: ${controller.dynamicTabs.length}',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tabs generados
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

                        // Muestra de datos por tipo
                        if (arsInvoices.isNotEmpty) ...[
                          const Text(
                            'Muestra FacturaArs (primeras 3):',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          ...arsInvoices
                              .take(3)
                              .map(
                                (invoice) => _InvoiceCard(
                                  invoice: invoice,
                                  color: Colors.green,
                                ),
                              ),
                        ],

                        if (pacienteInvoices.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Muestra FacturaPaciente (primeras 3):',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          ...pacienteInvoices
                              .take(3)
                              .map(
                                (invoice) => _InvoiceCard(
                                  invoice: invoice,
                                  color: Colors.blue,
                                ),
                              ),
                        ],
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

class _InvoiceCard extends StatelessWidget {
  final dynamic invoice;
  final MaterialColor color;

  const _InvoiceCard({required this.invoice, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              invoice.tipoTabEnvioFactura ?? 'NULL',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: color[700],
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
  }
}
