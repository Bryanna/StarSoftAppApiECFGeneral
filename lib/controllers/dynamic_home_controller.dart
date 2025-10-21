import 'package:facturacion/models/erp_invoice_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../models/erp_invoice.dart';
import '../services/dynamic_tabs_service.dart';
import '../services/fake_data_service.dart';
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
  Future<void> loadAllInvoices() async {
    debugPrint('[DynamicHomeController] loadAllInvoices start');
    loading = true;
    _clearErrors();
    update();

    try {
      // Cargar datos desde el servicio
      final datumList = await FakeDataService.generateFakeInvoicesFromJson();
      allInvoices = datumList
          .map((datum) => _convertDatumToERPInvoice(datum))
          .toList();

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
  Future<void> refresh() async {
    debugPrint('[DynamicHomeController] refresh');
    await loadAllInvoices();
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

  /// Convierte un Datum del modelo legacy a ERPInvoice
  ERPInvoice _convertDatumToERPInvoice(dynamic datum) {
    return ERPInvoice(
      fFacturaSecuencia: datum.fFacturaSecuencia,
      version: datum.version,
      tipoecf: datum.tipoecf,
      encf: datum.encf,
      fechavencimientosecuencia: datum.fechavencimientosecuencia?.toString(),
      indicadorenviodiferido: datum.indicadorenviodiferido?.toString(),
      indicadormontogravado: datum.indicadormontogravado,
      indicadornotacredito: datum.indicadornotacredito,
      tipoingresos: datum.tipoingresos,
      tipopago: datum.tipopago,
      formapago1: datum.formapago1,
      montopago1: datum.montopago1,
      formapago2: datum.formapago2,
      montopago2: datum.montopago2,
      rncemisor: datum.rncemisor,
      razonsocialemisor: datum.razonsocialemisor?.toString(),
      nombrecomercial: datum.nombrecomercial?.toString(),
      direccionemisor: datum.direccionemisor?.toString(),
      municipio: datum.municipio,
      provincia: datum.provincia,
      telefonoemisor1: datum.telefonoemisor1?.toString(),
      correoemisor: datum.correoemisor,
      website: datum.website?.toString(),
      actividadeconomica: datum.actividadeconomica?.toString(),
      codigovendedor: datum.codigovendedor?.toString(),
      numerofacturainterna: datum.numerofacturainterna?.toString(),
      numeropedidointerno: datum.numeropedidointerno?.toString(),
      zonaventa: datum.zonaventa?.toString(),
      fechaemision: datum.fechaemision?.toString(),
      rnccomprador: datum.rnccomprador,
      razonsocialcomprador: datum.razonsocialcomprador?.toString(),
      contactocomprador: datum.contactocomprador?.toString(),
      correocomprador: datum.correocomprador?.toString(),
      direccioncomprador: datum.direccioncomprador,
      municipiocomprador: datum.municipiocomprador,
      provinciacomprador: datum.provinciacomprador,
      fechaentrega: datum.fechaentrega?.toString(),
      telefonoadicional: datum.telefonoadicional?.toString(),
      fechaordencompra: datum.fechaordencompra?.toString(),
      numeroordencompra: datum.numeroordencompra,
      montogravadototal: datum.montogravadototal,
      montoexento: datum.montoexento,
      totalitbis: datum.totalitbis,
      montototal: datum.montototal,
      valorpagar: datum.valorpagar,
      totalitbisretenido: datum.totalitbisretenido,
      totalisrretencion: datum.totalisrretencion,
      tipomoneda: datum.tipomoneda,
      tipocambio: datum.tipocambio,
      fechahorafirma: datum.fechahorafirma?.toString(),
      codigoseguridad: datum.codigoseguridad?.toString(),
      linkOriginal: datum.linkOriginal,
      tipoComprobante: datum.tipoComprobante,
      detalleFactura: datum.detalleFactura,
      tipoTabEnvioFactura: datum.tipoTabEnvioFactura,
    );
  }
}
