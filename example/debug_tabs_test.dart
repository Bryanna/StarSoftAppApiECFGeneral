import 'package:flutter/material.dart';

import '../lib/models/erp_invoice.dart';
import '../lib/services/dynamic_tabs_service.dart';
import '../lib/services/fake_data_service.dart';

/// Test de debug para verificar por qué no aparecen los tabs
class DebugTabsTestScreen extends StatefulWidget {
  const DebugTabsTestScreen({super.key});

  @override
  State<DebugTabsTestScreen> createState() => _DebugTabsTestScreenState();
}

class _DebugTabsTestScreenState extends State<DebugTabsTestScreen> {
  List<dynamic> rawData = [];
  List<ERPInvoice> erpInvoices = [];
  List<DynamicTab> tabs = [];
  bool loading = true;
  String debugInfo = '';

  @override
  void initState() {
    super.initState();
    _runDebugTest();
  }

  Future<void> _runDebugTest() async {
    setState(() {
      loading = true;
      debugInfo = 'Iniciando test de debug...\n';
    });

    try {
      // 1. Cargar datos raw del servicio fake
      debugInfo += '1. Cargando datos del FakeDataService...\n';
      final datumList = await FakeDataService.generateFakeInvoicesFromJson();
      rawData = datumList;
      debugInfo += '   - Datos cargados: ${datumList.length} registros\n';

      // 2. Verificar si tienen tipoTabEnvioFactura
      int withTipoTab = 0;
      for (var datum in datumList) {
        if (datum.tipoTabEnvioFactura != null &&
            datum.tipoTabEnvioFactura!.isNotEmpty) {
          withTipoTab++;
          debugInfo += '   - Encontrado: ${datum.tipoTabEnvioFactura}\n';
        }
      }
      debugInfo += '   - Registros con tipoTabEnvioFactura: $withTipoTab\n';

      // 3. Convertir a ERPInvoice
      debugInfo += '2. Convirtiendo a ERPInvoice...\n';
      erpInvoices = datumList
          .map((datum) => _convertToERPInvoice(datum))
          .toList();
      debugInfo += '   - ERPInvoices creados: ${erpInvoices.length}\n';

      // 4. Verificar ERPInvoices
      int erpWithTipoTab = 0;
      for (var invoice in erpInvoices) {
        if (invoice.tipoTabEnvioFactura != null &&
            invoice.tipoTabEnvioFactura!.isNotEmpty) {
          erpWithTipoTab++;
          debugInfo += '   - ERP con tipoTab: ${invoice.tipoTabEnvioFactura}\n';
        }
      }
      debugInfo +=
          '   - ERPInvoices con tipoTabEnvioFactura: $erpWithTipoTab\n';

      // 5. Generar tabs
      debugInfo += '3. Generando tabs dinámicos...\n';
      tabs = DynamicTabsService.generateTabsFromInvoices(erpInvoices);
      debugInfo += '   - Tabs generados: ${tabs.length}\n';

      for (var tab in tabs) {
        debugInfo +=
            '   - Tab: ${tab.label} (${tab.count}) - Tipo: ${tab.tabType}\n';
      }
    } catch (e, stackTrace) {
      debugInfo += 'ERROR: $e\n';
      debugInfo += 'Stack: $stackTrace\n';
    }

    setState(() {
      loading = false;
    });
  }

  ERPInvoice _convertToERPInvoice(dynamic datum) {
    return ERPInvoice(
      encf: datum.encf,
      tipoecf: datum.tipoecf,
      razonsocialcomprador: datum.razonsocialcomprador?.toString(),
      montototal: datum.montototal,
      tipoTabEnvioFactura: datum.tipoTabEnvioFactura,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug: Tabs Test'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _runDebugTest, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información de debug
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Debug Info:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              debugInfo,
                              style: const TextStyle(
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

                  // Tabs generados
                  if (tabs.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tabs Generados:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...tabs.map((tab) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      tab.icon,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tab.label,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Count: ${tab.count} | ID: ${tab.id}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (tab.tabType != null)
                                            Text(
                                              'TabType: ${tab.tabType}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.blue[700],
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                        ],
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
                  ],

                  const SizedBox(height: 16),

                  // Muestra de facturas
                  if (erpInvoices.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Muestra de Facturas (primeras 5):',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...erpInvoices.take(5).map((invoice) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ENCF: ${invoice.encf ?? "N/A"}'),
                                    Text(
                                      'Tipo ECF: ${invoice.tipoecf ?? "N/A"}',
                                    ),
                                    Text(
                                      'Cliente: ${invoice.razonsocialcomprador ?? "N/A"}',
                                    ),
                                    Text(
                                      'TipoTabEnvioFactura: ${invoice.tipoTabEnvioFactura ?? "NULL"}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            invoice.tipoTabEnvioFactura != null
                                            ? Colors.green[700]
                                            : Colors.red[700],
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
                  ],
                ],
              ),
            ),
    );
  }
}
