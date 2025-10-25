import 'package:facturacion/models/erp_invoice_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/erp_invoice.dart';
import '../models/ui_types.dart';
import '../services/dynamic_tabs_service.dart';
import '../services/invoice_service.dart';
import '../widgets/simple_invoice_modal.dart';

/// Controlador dinámico que genera tabs basados en los tipos de ENCF encontrados en los datos
class DynamicHomeController extends GetxController {
  final _service = InvoiceService();

  // Estado
  bool loading = false;
  List<ERPInvoice> allInvoices = [];
  List<ERPInvoice> filteredInvoices = [];
  List<DynamicTab> dynamicTabs = [];
  DynamicTab? currentTab;
  String query = '';

  // Estados de error
  bool hasERPConfigError = false;
  bool hasNoInvoicesError = false;
  bool hasConnectionError = false;
  String? errorMessage;

  // Selección múltiple
  final Set<String> selectedInvoiceIds = {};
  bool get hasSelection => selectedInvoiceIds.isNotEmpty;
  bool get isAllSelected =>
      filteredInvoices.isNotEmpty &&
      selectedInvoiceIds.length == filteredInvoices.length;

  // Filtro de fechas
  DateTime? startDate;
  DateTime? endDate;
  bool get hasDateFilter => startDate != null || endDate != null;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[DynamicHomeController] onInit');
    loadAllInvoices();
  }

  /// Carga todas las facturas y genera tabs dinámicos
  Future<void> loadAllInvoices({bool forceReal = false}) async {
    debugPrint(
      '[DynamicHomeController] loadAllInvoices start (forceReal: $forceReal)',
    );
    loading = true;
    _clearErrors();
    update();

    try {
      // Cargar datos desde el servicio (puede ser real o fake según configuración)
      allInvoices = await _service.fetchInvoices(
        InvoiceCategory.todos,
        forceReal: forceReal,
      );

      debugPrint(
        '[DynamicHomeController] Loaded ${allInvoices.length} invoices',
      );

      // Generar tabs dinámicos basados en los datos
      dynamicTabs = DynamicTabsService.generateTabsFromInvoices(allInvoices);
      debugPrint(
        '[DynamicHomeController] Generated ${dynamicTabs.length} dynamic tabs',
      );

      // Seleccionar el primer tab por defecto
      if (dynamicTabs.isNotEmpty) {
        currentTab = dynamicTabs.first;
        _filterInvoicesByCurrentTab();
      }

      // Debug: Imprimir estado después de cargar
      debugPrintState();
    } catch (e) {
      _handleError(e);
      allInvoices = [];
      dynamicTabs = DynamicTabsService.generateTabsFromInvoices([]);
    } finally {
      loading = false;
      update();
    }
  }

  /// Cambia al tab especificado
  void selectTab(DynamicTab tab) {
    debugPrint('[DynamicHomeController] selectTab: ${tab.label}');
    currentTab = tab;
    selectedInvoiceIds.clear(); // Limpiar selección al cambiar tab
    _filterInvoicesByCurrentTab();
    update();
  }

  /// Filtra las facturas según el tab actual
  void _filterInvoicesByCurrentTab() {
    if (currentTab == null) {
      filteredInvoices = [];
      return;
    }

    filteredInvoices = DynamicTabsService.filterInvoicesByTab(
      allInvoices,
      currentTab!,
    );

    debugPrint(
      '[DynamicHomeController] Filtered to ${filteredInvoices.length} invoices for tab: ${currentTab!.label}',
    );
  }

  /// Actualiza la consulta de búsqueda
  void setQuery(String newQuery) {
    query = newQuery;
    update();
  }

  /// Obtiene las facturas filtradas por búsqueda y fechas
  List<ERPInvoice> getSearchFilteredInvoices() {
    var result = filteredInvoices;

    // Aplicar filtro de fechas
    if (hasDateFilter) {
      result = result.where((invoice) {
        final invoiceDate = invoice.fechaemisionDateTime;
        if (invoiceDate == null) return false;

        if (startDate != null && invoiceDate.isBefore(startDate!)) {
          return false;
        }

        if (endDate != null) {
          final endOfDay = DateTime(
            endDate!.year,
            endDate!.month,
            endDate!.day,
            23,
            59,
            59,
          );
          if (invoiceDate.isAfter(endOfDay)) {
            return false;
          }
        }

        return true;
      }).toList();
    }

    // Aplicar filtro de búsqueda
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((invoice) => invoice.matchesSearch(q)).toList();
    }

    return result;
  }

  /// Refresca los datos
  @override
  Future<void> refresh() async {
    debugPrint('[DynamicHomeController] refresh');
    await loadAllInvoices();
  }

  /// Fuerza la carga desde el endpoint real (no fake data)
  Future<void> loadFromRealEndpoint() async {
    debugPrint(
      '[DynamicHomeController] loadFromRealEndpoint - forcing real data',
    );
    await loadAllInvoices(forceReal: true);
  }

  // Métodos de selección
  void toggleSelection(String encf) {
    if (selectedInvoiceIds.contains(encf)) {
      selectedInvoiceIds.remove(encf);
    } else {
      selectedInvoiceIds.add(encf);
    }
    update();
  }

  void toggleSelectAll() {
    final searchFiltered = getSearchFilteredInvoices();
    if (isAllSelected) {
      selectedInvoiceIds.clear();
    } else {
      selectedInvoiceIds.clear();
      for (final inv in searchFiltered) {
        if (inv.encf != null) {
          selectedInvoiceIds.add(inv.encf!);
        }
      }
    }
    update();
  }

  void clearSelection() {
    selectedInvoiceIds.clear();
    update();
  }

  bool isSelected(String? encf) {
    if (encf == null) return false;
    return selectedInvoiceIds.contains(encf);
  }

  // Métodos de filtro de fechas
  void setDateRange(DateTime? start, DateTime? end) {
    startDate = start;
    endDate = end;
    update();
  }

  void clearDateFilter() {
    startDate = null;
    endDate = null;
    update();
  }

  // Métodos de acciones de facturas
  void viewInvoiceDetails(ERPInvoice invoice) {
    // Mostrar modal simple en lugar de navegar a otra pantalla
    showSimpleInvoiceModal(context: Get.context!, invoice: invoice);
  }

  void previewInvoice(ERPInvoice invoice) {
    // Mostrar vista previa mejorada
    // Esta función se llamará desde el widget que tenga acceso al context
  }

  void sendInvoice(ERPInvoice invoice) {
    // Enviar factura individual
    // TODO: Implementar envío individual
  }

  void sendSelectedInvoices() {
    if (!hasSelection) return;

    // Obtener facturas seleccionadas
    final selectedInvoices = filteredInvoices
        .where(
          (inv) => inv.encf != null && selectedInvoiceIds.contains(inv.encf!),
        )
        .toList();

    // TODO: Implementar envío en lote
    debugPrint(
      '[DynamicHomeController] Enviando ${selectedInvoices.length} facturas seleccionadas',
    );
  }

  // Métodos auxiliares para manejo de errores
  void _clearErrors() {
    hasERPConfigError = false;
    hasNoInvoicesError = false;
    hasConnectionError = false;
    errorMessage = null;
  }

  void _handleError(dynamic error) {
    debugPrint('[DynamicHomeController] Error: $error');

    if (error.toString().contains('ERP not configured')) {
      hasERPConfigError = true;
      errorMessage =
          'URL del ERP no configurado. Contacta con un Administrador del sistema.';
    } else if (error.toString().contains('No invoices found')) {
      hasNoInvoicesError = true;
      errorMessage = 'No hay facturas pendientes en el ERP.';
    } else {
      hasConnectionError = true;
      errorMessage = 'Error inesperado: $error';
    }
  }



  /// Método de debug para verificar el estado del controlador
  void debugPrintState() {
    debugPrint('=== DEBUG DYNAMIC HOME CONTROLLER ===');
    debugPrint('Loading: $loading');
    debugPrint('All invoices: ${allInvoices.length}');
    debugPrint('Filtered invoices: ${filteredInvoices.length}');
    debugPrint('Dynamic tabs: ${dynamicTabs.length}');
    debugPrint('Current tab: ${currentTab?.label ?? "null"}');

    for (int i = 0; i < allInvoices.take(3).length; i++) {
      final invoice = allInvoices[i];
      debugPrint(
        'Invoice $i: ENCF=${invoice.encf}, TipoECF=${invoice.tipoecf}, TipoTab=${invoice.tipoTabEnvioFactura}',
      );
    }

    for (int i = 0; i < dynamicTabs.length; i++) {
      final tab = dynamicTabs[i];
      debugPrint(
        'Tab $i: ${tab.label} (${tab.count}) - TabType: ${tab.tabType}, EncfType: ${tab.encfType}',
      );
    }
    debugPrint('=====================================');
  }
}
