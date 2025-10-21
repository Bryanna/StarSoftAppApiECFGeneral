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

  const DynamicDataTable({
    super.key,
    required this.onView,
    required this.onSend,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DynamicHomeController>(
      builder: (controller) {
        if (controller.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Manejar estados de error
        if (controller.hasERPConfigError) {
          return _buildErrorState(
            context,
            icon: Icons.admin_panel_settings_outlined,
            title: 'Configuración Requerida',
            message: controller.errorMessage ?? 'URL del ERP no configurado',
            actionText: 'Contactar Administrador',
            onAction: () {},
            color: Theme.of(context).colorScheme.tertiary,
          );
        }

        if (controller.hasNoInvoicesError) {
          return _buildErrorState(
            context,
            icon: Icons.inbox_outlined,
            title: 'Sin Facturas Pendientes',
            message: controller.errorMessage ?? 'No hay facturas pendientes',
            actionText: 'Actualizar',
            onAction: controller.refresh,
            color: Colors.blue,
          );
        }

        if (controller.hasConnectionError) {
          return _buildErrorState(
            context,
            icon: Icons.cloud_off_outlined,
            title: 'Error de Conexión',
            message: controller.errorMessage ?? 'Error conectando al ERP',
            actionText: 'Reintentar',
            onAction: controller.refresh,
            color: Colors.red,
          );
        }

        // Obtener facturas filtradas
        final filteredInvoices = controller.getSearchFilteredInvoices();

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
            onToggleSelection: controller.toggleSelection,
            onToggleSelectAll: controller.toggleSelectAll,
            isSelected: controller.isSelected,
            isAllSelected: controller.isAllSelected,
          ),
        );
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(
                actionText == 'Contactar Administrador'
                    ? Icons.contact_support
                    : Icons.refresh,
                size: 18,
              ),
              label: Text(actionText),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
