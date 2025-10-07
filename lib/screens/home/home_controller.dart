import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import '../../models/ui_types.dart';
import '../../models/tipo_comprobante.dart';
import '../../services/invoice_service.dart';
import '../../routes/app_routes.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../services/invoice_pdf_service.dart';

class HomeController extends GetxController {
  final _service = InvoiceService();

  // Estado
  InvoiceCategory currentCategory = InvoiceCategory.pacientes;
  bool loading = false;
  List<Datum> invoices = [];
  String query = '';

  // Estados de error específicos
  bool hasERPConfigError = false;
  bool hasNoInvoicesError = false;
  bool hasConnectionError = false;
  String? errorMessage;

  // Cache por categoría y conteos
  final Map<InvoiceCategory, List<Datum>> _cache = {};

  final List<_HomeTab> tabs = const [
    _HomeTab('Facturas Paciente', InvoiceCategory.pacientes),
    _HomeTab('Facturas ARS', InvoiceCategory.ars),
    _HomeTab('Notas Crédito', InvoiceCategory.notasCredito),
    _HomeTab('Notas Débito', InvoiceCategory.notasDebito),
    _HomeTab('Facturas Gastos', InvoiceCategory.gastos),
    _HomeTab('Documentos Enviados', InvoiceCategory.enviados),
    _HomeTab('Documentos Rechazados', InvoiceCategory.rechazados),
  ];

  @override
  void onInit() {
    super.onInit();
    debugPrint('[HomeController] onInit');
    _prefetchCounts();
    loadCategory(InvoiceCategory.pacientes);
  }

  Future<void> _prefetchCounts() async {
    // Realiza una sola llamada y rellena el cache para todas las pestañas.
    debugPrint('[HomeController] prefetchCounts start');

    try {
      _clearErrors();
      final list = await _service.fetchInvoices(InvoiceCategory.pacientes);
      debugPrint('[HomeController] prefetchCounts got ${list.length} items');
      // Derivamos alias corto del tipo de comprobante a partir del documento/NCF.
      String aliasFor(Datum inv) {
        final base =
            inv.fDocumento ??
            inv.encf ??
            inv.tipoecf ??
            inv.tipoComprobante ??
            '';
        return aliasDesdeDocumento(base) ??
            (inv.tipoComprobante ?? inv.tipoecf ?? '');
      }

      // Construimos listas por categoría en cliente.
      DisplayStatus statusOf(Datum i) {
        if (i.fAnulada == true) return DisplayStatus.rechazada;
        if (i.fPagada == true) return DisplayStatus.aprobada;
        final enviado =
            (i.linkOriginal != null && i.linkOriginal!.isNotEmpty) ||
            i.fechaHoraFirma != null;
        if (enviado) return DisplayStatus.enviado;
        return DisplayStatus.pendiente;
      }

      final pacientes = list.where((i) {
        final a = aliasFor(i);
        return a == 'Consumo' || a == 'Crédito Fiscal';
      }).toList();
      final ars = list.where((i) => i.fArsNombre != null).toList();
      final notasCredito = list
          .where((i) => aliasFor(i) == 'Nota Crédito')
          .toList();
      final notasDebito = list
          .where((i) => aliasFor(i) == 'Nota Débito')
          .toList();
      final gastos = list
          .where((i) => aliasFor(i) == 'Gastos Menores')
          .toList();
      // Enviados: estado 'Enviado' explícito (no pendiente, no aprobada, no rechazada)
      final enviados = list
          .where((i) => statusOf(i) == DisplayStatus.enviado)
          .toList();
      // Rechazados: estado 'Rechazada'
      final rechazados = list
          .where((i) => statusOf(i) == DisplayStatus.rechazada)
          .toList();

      _cache[InvoiceCategory.pacientes] = pacientes;
      _cache[InvoiceCategory.ars] = ars;
      _cache[InvoiceCategory.notasCredito] = notasCredito;
      _cache[InvoiceCategory.notasDebito] = notasDebito;
      _cache[InvoiceCategory.gastos] = gastos;
      _cache[InvoiceCategory.enviados] = enviados;
      _cache[InvoiceCategory.rechazados] = rechazados;
      update();
    } catch (e) {
      _handleError(e);
    }
  }

  int countFor(InvoiceCategory category) {
    return _cache[category]?.length ?? 0;
  }

  Future<void> loadCategory(InvoiceCategory category) async {
    debugPrint('[HomeController] loadCategory=$category');
    currentCategory = category;
    loading = true;
    _clearErrors();
    update();

    try {
      // usa cache si existe
      if (_cache.containsKey(category)) {
        invoices = _cache[category]!;
        debugPrint('[HomeController] using cache: ${invoices.length} items');
        loading = false;
        update();
        return;
      }

      final list = await _service.fetchInvoices(category);
      _cache[category] = list;
      invoices = list;
      debugPrint('[HomeController] loaded ${list.length} items from service');
    } catch (e) {
      _handleError(e);
      invoices = [];
    } finally {
      loading = false;
      update();
    }
  }

  Future<void> refreshCurrentCategory() async {
    debugPrint('[HomeController] refresh current=$currentCategory');
    loading = true;
    _clearErrors();
    update();

    try {
      final list = await _service.fetchInvoices(currentCategory);
      _cache[currentCategory] = list;
      invoices = list;
    } catch (e) {
      _handleError(e);
      invoices = [];
    } finally {
      loading = false;
      update();
    }
  }

  void setQuery(String v) {
    query = v;
    update();
  }

  // Acciones del menú
  void viewDetails(Datum invoice) {
    Get.toNamed(AppRoutes.INVOICE_PREVIEW, arguments: invoice);
  }

  Future<void> sendInvoice(Datum invoice) async {
    try {
      final bytes = await InvoicePdfService.buildPdf(PdfPageFormat.a4, invoice);
      final name =
          'Factura_${invoice.fDocumento ?? invoice.encf ?? 'CENSAVID'}.pdf';
      await Printing.sharePdf(bytes: bytes, filename: name);
      Get.snackbar(
        'Enviado',
        '${invoice.fDocumento ?? '-'} compartido correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo enviar: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> downloadInvoice(Datum invoice) async {
    try {
      final bytes = await InvoicePdfService.buildPdf(PdfPageFormat.a4, invoice);
      final name =
          'Factura_${invoice.fDocumento ?? invoice.encf ?? 'CENSAVID'}.pdf';
      // En web, sharePdf inicia descarga del archivo
      await Printing.sharePdf(bytes: bytes, filename: name);
      Get.snackbar(
        'Descargado',
        '${invoice.fDocumento ?? '-'} descargado',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo descargar: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Métodos auxiliares para manejo de errores
  void _clearErrors() {
    hasERPConfigError = false;
    hasNoInvoicesError = false;
    hasConnectionError = false;
    errorMessage = null;
  }

  void _handleError(dynamic error) {
    debugPrint('[HomeController] Error: $error');

    if (error is ERPNotConfiguredException) {
      hasERPConfigError = true;
      errorMessage =
          'URL del ERP no configurado. Contacta con un Administrador del sistema.';
    } else if (error is NoInvoicesFoundException) {
      hasNoInvoicesError = true;
      errorMessage = 'No hay facturas pendientes en el ERP.';
    } else if (error is ERPConnectionException) {
      hasConnectionError = true;
      errorMessage = 'Error conectando al ERP: ${error.message}';
    } else {
      hasConnectionError = true;
      errorMessage = 'Error inesperado: $error';
    }
  }
}

class _HomeTab {
  final String label;
  final InvoiceCategory category;
  const _HomeTab(this.label, this.category);
}
