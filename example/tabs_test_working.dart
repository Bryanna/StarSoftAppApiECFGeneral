import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../lib/controllers/dynamic_home_controller.dart';

class TabsTestWorkingScreen extends StatelessWidget {
  const TabsTestWorkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test: Tabs Dinámicos'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              final controller = Get.find<DynamicHomeController>();
              controller.refresh();
              controller.debugPrintState();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: GetBuilder<DynamicHomeController>(
        init: DynamicHomeController(),
        builder: (controller) {
          if (controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado Actual:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    Text('Total facturas: ${controller.allInvoices.length}'),
                    Text('Tabs generados: ${controller.dynamicTabs.length}'),
                    Text(
                      'Tab actual: ${controller.currentTab?.label ?? "Ninguno"}',
                    ),
                  ],
                ),
              ),
              if (controller.dynamicTabs.isNotEmpty)
                Container(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.dynamicTabs.length,
                    itemBuilder: (context, index) {
                      final tab = controller.dynamicTabs[index];
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () => controller.selectTab(tab),
                          child: Text(
                            '${tab.icon} ${tab.label} (${tab.count})',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.filteredInvoices.length,
                  itemBuilder: (context, index) {
                    final invoice = controller.filteredInvoices[index];
                    return ListTile(
                      title: Text(invoice.encf ?? 'Sin ENCF'),
                      subtitle: Text(
                        invoice.tipoTabEnvioFactura ?? 'Sin tipo tab',
                      ),
                      trailing: Text(invoice.tipoecf ?? 'N/A'),
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
}
