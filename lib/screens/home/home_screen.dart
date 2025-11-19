import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../models/erp_invoice.dart';
import '../../models/erp_invoice_extensions.dart';
import '../../models/ui_types.dart';
import '../../routes/app_routes.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/user_service.dart';
import '../../widgets/invoice_table.dart';
import 'home_controller.dart';

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
                    // Tabs dinámicos basados en tipos de ENCF
                    _DynamicTabsBar(isWide: isWide),
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
    final controller = Get.find<HomeController>();

    // Si hay un tipo de comprobante específico seleccionado, usar su display
    if (controller.currentTipoComprobante != null &&
        controller.invoices.isNotEmpty) {
      final firstInvoice = controller.invoices.first;
      return firstInvoice.tipoComprobanteDisplay;
    }

    // Fallback a títulos estáticos por categoría
    switch (category) {
      case InvoiceCategory.todos:
        return 'Todas las Facturas';
      case InvoiceCategory.pacientes:
        return 'Facturas de Pacientes';
      case InvoiceCategory.ars:
        return 'Facturas ARS';
      case InvoiceCategory.notasCredito:
        return 'Notas de Crédito';
      case InvoiceCategory.notasDebito:
        return 'Notas de Débito';
      case InvoiceCategory.gastos:
        return 'Gastos Menores';
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
        onPreview: controller.previewInvoice,
        onPrint80mm: controller.print80mmReceipt,
        onPreviewArsHeader: controller.previewArsHeader,
        onPreviewArsDetail: controller.previewArsDetail,
        onToggleSelection: controller.toggleSelection,
        onToggleSelectAll: controller.toggleSelectAll,
        isSelected: controller.isSelected,
        isAllSelected: controller.isAllSelected,
        isArsTab: controller.currentCategory == InvoiceCategory.ars,
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

class _DynamicTabsBar extends StatelessWidget {
  final bool isWide;
  const _DynamicTabsBar({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        // Generar tabs dinámicos basados en los tipos de ENCF encontrados
        final sourceList = controller.allInvoices.isNotEmpty ? controller.allInvoices : controller.invoices;
final dynamicTabs = _generateDynamicTabs(sourceList);

        return SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Tab "Todos" siempre presente
              ChoiceChip(
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
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
                    const Text('📋', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'Todos',
                      style: TextStyle(
                        color:
                            controller.currentCategory == InvoiceCategory.todos
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight:
                            controller.currentCategory == InvoiceCategory.todos
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _Badge(count: controller.allInvoices.length),
                  ],
                ),
                selected:
                    controller.currentCategory == InvoiceCategory.todos &&
                    controller.currentTipoComprobante == null,
                onSelected: (_) =>
                    controller.loadCategory(InvoiceCategory.todos),
              ),

              // Tabs dinámicos por tipo de comprobante
              for (final tab in dynamicTabs)
                ChoiceChip(
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  selectedColor: tab.category == InvoiceCategory.rechazados
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
                      Text(tab.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        tab.label,
                        style: TextStyle(
                          color: _isTabSelected(controller, tab)
                              ? (tab.category == InvoiceCategory.rechazados
                                  ? Theme.of(context).colorScheme.onError
                                  : Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer)
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: _isTabSelected(controller, tab)
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _Badge(count: tab.count),
                    ],
                  ),
                  selected: _isTabSelected(controller, tab),
                  onSelected: (_) => _selectTab(controller, tab),
                ),
            ],
          ),
        );
      },
    );
  }

  List<_DynamicTab> _generateDynamicTabs(List<ERPInvoice> invoices) {
    if (invoices.isEmpty) return [];

    // Mapear tipos de comprobante usando los primeros 3 caracteres del ENCF
    final Map<String, int> tipoComprobanteCounts = {};
    final Map<String, String> tipoComprobanteLabels = {};
    final Map<String, String> tipoComprobanteIcons = {};

    // Contar tipos de comprobante usando la extensión
    for (final invoice in invoices) {
      final tipoComprobante = _extractTipoComprobanteFromEncf(invoice);
      if (tipoComprobante != null) {
        tipoComprobanteCounts[tipoComprobante] =
            (tipoComprobanteCounts[tipoComprobante] ?? 0) + 1;

        // Usar la función tipoComprobanteDisplay de las extensiones
        tipoComprobanteLabels[tipoComprobante] = invoice.tipoComprobanteDisplay;
        tipoComprobanteIcons[tipoComprobante] = _getIconForTipoComprobante(
          tipoComprobante,
        );
      }
    }

    // Generar tabs dinámicos
    final List<_DynamicTab> tabs = [];

    // Primero: tabs por tipo_tab_envio_factura (después de 'Todos')
    final arsCount = invoices
        .where((inv) => (inv.tipoTabEnvioFactura?.toLowerCase().contains('ars') ?? false))
        .length;
    final pacienteCount = invoices
        .where((inv) => (inv.tipoTabEnvioFactura?.toLowerCase().contains('paciente') ?? false))
        .length;

    // Mostrar siempre estos tabs, aunque el conteo sea 0
    tabs.add(
      _DynamicTab(
        label: 'ARS',
        icon: '🏥',
        category: InvoiceCategory.ars,
        count: arsCount,
        tipoComprobante: null,
        tabType: 'FacturaArs',
        isSpecificType: true,
      ),
    );

    tabs.add(
      _DynamicTab(
        label: 'Pacientes',
        icon: '👤',
        category: InvoiceCategory.pacientes,
        count: pacienteCount,
        tipoComprobante: null,
        tabType: 'FacturaPaciente',
        isSpecificType: true,
      ),
    );

    // Luego: tabs por tipo de comprobante (ENCF)
    for (final entry in tipoComprobanteCounts.entries) {
      final tipoComprobante = entry.key;
      final count = entry.value;
      final label =
          tipoComprobanteLabels[tipoComprobante] ?? 'Tipo $tipoComprobante';
      final icon = tipoComprobanteIcons[tipoComprobante] ?? '📄';
      final category = _mapTipoComprobanteToCategory(tipoComprobante);

      tabs.add(
        _DynamicTab(
          label: label,
          icon: icon,
          category: category,
          count: count,
          tipoComprobante: tipoComprobante,
          isSpecificType: true,
        ),
      );
    }

    // Agregar tabs de estado si hay facturas con esos estados
    final enviados = invoices.where((inv) => _isEnviado(inv)).length;
    final rechazados = invoices.where((inv) => _isRechazado(inv)).length;

    if (enviados > 0) {
      tabs.add(
        _DynamicTab(
          label: 'Enviados',
          icon: '✅',
          category: InvoiceCategory.enviados,
          count: enviados,
          tipoComprobante: null,
          isSpecificType: false,
        ),
      );
    }

    if (rechazados > 0) {
      tabs.add(
        _DynamicTab(
          label: 'Rechazados',
          icon: '❌',
          category: InvoiceCategory.rechazados,
          count: rechazados,
          tipoComprobante: null,
          isSpecificType: false,
        ),
      );
    }

    return tabs;
  }

  String? _extractTipoComprobanteFromEncf(ERPInvoice invoice) {
    // Usar los primeros 3 caracteres del ENCF como especifica el usuario
    if (invoice.encf != null && invoice.encf!.length >= 3) {
      return invoice.encf!.substring(0, 3).toUpperCase();
    }

    // Fallback: usar tipoecf si no hay encf
    if (invoice.tipoecf != null && invoice.tipoecf!.isNotEmpty) {
      // Si tipoecf es solo números (ej: "32"), agregar prefijo para NCF tradicionales
      if (RegExp(r'^\d+$').hasMatch(invoice.tipoecf!)) {
        return 'B${invoice.tipoecf!.padLeft(2, '0')}'; // ej: "32" -> "B32"
      }
      return invoice.tipoecf!.toUpperCase();
    }

    return null;
  }

  InvoiceCategory _mapTipoComprobanteToCategory(String tipoComprobante) {
    // Mapear tipos de comprobante a categorías existentes
    switch (tipoComprobante) {
      // e-CF Crédito Fiscal y Consumo -> Pacientes
      case 'E31':
      case 'E32':
      case 'B01':
      case 'C01':
      case 'P01':
      case 'B02':
      case 'C02':
      case 'P02':
        return InvoiceCategory.pacientes;

      // Notas de Débito
      case 'E33':
      case 'B03':
      case 'C03':
      case 'P03':
        return InvoiceCategory.notasDebito;

      // Notas de Crédito
      case 'E34':
      case 'B04':
      case 'C04':
      case 'P04':
        return InvoiceCategory.notasCredito;

      // Gastos Menores
      case 'E43':
      case 'B13':
      case 'C13':
      case 'P13':
        return InvoiceCategory.gastos;

      // Compras -> ARS (asumiendo que las compras son para ARS)
      case 'E41':
      case 'B11':
      case 'C11':
      case 'P11':
        return InvoiceCategory.ars;

      default:
        return InvoiceCategory.todos;
    }
  }

  bool _isEnviado(ERPInvoice invoice) {
    // Priorizar estado del endpoint si existe
    final code = invoice.estadoCode;
    if (code != null) {
      return code == 3; // 3 = Enviado
    }
    // Fallback a la lógica anterior
    return (invoice.linkOriginal != null && invoice.linkOriginal!.isNotEmpty) ||
        (invoice.fechahorafirma != null && invoice.fechahorafirma!.isNotEmpty);
  }

  bool _isRechazado(ERPInvoice invoice) {
    // Priorizar estado del endpoint si existe
    final code = invoice.estadoCode;
    if (code != null) {
      return code == 2; // 2 = Rechazado
    }
    // Fallback a la lógica anterior
    return invoice.fAnulada == true;
  }

  String _getIconForTipoComprobante(String tipoComprobante) {
    switch (tipoComprobante) {
      // e-CF (Comprobantes Electrónicos)
      case 'E31':
        return '💰'; // Crédito Fiscal Electrónico
      case 'E32':
        return '🛒'; // Consumo Electrónico
      case 'E33':
        return '📈'; // Nota de Débito Electrónica
      case 'E34':
        return '📉'; // Nota de Crédito Electrónica
      case 'E41':
        return '🏪'; // Compras Electrónico
      case 'E43':
        return '💸'; // Gastos Menores Electrónico
      case 'E44':
        return '⚖️'; // Regímenes Especiales Electrónico
      case 'E45':
        return '🏛️'; // Gubernamental Electrónico

      // Comprobantes Fiscales tradicionales (NCF)
      case 'B01':
      case 'C01':
      case 'P01':
        return '💳'; // Factura con Crédito Fiscal
      case 'B02':
      case 'C02':
      case 'P02':
        return '🧾'; // Factura de Consumo
      case 'B03':
      case 'C03':
      case 'P03':
        return '📊'; // Nota de Débito
      case 'B04':
      case 'C04':
      case 'P04':
        return '📋'; // Nota de Crédito
      case 'B11':
      case 'C11':
      case 'P11':
        return '🏥'; // Factura de Compras (ARS)
      case 'B13':
      case 'C13':
      case 'P13':
        return '💵'; // Gastos Menores
      case 'B14':
      case 'C14':
      case 'P14':
        return '📜'; // Regímenes Especiales
      case 'B15':
      case 'C15':
      case 'P15':
        return '🏢'; // Factura Gubernamental

      // Comprobantes Especiales
      case 'B16':
        return '🌍'; // Exportaciones
      case 'B17':
        return '🏭'; // Zona Franca
      case 'B18':
        return '📱'; // Omnipresentes
      case 'B19':
        return '🏖️'; // Turísticas
      case 'B20':
        return '⚡'; // Provisional Electrónicas
      case 'B21':
        return '🎁'; // Donaciones
      case 'B22':
      case 'B23':
        return '🔒'; // Retenciones

      default:
        return '📄'; // Genérico
    }
  }

  // Método para verificar si un tab está seleccionado
  bool _isTabSelected(HomeController controller, _DynamicTab tab) {
    if (tab.isSpecificType) {
      if (tab.tipoComprobante != null) {
        // Para tabs específicos por tipo de comprobante
        return controller.currentTipoComprobante == tab.tipoComprobante;
      }
      if (tab.tabType != null) {
        // Para tabs específicos por tipo_tab_envio_factura
        return controller.currentTabType == tab.tabType;
      }
    }
    // Para tabs generales, verificar la categoría y que no haya filtros específicos activos
    return controller.currentCategory == tab.category &&
        controller.currentTipoComprobante == null &&
        controller.currentTabType == null;
  }

  // Método para seleccionar un tab
  void _selectTab(HomeController controller, _DynamicTab tab) {
    if (tab.isSpecificType) {
      if (tab.tipoComprobante != null) {
        // Cargar por tipo de comprobante específico
        controller.loadByTipoComprobante(tab.tipoComprobante!);
        return;
      }
      if (tab.tabType != null) {
        // Cargar por tipo_tab_envio_factura
        controller.loadByTabType(tab.tabType!);
        return;
      }
    }
    // Cargar por categoría general
    controller.loadCategory(tab.category);
  }
}

class _DynamicTab {
  final String label;
  final String icon;
  final InvoiceCategory category;
  final int count;
  final String? tipoComprobante; // Cambiado de encfType a tipoComprobante
  final String? tabType; // Nuevo: tipo_tab_envio_factura (FacturaArs/Paciente)
  final bool isSpecificType; // Nuevo: indica si es un tipo específico

  const _DynamicTab({
    required this.label,
    required this.icon,
    required this.category,
    required this.count,
    this.tipoComprobante,
    this.tabType,
    this.isSpecificType = false,
  });
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
    final initialStart = controller.startDate;
    final initialEnd = controller.endDate;

    final DateTimeRange? picked = await showDialog<DateTimeRange>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        List<DateTime?> selected = [initialStart, initialEnd];
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text('Seleccionar rango de fechas', style: TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CalendarDatePicker2(
                        config: CalendarDatePicker2Config(
                          calendarType: CalendarDatePicker2Type.range,
                        ),
                        value: selected,
                        onValueChanged: (vals) => setState(() => selected = vals),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: selected.where((d) => d != null).length >= 2
                                  ? () {
                                      final nonNull = selected.where((d) => d != null).toList();
                                      final start = nonNull.first!;
                                      final end = nonNull.last!;
                                      Navigator.of(ctx).pop(DateTimeRange(start: start, end: end));
                                    }
                                  : null,
                              icon: const Icon(Icons.check),
                              label: const Text('Aplicar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
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
