import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facturacion/models/erp_invoice_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';

import '../../models/erp_invoice.dart';
import '../../models/invoice.dart';
import '../../models/tipo_comprobante.dart';
import '../../models/ui_types.dart';
import '../../routes/app_routes.dart';
import '../../services/enhanced_invoice_pdf_service.dart';
import '../../services/fake_data_service.dart';
import '../../services/invoice_service.dart';
import '../../services/pdf_viewer_service.dart';
import '../../services/queue_processor_service.dart';
import '../../services/ars_header_pdf_service.dart';
import '../../widgets/enhanced_invoice_preview.dart';
import '../../widgets/simple_invoice_modal.dart';

class HomeController extends GetxController {
  final _service = InvoiceService();

  // Estado
  InvoiceCategory currentCategory = InvoiceCategory.pacientes;
  String? currentTipoComprobante; // Nuevo: tipo de comprobante específico
  String? currentTabType; // Nuevo: tipo_tab_envio_factura seleccionado
  bool loading = false;
  List<ERPInvoice> invoices = [];
  List<ERPInvoice> allInvoices = []; // Nuevo: todas las facturas sin filtrar
  String query = '';

  // Estados de error específicos
  bool hasERPConfigError = false;
  bool hasNoInvoicesError = false;
  bool hasConnectionError = false;
  String? errorMessage;

  // Cache por categoría y conteos
  final Map<InvoiceCategory, List<ERPInvoice>> _cache = {};

  // Selección múltiple
  final Set<String> selectedInvoiceIds = {};
  bool get hasSelection => selectedInvoiceIds.isNotEmpty;
  bool get isAllSelected =>
      invoices.isNotEmpty && selectedInvoiceIds.length == invoices.length;

  // Filtro de fechas
  DateTime? startDate;
  DateTime? endDate;
  bool get hasDateFilter => startDate != null || endDate != null;

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
    if (isAllSelected) {
      selectedInvoiceIds.clear();
    } else {
      selectedInvoiceIds.clear();
      for (final inv in invoices) {
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

  final List<_HomeTab> tabs = const [
    _HomeTab('Todos', InvoiceCategory.todos),
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

    // Iniciar el procesador de cola automático
    QueueProcessorService.instance.startProcessing();

    _prefetchCounts();
    // Cargar "todos" primero para tener todos los datos disponibles
    loadCategory(InvoiceCategory.todos);
  }
 Future<void> _prefetchCounts() async {
    // Realiza una sola llamada y rellena el cache para todas las pestañas.
    debugPrint('[HomeController] prefetchCounts start');

    try {
      _clearErrors();
      // Cargar TODO el dataset de ejemplos para calcular conteos sin límites
      final datumList = await FakeDataService.generateFakeInvoicesFromJson();
      final list = datumList
          .map((datum) => _convertDatumToERPInvoice(datum))
          .toList();

      if (list.isEmpty) {
        debugPrint('[HomeController] No invoices loaded from ejemplos.json');
        return;
      }

      debugPrint('[HomeController] prefetchCounts got ${list.length} items');

      // Construimos listas por categoría usando los primeros 3 caracteres del ENCF
      DisplayStatus statusOf(ERPInvoice invoice) {
        // Priorizar el estado del endpoint si está disponible
        final code = invoice.estadoCode;
        if (code != null) {
          switch (code) {
            case 1:
              return DisplayStatus.pendiente;
            case 2:
              return DisplayStatus.rechazada;
            case 3:
              return DisplayStatus.enviado;
          }
        }
        // Fallback a la lógica anterior
        if (invoice.fAnulada == true) return DisplayStatus.rechazada;
        if (invoice.fPagada == true) return DisplayStatus.aprobada;
        final enviado =
            (invoice.linkOriginal != null && invoice.linkOriginal!.isNotEmpty) ||
            invoice.fechaHoraFirma != null;
        if (enviado) return DisplayStatus.enviado;
        return DisplayStatus.pendiente;
      }

      String? getTipoComprobanteFromEncf(ERPInvoice invoice) {
        if (invoice.encf != null && invoice.encf!.length >= 3) {
          return invoice.encf!.substring(0, 3).toUpperCase();
        }
        if (invoice.tipoecf != null && invoice.tipoecf!.isNotEmpty) {
          if (RegExp(r'^\d+$').hasMatch(invoice.tipoecf!)) {
            return 'B${invoice.tipoecf!.padLeft(2, '0')}';
          }
          return invoice.tipoecf!.toUpperCase();
        }
        return null;
      }

      // Filtrar por tipo de comprobante usando los primeros 3 caracteres del ENCF
      final pacientes = list.where((invoice) {
        final tipo = getTipoComprobanteFromEncf(invoice);
        return tipo != null &&
            [
              'E31',
              'E32',
              'B01',
              'C01',
              'P01',
              'B02',
              'C02',
              'P02',
            ].contains(tipo);
      }).toList();

      final ars = list.where((invoice) {
        final tipo = getTipoComprobanteFromEncf(invoice);
        return tipo != null && ['E41', 'B11', 'C11', 'P11'].contains(tipo);
      }).toList();

      final notasCredito = list.where((invoice) {
        final tipo = getTipoComprobanteFromEncf(invoice);
        return tipo != null && ['E34', 'B04', 'C04', 'P04'].contains(tipo);
      }).toList();

      final notasDebito = list.where((invoice) {
        final tipo = getTipoComprobanteFromEncf(invoice);
        return tipo != null && ['E33', 'B03', 'C03', 'P03'].contains(tipo);
      }).toList();

      final gastos = list.where((invoice) {
        final tipo = getTipoComprobanteFromEncf(invoice);
        return tipo != null && ['E43', 'B13', 'C13', 'P13'].contains(tipo);
      }).toList();

      // Enviados: estado 'Enviado' explícito (no pendiente, no aprobada, no rechazada)
      final enviados = list
          .where((invoice) => statusOf(invoice) == DisplayStatus.enviado)
          .toList();
      // Rechazados: estado 'Rechazada'
      final rechazados = list
          .where((invoice) => statusOf(invoice) == DisplayStatus.rechazada)
          .toList();

      // Todos: el dataset completo sin filtrar
      allInvoices = list; // Guardar todas las facturas
      _cache[InvoiceCategory.todos] = list;
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
    currentTipoComprobante = null; // Limpiar filtro específico
    currentTabType = null; // Limpiar filtro por tipo_tab_envio_factura
    loading = true;
    _clearErrors();
    update();

    try {
      // usa cache si existe
      if (_cache.containsKey(category)) {
        invoices = _cache[category]!;
        // Si es "todos", también actualizar allInvoices
        if (category == InvoiceCategory.todos) {
          allInvoices = invoices;
        }
        debugPrint('[HomeController] using cache: ${invoices.length} items');
        loading = false;
        update();
        return;
      }

      final list = await _service.fetchInvoices(category);
      _cache[category] = list;
      invoices = list;
      // Si es "todos", también actualizar allInvoices
      if (category == InvoiceCategory.todos) {
        allInvoices = list;
      }
      debugPrint('[HomeController] loaded ${list.length} items from service');
    } catch (e) {
      _handleError(e);
      invoices = [];
    } finally {
      loading = false;
      update();
    }
  }

  // Nuevo método para cargar por tipo de comprobante específico
  void loadByTipoComprobante(String tipoComprobante) {
    debugPrint('[HomeController] loadByTipoComprobante=$tipoComprobante');
    currentTipoComprobante = tipoComprobante;
    currentTabType = null;
    // Determinar la categoría en base al tipo de comprobante (primeros 3 caracteres)
    final tc = tipoComprobante.toUpperCase();
    const pacientesTC = {'E31','E32','B01','C01','P01','B02','C02','P02'};
    const arsTC = {'E41','B11','C11','P11'};
    const notasCreditoTC = {'E34','B04','C04','P04'};
    const notasDebitoTC = {'E33','B03','C03','P03'};
    const gastosTC = {'E43','B13','C13','P13'};
    if (pacientesTC.contains(tc)) {
      currentCategory = InvoiceCategory.pacientes;
    } else if (arsTC.contains(tc)) {
      currentCategory = InvoiceCategory.ars;
    } else if (notasCreditoTC.contains(tc)) {
      currentCategory = InvoiceCategory.notasCredito;
    } else if (notasDebitoTC.contains(tc)) {
      currentCategory = InvoiceCategory.notasDebito;
    } else if (gastosTC.contains(tc)) {
      currentCategory = InvoiceCategory.gastos;
    } else {
      currentCategory = InvoiceCategory.todos;
    }

    // Asegurar que tenemos datos cargados
    if (allInvoices.isEmpty) {
      debugPrint('[HomeController] allInvoices is empty, using cache[todos]');
      allInvoices = _cache[InvoiceCategory.todos] ?? [];
    }

    // Si aún no hay datos, usar las facturas actuales como fallback
    final sourceInvoices = allInvoices.isNotEmpty ? allInvoices : invoices;

    // Filtrar todas las facturas por el tipo específico
    invoices = sourceInvoices.where((invoice) {
      final tipo = _getTipoComprobanteFromEncf(invoice);
      return tipo == tipoComprobante;
    }).toList();

    debugPrint(
      '[HomeController] filtered to ${invoices.length} items for type $tipoComprobante from ${sourceInvoices.length} total',
    );
    update();
  }

  // Nuevo: cargar por tipo_tab_envio_factura (FacturaArs / FacturaPaciente)
  void loadByTabType(String tabType) {
    debugPrint('[HomeController] loadByTabType=$tabType');
    currentTabType = tabType;
    currentTipoComprobante = null;
    currentCategory = _mapTabTypeToCategory(tabType);

    if (allInvoices.isEmpty) {
      debugPrint('[HomeController] allInvoices is empty, using cache[todos]');
      allInvoices = _cache[InvoiceCategory.todos] ?? [];
    }

    final sourceInvoices = allInvoices.isNotEmpty ? allInvoices : invoices;
    final lowerTab = tabType.toLowerCase();
    invoices = sourceInvoices.where((invoice) {
      final t = (invoice.tipoTabEnvioFactura ?? '').toLowerCase();
      if (lowerTab.contains('ars')) return t.contains('ars');
      if (lowerTab.contains('paciente')) return t.contains('paciente');
      return t == lowerTab;
    }).toList();

    debugPrint(
      '[HomeController] filtered to ${invoices.length} items for tabType $tabType from ${sourceInvoices.length} total',
    );
    update();
  }

  InvoiceCategory _mapTabTypeToCategory(String tabType) {
    final lower = tabType.toLowerCase();
    if (lower.contains('ars')) return InvoiceCategory.ars;
    if (lower.contains('paciente')) return InvoiceCategory.pacientes;
    return InvoiceCategory.todos;
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

  List<ERPInvoice> getFilteredInvoices() {
    if (!hasDateFilter) return invoices;

    return invoices.where((invoice) {
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

  // Acciones del menú
  void viewDetails(ERPInvoice invoice) {
    // Debug: verificar qué datos tiene la factura antes de mostrar el modal
    if (kDebugMode) {
      debugPrint('');
      debugPrint('=== VIEW DETAILS MODAL DEBUG ===');
      debugPrint('Invoice eCF: ${invoice.encf}');
      debugPrint('Invoice RNC Emisor: ${invoice.rncemisor}');
      debugPrint('Invoice Cliente: ${invoice.clienteNombre}');
      debugPrint('Invoice Total: ${invoice.montototal}');
      debugPrint('=== END VIEW DETAILS MODAL DEBUG ===');
      debugPrint('');
    }

    // Mostrar modal simple en lugar de navegar a otra pantalla
    showSimpleInvoiceModal(context: Get.context!, invoice: invoice);
  }

  Future<void> sendInvoice(ERPInvoice invoice) async {
    try {
      debugPrint('[HomeController] ===== ENVIANDO FACTURA A COLA =====');
      debugPrint('[HomeController] Factura: ${invoice.numeroFactura}');
      debugPrint('[HomeController] eCF: ${invoice.encf}');
      debugPrint('[HomeController] =====================================');

      // Agregar la factura individual a la cola
      await _addInvoicesToFirebaseQueue([invoice]);

      // Mostrar confirmación y opción de ver cola
      Get.snackbar(
        'Agregado a Cola',
        'Factura ${invoice.numeroFactura} agregada a la cola de envío',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.queue, color: Colors.white),
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () => Get.toNamed(AppRoutes.QUEUE),
          child: const Text('Ver Cola', style: TextStyle(color: Colors.white)),
        ),
      );

      // Iniciar procesador automáticamente
      QueueProcessorService.instance.startProcessing();
    } catch (e) {
      debugPrint('[HomeController] Error agregando factura a cola: $e');
      Get.snackbar(
        'Error',
        'No se pudo agregar la factura a la cola: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> previewArsHeader(ERPInvoice invoice) async {
    try {
      // Generar PDF de encabezado ARS únicamente
      final bytes = await ArsHeaderPdfService.buildHeaderPdf(
        PdfPageFormat.a4,
        invoice,
      );

      // Mostrar vista previa rápida con opción de ver completo
      PdfViewerService.showQuickPreview(
        context: Get.context!,
        pdfBytes: bytes,
        title: 'Encabezado ARS - ${invoice.numeroFactura}',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo generar el encabezado ARS: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> previewInvoice(ERPInvoice invoice) async {
    try {
      debugPrint('');
      debugPrint(
        '🔍🔍🔍 ENHANCED PREVIEW INVOICE CALLED - HOME CONTROLLER 🔍🔍🔍',
      );
      debugPrint('🔍 Using new enhanced preview with download options');
      debugPrint('');

      // Usar la nueva vista previa mejorada
      showEnhancedInvoicePreview(context: Get.context!, invoice: invoice);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo abrir la vista previa: $e',
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

  // Conversión de Datum a ERPInvoice para datos fake
  ERPInvoice _convertDatumToERPInvoice(Datum datum) {
    return ERPInvoice(
      fFacturaSecuencia: datum.fFacturaSecuencia,
      version: datum.version,
      tipoecf: datum.tipoecf,
      encf: datum.encf,
      fechavencimientosecuencia: datum.fechavencimientosecuencia?.name,
      fechaemision: datum.fechaemision?.name,
      rncemisor: datum.rncemisor,
      razonsocialemisor: datum.razonsocialemisor?.name,
      nombrecomercial: datum.nombrecomercial?.name,
      direccionemisor: datum.direccionemisor?.name,
      municipio: datum.municipio,
      provincia: datum.provincia,
      telefonoemisor1: datum.telefonoemisor1?.toString(),
      correoemisor: datum.correoemisor,
      website: datum.website?.toString(),
      rnccomprador: datum.rnccomprador,
      razonsocialcomprador: datum.razonsocialcomprador?.name,
      direccioncomprador: datum.direccioncomprador,
      montototal: datum.montototal,
      montogravadototal: datum.montogravadototal,
      totalitbis: datum.totalitbis,
      montoexento: datum.montoexento,
      tipomoneda: datum.tipomoneda,
      fechahorafirma: datum.fechahorafirma?.toString(),
      codigoseguridad: datum.codigoseguridad?.toString(),
      linkOriginal: datum.linkOriginal,
      tipoComprobante: datum.tipoComprobante,
    );
  }

  // Método directo para agregar facturas a Firebase (simplificado)
  Future<void> _addInvoicesToFirebaseQueue(List<ERPInvoice> invoices) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');

    debugPrint(
      '[HomeController] Agregando ${invoices.length} facturas a la cola directamente',
    );

    final batch = FirebaseFirestore.instance.batch();

    for (final invoice in invoices) {
      final docRef = FirebaseFirestore.instance
          .collection('invoice_queue')
          .doc();
      batch.set(docRef, {
        'user_id': userId,
        'invoice_id': invoice.encf ?? '',
        'encf': invoice.encf ?? '',
        'numero_factura': invoice.numeroFactura ?? '',
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'retry_count': 0,
        'invoice_data': {
          'encf': invoice.encf,
          'numeroFactura': invoice.numeroFactura,
          'fechaemision': invoice.fechaemision,
          'montototal': invoice.montototal,
          'rncemisor': invoice.rncemisor,
          'razonsocialemisor': invoice.razonsocialemisor,
          'rnccomprador': invoice.rnccomprador,
          'razonsocialcomprador': invoice.razonsocialcomprador,
        },
      });
    }

    await batch.commit();
    debugPrint(
      '[HomeController] ${invoices.length} facturas agregadas a la cola',
    );
  }

  // Método para filtrar facturas por tipo de comprobante específico
  List<ERPInvoice> getInvoicesByTipoComprobante(String tipoComprobante) {
    return invoices.where((invoice) {
      final tipo = _getTipoComprobanteFromEncf(invoice);
      return tipo == tipoComprobante;
    }).toList();
  }

  String? _getTipoComprobanteFromEncf(ERPInvoice invoice) {
    String? result;

    if (invoice.encf != null && invoice.encf!.length >= 3) {
      result = invoice.encf!.substring(0, 3).toUpperCase();
    } else if (invoice.tipoecf != null && invoice.tipoecf!.isNotEmpty) {
      if (RegExp(r'^\d+$').hasMatch(invoice.tipoecf!)) {
        result = 'B${invoice.tipoecf!.padLeft(2, '0')}';
      } else {
        result = invoice.tipoecf!.toUpperCase();
      }
    }

    // Debug log para verificar la extracción
    if (kDebugMode && result != null) {
      debugPrint('[HomeController] ENCF: ${invoice.encf} -> Tipo: $result');
    }

    return result;
  }

  // Enviar facturas seleccionadas en lote
  Future<void> sendSelectedInvoices() async {
    // Validaciones
    if (selectedInvoiceIds.isEmpty) {
      Get.snackbar(
        'Sin Selección',
        'Por favor selecciona al menos una factura para enviar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    // Obtener las facturas seleccionadas
    final selectedInvoices = invoices
        .where(
          (inv) => inv.encf != null && selectedInvoiceIds.contains(inv.encf!),
        )
        .toList();

    if (selectedInvoices.isEmpty) {
      Get.snackbar(
        'Error',
        'No se encontraron facturas válidas para enviar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Agregar facturas a la cola de Firebase
      await _addInvoicesToFirebaseQueue(selectedInvoices);

      // Limpiar selección
      clearSelection();

      // Mostrar confirmación
      Get.snackbar(
        'Agregado a Cola',
        '${selectedInvoices.length} factura(s) agregada(s) a la cola de envío',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.queue, color: Colors.white),
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () => Get.toNamed(AppRoutes.QUEUE),
          child: const Text('Ver Cola', style: TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      debugPrint('[HomeController] Error agregando a cola: $e');
      Get.snackbar(
        'Error',
        'No se pudieron agregar las facturas a la cola: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class _HomeTab {
  final String label;
  final InvoiceCategory category;
  const _HomeTab(this.label, this.category);
}