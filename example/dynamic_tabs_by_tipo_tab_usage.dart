import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../lib/services/dynamic_tabs_service.dart';
import '../lib/models/erp_invoice.dart';

/// Ejemplo de uso de tabs dinámicos basados en tipo_tab_envio_factura
///
/// Demuestra cómo el sistema genera tabs automáticamente dividiendo
/// las palabras por mayúsculas:
/// - "FacturaArs" → "Factura Ars" 🏥
/// - "NotaCredito" → "Nota Credito" 📉
/// - "FacturaConsumo" → "Factura Consumo" 🛒
/// - "GastoMenor" → "Gasto Menor" 💸

class DynamicTabsByTipoTabUsageScreen extends StatelessWidget {
  const DynamicTabsByTipoTabUsageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabs Dinámicos por Tipo Tab'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ExplanationCard(),
            const SizedBox(height: 20),
            _ExampleDataCard(),
            const SizedBox(height: 20),
            _GeneratedTabsCard(),
            const SizedBox(height: 20),
            _TestButtonsCard(),
          ],
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
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
                  'Cómo Funciona',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _ExampleItem(
              input: '"FacturaArs"',
              output: '"Factura Ars" 🏥',
              description: 'Facturas del sistema ARS',
            ),
            _ExampleItem(
              input: '"NotaCredito"',
              output: '"Nota Credito" 📉',
              description: 'Notas de crédito',
            ),
            _ExampleItem(
              input: '"FacturaConsumo"',
              output: '"Factura Consumo" 🛒',
              description: 'Facturas de consumo',
            ),
            _ExampleItem(
              input: '"GastoMenor"',
              output: '"Gasto Menor" 💸',
              description: 'Gastos menores',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExampleItem extends StatelessWidget {
  final String input;
  final String output;
  final String description;

  const _ExampleItem({
    required this.input,
    required this.output,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              input,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  output,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleDataCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datos de Ejemplo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            const Text(
              'Facturas con diferentes tipos de tab:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            _DataExample(
              title: 'Factura 1',
              field: 'tipo_tab_envio_factura',
              value: 'FacturaArs',
            ),
            _DataExample(
              title: 'Factura 2',
              field: 'tipo_tab_envio_factura',
              value: 'NotaCredito',
            ),
            _DataExample(
              title: 'Factura 3',
              field: 'tipo_tab_envio_factura',
              value: 'FacturaConsumo',
            ),
            _DataExample(
              title: 'Factura 4',
              field: 'tipo_tab_envio_factura',
              value: 'GastoMenor',
            ),
          ],
        ),
      ),
    );
  }
}

class _DataExample extends StatelessWidget {
  final String title;
  final String field;
  final String value;

  const _DataExample({
    required this.title,
    required this.field,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text('$title:', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(
            '"$field": "$value"',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _GeneratedTabsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Crear facturas de ejemplo
    final sampleInvoices = _createSampleInvoices();

    // Generar tabs dinámicos
    final dynamicTabs = DynamicTabsService.generateTabsFromInvoices(
      sampleInvoices,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tabs Generados Automáticamente',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...dynamicTabs.map((tab) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Text(tab.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tab.label,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'ID: ${tab.id} | Cantidad: ${tab.count}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (tab.tabType != null)
                            Text(
                              'Tipo: ${tab.tabType}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[700],
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
    );
  }

  List<ERPInvoice> _createSampleInvoices() {
    return [
      ERPInvoice(tipoTabEnvioFactura: 'FacturaArs'),
      ERPInvoice(tipoTabEnvioFactura: 'FacturaArs'),
      ERPInvoice(tipoTabEnvioFactura: 'NotaCredito'),
      ERPInvoice(tipoTabEnvioFactura: 'FacturaConsumo'),
      ERPInvoice(tipoTabEnvioFactura: 'FacturaConsumo'),
      ERPInvoice(tipoTabEnvioFactura: 'FacturaConsumo'),
      ERPInvoice(tipoTabEnvioFactura: 'GastoMenor'),
    ];
  }
}

class _TestButtonsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pruebas de Formateo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TestButton(
                  input: 'FacturaArs',
                  onPressed: () => _testFormat(context, 'FacturaArs'),
                ),
                _TestButton(
                  input: 'NotaCreditoFiscal',
                  onPressed: () => _testFormat(context, 'NotaCreditoFiscal'),
                ),
                _TestButton(
                  input: 'CompraGubernamental',
                  onPressed: () => _testFormat(context, 'CompraGubernamental'),
                ),
                _TestButton(
                  input: 'PagoExterior',
                  onPressed: () => _testFormat(context, 'PagoExterior'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _testFormat(BuildContext context, String input) {
    final formatted = DynamicTabsService.formatTabTypeLabel(input);
    final icon = DynamicTabsService.getTabTypeIcon(input);

    Get.dialog(
      AlertDialog(
        title: const Text('Resultado del Formateo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text('Entrada: '),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    input,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Resultado: '),
                Text(
                  '$icon $formatted',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
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

class _TestButton extends StatelessWidget {
  final String input;
  final VoidCallback onPressed;

  const _TestButton({required this.input, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[100],
        foregroundColor: Colors.blue[700],
      ),
      child: Text(input, style: const TextStyle(fontSize: 12)),
    );
  }
}
