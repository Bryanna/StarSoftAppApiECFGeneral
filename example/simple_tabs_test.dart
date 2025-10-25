import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../lib/controllers/dynamic_home_controller.dart';

/// Test simple de tabs dinámicos sin dependencias de debug
class SimpleTabsTestScreen extends StatelessWidget {
  const SimpleTabsTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Simple: Tabs'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Get.find<DynamicHomeController>().refresh();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: GetBuilder<DynamicHomeController>(
        init: DynamicHomeController(),
        builder: (controller) {
          return Column(
            children: [
              // Estado básico
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green[50],
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Facturas: ${controller.allInvoices.length} | '
                        'Tabs: ${controller.dynamicTabs.length} | '
                        'Estado: ${controller.loading ? "Cargando..." : "Listo"}',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs como chips
              if (controller.dynamicTabs.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.dynamicTabs.map((tab) {
                      final isSelected = controller.currentTab?.id == tab.id;
                      return FilterChip(
                        selected: isSelected,
                        label: Text('${tab.icon} ${tab.label} (${tab.count})'),
                        onSelected: (selected) {
                          if (selected) controller.selectTab(tab);
                        },
                      );
                    }).toList(),
                  ),
                ),

              // Lista simple de facturas
              Expanded(
                child: controller.loading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.filteredInvoices.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay facturas para mostrar',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            itemCount: controller.filteredInvoices.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final invoice = controller.filteredInvoices[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    invoice.tipoecf ?? '?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                                title: Text(
                                  invoice.encf ?? 'Sin ENCF',
                                  style: const TextStyle(fontFamily: 'monospace'),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      invoice.razonsocialcomprador ?? 'Sin cliente',
                                      style: const TextStyle(fontSize: 12),
                                    ),
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
                                          'Tab: ${invoice.tipoTabEnvioFactura}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.orange[700],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: invoice.montototal != null
                                    ? Text(
                                        '\$${_formatMoney(invoice.montototal)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatMoney(dynamic value) {
    if (value == null) return '0.00';

    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.toStringAsFixed(2) ?? '0.00';
    }

    if (value is num) {
      return value.toStringAsFixed(2);
    }

    return '0.00';
  }
}
