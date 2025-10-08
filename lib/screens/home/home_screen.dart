import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/invoice.dart';
import '../../models/ui_types.dart';
import '../../models/tipo_comprobante.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/invoice_table.dart';
import 'home_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/firebase_auth_service.dart';
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
        bool matches(Datum inv) {
          String mStr(dynamic v) => (v ?? '').toString().toLowerCase();
          final encf = inv.encf ?? '';
          final alias = aliasDesdeDocumento(encf);
          final razonSocial = inv.razonsocialcomprador?.toString() ?? '';

          return q.isEmpty ||
              mStr(encf).contains(q) ||
              mStr(inv.fDocumento).contains(q) ||
              mStr(razonSocial).contains(q) ||
              mStr(inv.rnccomprador).contains(q) ||
              mStr(inv.montototal).contains(q) ||
              mStr(alias).contains(q);
        }

        final isWideApp = MediaQuery.of(context).size.width > 900;
        return Scaffold(
          backgroundColor: const Color(0xFFf6f7fb),
          appBar: AppBar(
            backgroundColor: const Color(0xFF005285),
            centerTitle: false,
            title: SizedBox(
              width: isWideApp ? 420 : 240,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: TextField(
                  onChanged: controller.setQuery,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Buscar facturas, pacientes, documentos…',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            actions: [_AccountMenuButton()],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final filtered = q.isEmpty
                  ? controller.invoices
                  : controller.invoices.where(matches).toList();
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestión de Facturas Electrónicas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tabs
                    _TabsBar(isWide: isWide),
                    const SizedBox(height: 16),

                    // Encabezado y botones de acción (Refresh y Enviar)
                    Row(
                      children: [
                        Text(
                          _titleFor(controller.currentCategory),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
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
                              color: const Color(0xFF2E6B5A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.arrowsRotate,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 20),
                                const Text(
                                  'Refresh',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: filtered.isEmpty
                              ? null
                              : () => controller.sendInvoice(filtered.first),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            height: 40,
                            width: 120,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF005285),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.paperPlane,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  'Enviar',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
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
                          : _buildContent(controller, filtered),
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

  Widget _buildContent(HomeController controller, List<Datum> filtered) {
    // Si hay error de configuración ERP
    if (controller.hasERPConfigError) {
      return _buildERPConfigError(
        message: controller.errorMessage ?? 'URL del ERP no configurado',
      );
    }

    // Si no hay facturas pendientes
    if (controller.hasNoInvoicesError) {
      return _buildErrorState(
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
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: InvoiceTable(
        invoices: filtered,
        onView: controller.viewDetails,
        onSend: controller.sendInvoice,
        onDownload: controller.downloadInvoice,
      ),
    );
  }

  Widget _buildErrorState({
    required IconData icon,
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(32.0),
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
              style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                foregroundColor: Colors.white,
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

  Widget _buildERPConfigError({required String message}) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              size: 64,
              color: Colors.orange.shade600,
            ),
            const SizedBox(height: 16),
            const Text(
              'Configuración Requerida',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'URL del ERP no configurado.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Contacta con un Administrador del sistema.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Configuración pendiente',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
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
      icon: const Icon(FontAwesomeIcons.user, color: Colors.white),
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
                      ? const Color(0xFFdd1416)
                      : null,
                  backgroundColor: t.category == InvoiceCategory.rechazados
                      ? const Color(0xFFffebee)
                      : null,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.label,
                        style: TextStyle(
                          color: t.category == InvoiceCategory.rechazados
                              ? Colors.black
                              : null,
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
        color: const Color(0xFF005285),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
