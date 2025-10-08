import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
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
      // Crear el JSON scenario como en response.json
      final scenarioData = _createScenarioFromInvoice(invoice);
      final jsonString = JsonEncoder.withIndent('  ').convert(scenarioData);

      // Mostrar en consola (print)
      debugPrint('[HomeController] ===== DATOS DEL SCENARIO =====');
      debugPrint(
        '[HomeController] Factura: ${invoice.fDocumento ?? invoice.encf}',
      );
      debugPrint('[HomeController] JSON Scenario:');
      debugPrint(jsonString);
      debugPrint('[HomeController] ================================');

      // Mostrar el diálogo con la información
      _showInvoiceDataDialog(scenarioData);
    } catch (e) {
      debugPrint('[HomeController] Error creando scenario: $e');
      Get.snackbar(
        'Error',
        'No se pudo procesar la factura: $e',
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

  // Método para crear el scenario JSON desde una factura
  Map<String, dynamic> _createScenarioFromInvoice(Datum invoice) {
    return {
      "scenario": {
        "CasoPrueba": invoice.encf ?? invoice.fDocumento ?? "",
        "Version": "1.0",
        "TipoeCF": _extractTipoeCF(invoice),
        "ENCF": invoice.encf ?? invoice.fDocumento ?? "",
        "FechaVencimientoSecuencia": _formatDateForScenario(
          DateTime.now().add(Duration(days: 365)),
        ),
        "IndicadorNotaCredito": "#e",
        "IndicadorEnvioDiferido": "#e",
        "IndicadorMontoGravado": "#e",
        "TipoIngresos": "01",
        "TipoPago": "1",
        "FechaLimitePago": "#e",
        "TerminoPago": "#e",
        "FormaPago[1]": "1",
        "MontoPago[1]": invoice.montototal ?? "0.00",
        "FormaPago[2]": "#e",
        "MontoPago[2]": "#e",
        "RNCEmisor": "132177975", // Valor por defecto
        "RazonSocialEmisor": "DOCUMENTOS ELECTRONICOS DE 02",
        "NombreComercial": "DOCUMENTOS ELECTRONICOS DE 02",
        "DireccionEmisor":
            "AVE. ISABEL AGUIAR NO. 269, ZONA INDUSTRIAL DE HERRERA",
        "Municipio": "010100",
        "Provincia": "010000",
        "TelefonoEmisor[1]": "809-472-7676",
        "CorreoEmisor": "info@empresa.com",
        "WebSite": "www.facturaelectronica.com",
        "CodigoVendedor":
            "AA0000000100000000010000000002000000000300000000050000000006",
        "NumeroFacturaInterna": invoice.fDocumento ?? invoice.encf ?? "",
        "FechaEmision": _formatDateForScenario(
          invoice.fechaemision ?? DateTime.now(),
        ),
        "RNCComprador": invoice.rnccomprador ?? "",
        "RazonSocialComprador": invoice.razonsocialcomprador?.toString() ?? "",
        "ContactoComprador": "CONTACTO COMPRADOR",
        "CorreoComprador": "comprador@email.com",
        "DireccionComprador": "DIRECCION DEL COMPRADOR",
        "MunicipioComprador": "010100",
        "ProvinciaComprador": "010000",
        "MontoExento": invoice.montototal ?? "0.00",
        "MontoTotal": invoice.montototal ?? "0.00",
        "TipoMoneda": "DOP",
        "NumeroLinea[1]": "1",
        "IndicadorFacturacion[1]": "4",
        "NombreItem[1]": "PRODUCTO/SERVICIO",
        "IndicadorBienoServicio[1]": "1",
        "CantidadItem[1]": "1.00",
        "UnidadMedida[1]": "47",
        "PrecioUnitarioItem[1]": invoice.montototal ?? "0.00",
        "MontoItem[1]": invoice.montototal ?? "0.00",
      },
    };
  }

  // Método para extraer el tipo de eCF
  String _extractTipoeCF(Datum invoice) {
    final encf = invoice.encf ?? invoice.fDocumento ?? "";
    if (encf.startsWith("E31")) return "31";
    if (encf.startsWith("E32")) return "32";
    if (encf.startsWith("E33")) return "33";
    if (encf.startsWith("E34")) return "34";
    if (encf.startsWith("E41")) return "41";
    if (encf.startsWith("E43")) return "43";
    if (encf.startsWith("E44")) return "44";
    if (encf.startsWith("E45")) return "45";
    if (encf.startsWith("E46")) return "46";
    if (encf.startsWith("E47")) return "47";
    return "33"; // Por defecto
  }

  // Método para formatear fecha para el scenario
  String _formatDateForScenario(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  // Método para mostrar el diálogo con la información
  void _showInvoiceDataDialog(Map<String, dynamic> scenarioData) {
    final jsonString = JsonEncoder.withIndent('  ').convert(scenarioData);

    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.8,
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Datos del Scenario',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: jsonString));
                          Get.snackbar(
                            'Copiado',
                            'JSON copiado al portapapeles',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copiar JSON',
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonString,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab {
  final String label;
  final InvoiceCategory category;
  const _HomeTab(this.label, this.category);
}
