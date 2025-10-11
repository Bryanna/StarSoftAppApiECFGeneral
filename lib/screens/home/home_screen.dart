import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/erp_invoice.dart';
import '../../models/erp_invoice_extensions.dart';
import '../../models/ui_types.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/invoice_table.dart';
import 'home_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/user_service.dart';
import 'package:get_storage/get_storage.dart';

// Refactor: usamos StatelessWidget con estado manejado por GetX en HomeController
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Eliminamos Stateful y controladores locales; el estado viene de HomeController

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        final q = controller.query.trim().toLowerCase();
        bool matches(ERPInvoice inv) {
          // Usar el método de búsqueda integrado del ERPInvoice
          return inv.matchesSearch(q);
        }

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
              // Primero aplicar filtro de fechas
              final dateFiltered = controller.getFilteredInvoices();
              // Luego aplicar búsqueda de texto
              final filtered = q.isEmpty
                  ? dateFiltered
                  : dateFiltered.where(matches).toList();
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
                    // Tabs
                    _TabsBar(isWide: isWide),
                    const SizedBox(height: 16),

                    // Selector de rango de fechas
                    _DateRangeSelector(),
                    const SizedBox(height: 16),

                    // Encabezado y botones de acción (Refresh y Enviar)
                    Row(
                      children: [
                        Text(
                          _titleFor(controller.currentCategory),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
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
                          GestureDetector(
                            onTap: controller.clearSelection,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              height: 40,
                              width: 120,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.clear,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Limpiar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        // Botón Refresh
                        GestureDetector(
                          onTap: () => controller.refreshCurrentCategory(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            height: 40,
                            width: 120,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.arrowsRotate,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSecondary,
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  'Refresh',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Botón Enviar (ahora envía seleccionadas)
                        GestureDetector(
                          onTap: controller.hasSelection
                              ? controller.sendSelectedInvoices
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            height: 40,
                            width: controller.hasSelection ? 160 : 120,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: controller.hasSelection
                                  ? Colors.green
                                  : Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.paperPlane,
                                  size: 16,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  controller.hasSelection
                                      ? 'Enviar (${controller.selectedInvoiceIds.length})'
                                      : 'Enviar',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Contenido
                    Expanded(
                      child: controller.loading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildContent(context, controller, filtered),
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

  String _titleFor(InvoiceCategory category) {
    switch (category) {
      case InvoiceCategory.todos:
        return 'Todas las Facturas';
      case InvoiceCategory.pacientes:
        return 'Facturas de Pacientes';
      case InvoiceCategory.ars:
        return 'Facturas ARS';
      case InvoiceCategory.notasCredito:
        return 'Notas Crédito';
      case InvoiceCategory.notasDebito:
        return 'Notas Débito';
      case InvoiceCategory.gastos:
        return 'Facturas Gastos';
      case InvoiceCategory.enviados:
        return 'Documentos Enviados';
      case InvoiceCategory.rechazados:
        return 'Documentos Rechazados';
    }
  }

  Widget _buildContent(
    BuildContext context,
    HomeController controller,
    List<ERPInvoice> filtered,
  ) {
    // Si hay error de configuración ERP
    if (controller.hasERPConfigError) {
      return _buildERPConfigError(
        context,
        message: controller.errorMessage ?? 'URL del ERP no configurado',
      );
    }

    // Si no hay facturas pendientes
    if (controller.hasNoInvoicesError) {
      return _buildErrorState(
        context,
        icon: Icons.inbox_outlined,
        title: 'Sin Facturas Pendientes',
        message: controller.errorMessage ?? 'No hay facturas pendientes',
        actionText: 'Actualizar',
        onAction: () => controller.refreshCurrentCategory(),
        color: Colors.blue,
      );
    }

    // Si hay error de conexión
    if (controller.hasConnectionError) {
      return _buildErrorState(
        context,
        icon: Icons.cloud_off_outlined,
        title: 'Error de Conexión',
        message: controller.errorMessage ?? 'Error conectando al ERP',
        actionText: 'Reintentar',
        onAction: () => controller.refreshCurrentCategory(),
        color: Colors.red,
      );
    }

    // Contenido normal
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InvoiceTable(
        invoices: filtered,
        onView: controller.viewDetails,
        onSend: controller.sendInvoice,
        onDownload: controller.downloadInvoice,
        onToggleSelection: controller.toggleSelection,
        onToggleSelectAll: controller.toggleSelectAll,
        isSelected: controller.isSelected,
        isAllSelected: controller.isAllSelected,
      ),
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
                actionText == 'Ir a Configuración'
                    ? Icons.settings
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

  Widget _buildERPConfigError(BuildContext context, {required String message}) {
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
            Icon(
              Icons.admin_panel_settings_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Configuración Requerida',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'URL del ERP no configurado.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Contacta con un Administrador del sistema.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Configuración pendiente',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AccountAction { profile, settings, logout }

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
          value: _AccountAction.logout,
          child: Text('Cerrar Sesión'),
        ),
      ],
    );
  }
}

class _TabsBar extends StatelessWidget {
  final bool isWide;
  const _TabsBar({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        // Siempre usamos Wrap para que los chips se ajusten y nunca hagan overflow.
        return SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final t in controller.tabs)
                ChoiceChip(
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  selectedColor: t.category == InvoiceCategory.rechazados
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primaryContainer,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.label,
                        style: TextStyle(
                          color: controller.currentCategory == t.category
                              ? (t.category == InvoiceCategory.rechazados
                                    ? Theme.of(context).colorScheme.onError
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _Badge(count: controller.countFor(t.category)),
                    ],
                  ),
                  selected: controller.currentCategory == t.category,
                  onSelected: (_) => controller.loadCategory(t.category),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  const _DateRangeSelector();

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDateRange(
    BuildContext context,
    HomeController controller,
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
    return GetBuilder<HomeController>(
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
                    '${controller.getFilteredInvoices().length} resultado(s)',
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
