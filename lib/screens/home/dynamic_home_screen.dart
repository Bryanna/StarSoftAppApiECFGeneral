import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../controllers/dynamic_home_controller.dart';
import '../../models/erp_invoice.dart';
import '../../routes/app_routes.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/dynamic_data_table.dart';
import '../../widgets/dynamic_tabs_bar.dart';
import '../../widgets/enhanced_invoice_preview.dart';
import '../../widgets/simple_invoice_modal.dart';
import 'home_controller.dart';

/// Versión dinámica del HomeScreen que genera tabs basados en los tipos de ENCF encontrados
class DynamicHomeScreen extends StatelessWidget {
  const DynamicHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DynamicHomeController>(
      init: DynamicHomeController(),
      builder: (controller) {
        final isWideApp = MediaQuery.of(context).size.width > 900;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            centerTitle: false,
            title: Row(
              children: [
                Image.asset('assets/logo.png', height: 50),
                SizedBox(
                  width: isWideApp ? 420 : 240,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 8,
                    ),
                    child: TextField(
                      onChanged: controller.setQuery,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        hintText: 'Buscar facturas, pacientes, documentos…',
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              // Botón de Debug (solo en desarrollo)
              IconButton(
                icon: const Icon(Icons.bug_report),
                tooltip: 'Debug Tabs',
                onPressed: () {
                  controller.debugPrintState();
                  Get.snackbar(
                    'Debug',
                    'Estado impreso en consola. Tabs: ${controller.dynamicTabs.length}',
                    backgroundColor: Colors.blue[100],
                    colorText: Colors.blue[700],
                  );
                },
              ),
              // Botón de Cola
              IconButton(
                icon: const Icon(Icons.queue),
                tooltip: 'Ver Cola de Envío',
                onPressed: () => Get.toNamed(AppRoutes.QUEUE),
              ),
              const _AccountMenuButton(),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de Facturas Electrónicas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tabs dinámicos
                    DynamicTabsBar(isWide: isWide),
                    const SizedBox(height: 16),

                    // Selector de rango de fechas
                    _DateRangeSelector(),
                    const SizedBox(height: 16),

                    // Encabezado y botones de acción
                    _ActionBar(),
                    const SizedBox(height: 12),

                    // Contenido dinámico
                    Expanded(
                      child: DynamicDataTable(
                        onView: _viewDetails,
                        onSend: _sendInvoice,
                        onPreview: _previewInvoice,
                        onPreviewArsHeader: _previewArsHeader,
                        onPreviewArsDetail: _previewArsDetail,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _viewDetails(ERPInvoice invoice) {
    showSimpleInvoiceModal(context: Get.context!, invoice: invoice);
  }

  void _sendInvoice(ERPInvoice invoice) {
    // TODO: Implementar envío individual
    Get.snackbar(
      'Función en desarrollo',
      'El envío individual se implementará próximamente',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _previewInvoice(ERPInvoice invoice) {
    showEnhancedInvoicePreview(context: Get.context!, invoice: invoice);
  }

  void _previewArsHeader(ERPInvoice invoice) {
    try {
      final hc = Get.find<HomeController>();
      hc.previewArsHeader(invoice);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo abrir el encabezado ARS',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _previewArsDetail(ERPInvoice invoice) {
    try {
      final hc = Get.find<HomeController>();
      hc.previewArsDetail(invoice);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo abrir el detalle ARS',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _ActionBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DynamicHomeController>(
      builder: (controller) {
        final currentTabLabel = controller.currentTab?.label ?? 'Facturas';

        return Row(
          children: [
            Text(
              currentTabLabel,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (controller.hasSelection) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${controller.selectedInvoiceIds.length} seleccionada(s)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),

            // Botón Limpiar Selección
            if (controller.hasSelection) ...[
              _ActionButton(
                label: 'Limpiar',
                icon: Icons.clear,
                color: Colors.grey.shade400,
                onTap: controller.clearSelection,
              ),
              const SizedBox(width: 12),
            ],

            // Botón Refresh
            _ActionButton(
              label: 'Refresh',
              icon: FontAwesomeIcons.arrowsRotate,
              color: Theme.of(context).colorScheme.secondary,
              onTap: controller.refresh,
            ),
            const SizedBox(width: 12),

            // Botón Enviar
            _ActionButton(
              label: controller.hasSelection
                  ? 'Enviar (${controller.selectedInvoiceIds.length})'
                  : 'Enviar',
              icon: FontAwesomeIcons.paperPlane,
              color: controller.hasSelection
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary.withOpacity(0.5),
              onTap: controller.hasSelection ? _sendSelectedInvoices : null,
              width: controller.hasSelection ? 160 : 120,
            ),
          ],
        );
      },
    );
  }

  void _sendSelectedInvoices() {
    // TODO: Implementar envío en lote
    Get.snackbar(
      'Función en desarrollo',
      'El envío en lote se implementará próximamente',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final double width;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    this.width = 120,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        height: 40,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: onTap != null ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: onTap != null ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDateRange(
    BuildContext context,
    DynamicHomeController controller,
  ) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange:
          controller.startDate != null && controller.endDate != null
          ? DateTimeRange(
              start: controller.startDate!,
              end: controller.endDate!,
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DynamicHomeController>(
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.hasDateFilter
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 20,
                color: controller.hasDateFilter
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Text(
                'Filtrar por fecha:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              // Botón de rango de fechas
              InkWell(
                onTap: () => _selectDateRange(context, controller),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: controller.hasDateFilter
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: controller.hasDateFilter
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.hasDateFilter
                            ? '${_formatDate(controller.startDate)} - ${_formatDate(controller.endDate)}'
                            : 'Seleccionar rango',
                        style: TextStyle(
                          fontSize: 13,
                          color: controller.hasDateFilter
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: controller.hasDateFilter
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              ),
              // Botón limpiar filtro
              if (controller.hasDateFilter) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: controller.clearDateFilter,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Icon(
                      Icons.clear,
                      size: 16,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Contador de resultados filtrados
              if (controller.hasDateFilter)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${controller.getSearchFilteredInvoices().length} resultado(s)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

enum _AccountAction { profile, settings, pdfMaker, logout }

class _AccountMenuButton extends StatelessWidget {
  const _AccountMenuButton();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_AccountAction>(
      tooltip: 'Mi Cuenta',
      icon: Icon(
        FontAwesomeIcons.user,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      offset: const Offset(0, 12),
      onSelected: (action) async {
        switch (action) {
          case _AccountAction.profile:
            Get.toNamed(AppRoutes.PROFILE);
            break;
          case _AccountAction.settings:
            Get.toNamed(AppRoutes.CONFIGURACION);
            break;
          case _AccountAction.pdfMaker:
            Get.toNamed(AppRoutes.PDF_MAKER);
            break;
          case _AccountAction.logout:
            await FirebaseAuthService().signOut();
            // Remueve el marcador de sesión para que Splash redirija a Login
            GetStorage().remove('f_nombre_usuario');
            // Limpiar también los datos del usuario
            UserService.clearUserData();
            Get.offAllNamed(AppRoutes.LOGIN);
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<_AccountAction>(
          enabled: false,
          child: Text(
            'Mi Cuenta',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const PopupMenuItem<_AccountAction>(
          value: _AccountAction.profile,
          child: Text('Perfil'),
        ),
        const PopupMenuItem<_AccountAction>(
          value: _AccountAction.settings,
          child: Text('Configuración'),
        ),
        const PopupMenuItem<_AccountAction>(
          value: _AccountAction.pdfMaker,
          child: Text('PDF Maker'),
        ),
        const PopupMenuItem<_AccountAction>(
          value: _AccountAction.logout,
          child: Text('Cerrar Sesión'),
        ),
      ],
    );
  }
}
