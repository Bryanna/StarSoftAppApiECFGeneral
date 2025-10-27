import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dynamic_home_controller.dart';
import '../models/erp_invoice.dart';
import '../widgets/invoice_table.dart';

/// Widget que muestra una tabla de datos dinámicos basada en el controlador dinámico
class DynamicDataTable extends StatelessWidget {
  final Function(ERPInvoice) onView;
  final Function(ERPInvoice) onSend;
  final Function(ERPInvoice) onPreview;
  final Function(ERPInvoice)? onPreviewArsHeader;
  final Function(ERPInvoice)? onPreviewArsDetail;

  const DynamicDataTable({
    super.key,
    required this.onView,
    required this.onSend,
    required this.onPreview,
    this.onPreviewArsHeader,
    this.onPreviewArsDetail,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DynamicHomeController>(
      builder: (controller) {
        if (controller.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Obtener facturas filtradas
        final filteredInvoices = controller.getSearchFilteredInvoices();

        // Determinar si estamos en el tab ARS
        final isArsTab =
            (controller.currentTab?.tabType?.toLowerCase().contains('ars') ??
            false);

        // Mostrar tabla de facturas
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: InvoiceTable(
            invoices: filteredInvoices,
            onView: onView,
            onSend: onSend,
            onPreview: onPreview,
            onPreviewArsHeader: onPreviewArsHeader,
            onPreviewArsDetail: onPreviewArsDetail,
            onToggleSelection: controller.toggleSelection,
            onToggleSelectAll: controller.toggleSelectAll,
            isSelected: controller.isSelected,
            isAllSelected: controller.isAllSelected,
            isArsTab: isArsTab,
          ),
        );
      },
    );
  }
}
