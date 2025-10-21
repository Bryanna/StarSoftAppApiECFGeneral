import 'package:facturacion/models/erp_invoice_extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../lib/controllers/dynamic_home_controller.dart';
import '../lib/models/erp_invoice.dart';
import '../lib/widgets/dynamic_data_table.dart';
import '../lib/widgets/dynamic_tabs_bar.dart';

/// Ejemplo de uso del sistema de tabs dinámicos
///
/// Este ejemplo muestra cómo el sistema genera automáticamente tabs
/// basados en los tipos de ENCF encontrados en los datos de facturas.
///
/// Características:
/// - Tabs generados dinámicamente según tipos de ENCF (31, 32, 33, 34, etc.)
/// - Contadores automáticos por cada tipo
/// - Iconos y colores específicos por tipo de comprobante
/// - Filtrado automático de facturas por tab seleccionado
/// - Búsqueda y filtros de fecha integrados
///
/// Tipos de ENCF soportados:
/// - E31: Crédito Fiscal Electrónico 💰
/// - E32: Consumo Electrónico 🛒
/// - E33: Nota de Débito Electrónica 📈
/// - E34: Nota de Crédito Electrónica 📉
/// - E41: Compras Electrónico 🏪
/// - E43: Gastos Menores Electrónico 💸
/// - E44: Regímenes Especiales Electrónico ⚖️
/// - E45: Gubernamental Electrónico 🏛️
class DynamicTabsUsageExample extends StatelessWidget {
  const DynamicTabsUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabs Dinámicos - Ejemplo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: GetBuilder<DynamicHomeController>(
        init: DynamicHomeController(),
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  'Sistema de Tabs Dinámicos',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Descripción
                Text(
                  'Los tabs se generan automáticamente basados en los tipos de ENCF encontrados en los datos.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),

                // Información de debug
                if (controller.dynamicTabs.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tabs generados: ${controller.dynamicTabs.length}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        for (final tab in controller.dynamicTabs)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${tab.icon} ${tab.label}: ${tab.count} facturas${tab.encfType != null ? ' (ENCF: ${tab.encfType})' : ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Tabs dinámicos
                const DynamicTabsBar(isWide: true),
                const SizedBox(height: 16),

                // Información del tab actual
                if (controller.currentTab != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          controller.currentTab!.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tab actual: ${controller.currentTab!.label}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                '${controller.currentTab!.count} facturas${controller.currentTab!.encfType != null ? ' • Tipo ENCF: ${controller.currentTab!.encfType}' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Tabla de datos
                Expanded(
                  child: DynamicDataTable(
                    onView: (invoice) => _showInvoiceDetails(context, invoice),
                    onSend: (invoice) =>
                        _showSnackbar('Enviar: ${invoice.numeroFactura}'),
                    onPreview: (invoice) =>
                        _showSnackbar('Vista previa: ${invoice.numeroFactura}'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showInvoiceDetails(BuildContext context, ERPInvoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Factura'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ENCF: ${invoice.encf ?? 'N/A'}'),
            Text('Tipo: ${invoice.tipoecf ?? 'N/A'}'),
            Text('Cliente: ${invoice.clienteNombre}'),
            Text('Total: ${invoice.formattedTotal}'),
            Text('Fecha: ${invoice.formattedFechaEmision}'),
            const SizedBox(height: 8),
            Text(
              'Tipo de Comprobante: ${invoice.tipoComprobanteDisplay}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    Get.snackbar(
      'Acción',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

/// Widget de ejemplo para mostrar cómo usar el sistema en una aplicación real
class DynamicTabsIntegrationExample extends StatelessWidget {
  const DynamicTabsIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integración Completa')),
      body: GetBuilder<DynamicHomeController>(
        init: DynamicHomeController(),
        builder: (controller) {
          return Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: controller.setQuery,
                  decoration: InputDecoration(
                    hintText: 'Buscar facturas...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Tabs dinámicos
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: DynamicTabsBar(isWide: true),
              ),

              // Información de filtros activos
              if (controller.query.isNotEmpty || controller.hasDateFilter)
                Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Filtros activos: ${controller.query.isNotEmpty ? 'Búsqueda' : ''}${controller.query.isNotEmpty && controller.hasDateFilter ? ', ' : ''}${controller.hasDateFilter ? 'Fechas' : ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        '${controller.getSearchFilteredInvoices().length} resultados',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Tabla de datos
              Expanded(
                child: DynamicDataTable(
                  onView: (invoice) =>
                      Get.snackbar('Ver', invoice.numeroFactura),
                  onSend: (invoice) =>
                      Get.snackbar('Enviar', invoice.numeroFactura),
                  onPreview: (invoice) =>
                      Get.snackbar('Preview', invoice.numeroFactura),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
