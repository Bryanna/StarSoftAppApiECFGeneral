import 'package:facturacion/models/erp_invoice_extensions.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/invoice.dart';
import '../../models/erp_invoice.dart';
import '../../models/ui_types.dart';
import '../../models/tipo_comprobante.dart';
import '../../services/invoice_service.dart';
import '../../routes/app_routes.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../services/enhanced_invoice_pdf_service.dart';
import '../../services/fake_data_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/queue_processor_service.dart';

class HomeController extends GetxController {
  final _service = InvoiceService();

  // Estado
  InvoiceCategory currentCategory = InvoiceCategory.pacientes;
  bool loading = false;
  List<ERPInvoice> invoices = [];
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
    loadCategory(InvoiceCategory.pacientes);
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
      // Derivamos alias corto del tipo de comprobante a partir del documento/NCF.
      String aliasFor(ERPInvoice inv) {
        // Preferimos ENCF para derivar el tipo; si no, intentamos con código.
        final base =
            inv.encf ?? inv.tipoecf ?? inv.tipoComprobante ?? inv.numeroFactura;
        final alias = aliasDesdeDocumento(base);
        if (alias != null) return alias;
        final code = inv.tipoComprobante ?? inv.tipoecf ?? '';
        return aliasDesdeDocumento(code) ?? code;
      }

      // Construimos listas por categoría en cliente.
      DisplayStatus statusOf(ERPInvoice i) {
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

      // Todos: el dataset completo sin filtrar
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
    // Debug: verificar qué datos tiene la factura antes de ir al preview
    if (kDebugMode) {
      debugPrint('');
      debugPrint('=== VIEW DETAILS DEBUG ===');
      debugPrint('Invoice eCF: ${invoice.encf}');
      debugPrint(
        'Invoice detalleFactura: ${invoice.detalleFactura?.substring(0, invoice.detalleFactura!.length > 100 ? 100 : invoice.detalleFactura!.length) ?? 'NULL'}...',
      );
      debugPrint('Invoice has ${invoice.detalles.length} parsed details');
      for (int i = 0; i < invoice.detalles.length && i < 3; i++) {
        final detail = invoice.detalles[i];
        debugPrint('  ${i + 1}. [${detail.referencia}] ${detail.descripcion}');
      }
      debugPrint('=== END VIEW DETAILS DEBUG ===');
      debugPrint('');
    }

    Get.toNamed(AppRoutes.INVOICE_PREVIEW, arguments: invoice);
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

  Future<void> downloadInvoice(ERPInvoice invoice) async {
    try {
      debugPrint('');
      debugPrint('🔥🔥🔥 DOWNLOAD INVOICE CALLED - HOME CONTROLLER 🔥🔥🔥');
      debugPrint('🔥 About to call EnhancedInvoicePdfService.buildPdf');
      debugPrint('');

      // Debug: verificar qué datos estamos enviando al PDF
      if (kDebugMode) {
        debugPrint('');
        debugPrint('🔍🔍🔍 DOWNLOAD INVOICE DEBUG 🔍🔍🔍');
        debugPrint('Invoice eCF: ${invoice.encf}');
        debugPrint(
          'Invoice detalleFactura: ${invoice.detalleFactura?.substring(0, invoice.detalleFactura!.length > 100 ? 100 : invoice.detalleFactura!.length) ?? 'NULL'}...',
        );
        debugPrint('Invoice has ${invoice.detalles.length} parsed details');

        // VERIFICACIÓN CRÍTICA
        if (invoice.detalleFactura == null || invoice.detalleFactura!.isEmpty) {
          debugPrint('');
          debugPrint('❌❌❌ PROBLEMA ENCONTRADO ❌❌❌');
          debugPrint('❌ La factura NO tiene campo detalleFactura');
          debugPrint('❌ Esto significa que estás usando DATOS FAKE');
          debugPrint('❌ Ve a Configuración y DESACTIVA "Usar datos fake"');
          debugPrint('❌❌❌ PROBLEMA ENCONTRADO ❌❌❌');
          debugPrint('');
        } else {
          debugPrint(
            '✅ La factura SÍ tiene detalleFactura - debería funcionar',
          );
        }
      }

      // Usar EnhancedInvoicePdfService que puede manejar Map directamente
      final invoiceMap = _convertERPInvoiceToMap(invoice);

      // Debug: verificar el map que se envía al PDF
      if (kDebugMode) {
        debugPrint('');
        debugPrint('🔍 INVOICE MAP DEBUG:');
        debugPrint('🔍 INVOICE FIELDS DEBUG:');
        debugPrint('🔍 encf (eCF): ${invoice.encf}');
        debugPrint(
          '🔍 numerofacturainterna (No. Factura): ${invoice.numerofacturainterna}',
        );
        debugPrint(
          '🔍 noAutorizacion (Autorización): ${invoice.noAutorizacion}',
        );
        debugPrint('🔍 nss (NSS): ${invoice.nss}');
        debugPrint('🔍 medico (Médico): ${invoice.medico}');
        debugPrint('🔍 cedulaMedico (RNC/CED): ${invoice.cedulaMedico}');
        debugPrint('🔍 tipoFacturaTitulo: "${invoice.tipoFacturaTitulo}"');
        debugPrint('🔍 aseguradora: "${invoice.aseguradora}"');

        // Debug del map que se envía al PDF
        final tipoEnMap = invoiceMap['tipo_factura_titulo'] as String?;
        debugPrint('🔍 tipo_factura_titulo in map: "$tipoEnMap"');
        debugPrint(
          '🔍 Original invoice.detalleFactura: ${invoice.detalleFactura?.substring(0, invoice.detalleFactura!.length > 100 ? 100 : invoice.detalleFactura!.length) ?? 'NULL'}...',
        );

        final detalleInMap = invoiceMap['DetalleFactura'] as String?;
        debugPrint(
          '🔍 DetalleFactura in map: ${detalleInMap?.substring(0, detalleInMap.length > 100 ? 100 : detalleInMap.length) ?? 'NULL'}...',
        );

        // Verificar si el problema está en la conversión
        if ((invoice.detalleFactura != null &&
                invoice.detalleFactura!.isNotEmpty) &&
            (detalleInMap == null || detalleInMap.isEmpty)) {
          debugPrint(
            '❌ PROBLEMA: La factura original tiene detalleFactura pero el map no',
          );
        } else if ((invoice.detalleFactura == null ||
            invoice.detalleFactura!.isEmpty)) {
          debugPrint('❌ PROBLEMA: La factura original NO tiene detalleFactura');
          debugPrint('❌ Esto significa que el ERP no está enviando este campo');
        }

        debugPrint('=== END DOWNLOAD DEBUG ===');
        debugPrint('');
      }

      final bytes = await EnhancedInvoicePdfService.buildPdf(
        PdfPageFormat.a4,
        invoiceMap,
      );
      final name =
          'Factura_${invoice.numeroFactura.isNotEmpty ? invoice.numeroFactura : 'CENSAVID'}.pdf';
      // En web, sharePdf inicia descarga del archivo
      await Printing.sharePdf(bytes: bytes, filename: name);
      Get.snackbar(
        'Descargado',
        '${invoice.numeroFactura.isNotEmpty ? invoice.numeroFactura : '-'} descargado',
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

  // Enviar facturas seleccionadas en lote (NUEVA VERSIÓN CON COLA)
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

    // Validar que no haya facturas rechazadas
    final rejectedInvoices = selectedInvoices
        .where((inv) => inv.fAnulada == true)
        .toList();
    if (rejectedInvoices.isNotEmpty) {
      Get.snackbar(
        'Facturas Rechazadas',
        'No puedes enviar facturas rechazadas. Por favor deselecciónalas.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // Confirmar envío
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar Envío en Lote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de enviar ${selectedInvoices.length} factura(s) seleccionada(s)?',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.queue, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Sistema de Cola',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Las facturas se enviarán una por una automáticamente\n'
                    '• Podrás ver el progreso en tiempo real\n'
                    '• Se reintentarán automáticamente en caso de error',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Agregar a Cola'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Agregar facturas a la cola de Firebase
      // Usar método directo sin servicio complejo por ahora
      await _addInvoicesToFirebaseQueue(selectedInvoices);

      // Limpiar selección
      clearSelection();

      // Mostrar confirmación y navegar a la cola
      Get.snackbar(
        'Agregado a Cola',
        '${selectedInvoices.length} factura(s) agregada(s) a la cola de envío',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.queue, color: Colors.white),
        duration: const Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/queue'),
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

  // Método para crear el scenario JSON desde una factura (USANDO DATOS REALES DEL ERP)
  Future<Map<String, dynamic>> _createScenarioFromInvoice(
    ERPInvoice invoice,
  ) async {
    // Helper function to check if value is valid (not null, empty, or "#e")
    bool isValidValue(String? value) {
      return value != null && value.isNotEmpty && value != "#e";
    }

    // Parsear detalles para los items
    final detalles = invoice.detalles;

    // Crear el scenario SOLO con campos del XSD que tengan datos válidos
    final scenario = <String, dynamic>{};

    // CasoPrueba se generará después de obtener RNCEmisor y eNCF

    // === CAMPOS DEL XSD SOLAMENTE ===

    // Version (required)
    scenario["Version"] = invoice.version ?? "1.0";

    // TipoeCF (required) - TEMPORAL: usando 32 para coincidir con E32
    scenario["TipoeCF"] = "32"; // TEMPORAL: coincide con E320000000213
    debugPrint('[HomeController] 🧪 USANDO TipoeCF DE PRUEBA: 32');

    // eNCF (required) - TEMPORAL: usando número de prueba

    final encf = "E320000000286"; // NÚMERO DE PRUEBA TEMPORAL
    scenario["ENCF"] = encf;
    debugPrint('[HomeController] 🧪 USANDO eNCF DE PRUEBA: $encf');

    // FechaVencimientoSecuencia (required for e-CF 31)
    final fechaVencimiento = invoice.fechavencimientosecuencia;
    if (isValidValue(fechaVencimiento)) {
      scenario["FechaVencimientoSecuencia"] = fechaVencimiento;
    }

    // TipoIngresos (required)
    scenario["TipoIngresos"] = invoice.tipoingresos ?? "01";

    // TipoPago (required)
    scenario["TipoPago"] = invoice.tipopago ?? "1";

    // FormaPago[1] and MontoPago[1] (if valid)
    final formaPago1 = invoice.formapago1;
    if (isValidValue(formaPago1)) scenario["FormaPago[1]"] = formaPago1;

    final montoPago1 = invoice.montopago1 ?? invoice.montototal;
    if (isValidValue(montoPago1)) scenario["MontoPago[1]"] = montoPago1;

    // === Obtener datos del emisor desde Firebase ===
    Map<String, dynamic> companyData = {};
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final companyRnc = userData['companyRnc'] as String?;

          if (companyRnc != null && companyRnc.isNotEmpty) {
            final companyDoc = await FirebaseFirestore.instance
                .collection('companies')
                .doc(companyRnc)
                .get();

            if (companyDoc.exists) {
              companyData = companyDoc.data()!;
              debugPrint(
                '[HomeController] Datos de empresa obtenidos desde Firebase',
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[HomeController] Error obteniendo datos de empresa: $e');
    }

    // === Emisor (usando datos de Firebase cuando estén disponibles) ===

    // RNCEmisor (required) - prioridad a Firebase
    final rncEmisorFirebase = companyData['rnc'] as String?;
    final rncEmisor = rncEmisorFirebase ?? invoice.rncemisor;
    if (isValidValue(rncEmisor)) scenario["RNCEmisor"] = rncEmisor;

    // RazonSocialEmisor (required) - prioridad a Firebase
    final razonSocialFirebase = companyData['razonSocial'] as String?;
    final razonSocialEmisor = razonSocialFirebase ?? invoice.razonsocialemisor;
    if (isValidValue(razonSocialEmisor))
      scenario["RazonSocialEmisor"] = razonSocialEmisor;

    // DireccionEmisor (required) - prioridad a Firebase
    final direccionFirebase = companyData['direccion'] as String?;
    final direccionEmisor = direccionFirebase ?? invoice.direccionemisor;
    if (isValidValue(direccionEmisor))
      scenario["DireccionEmisor"] = direccionEmisor;

    // FechaEmision (required) - siempre del invoice
    final fechaEmision = invoice.fechaemision;
    if (isValidValue(fechaEmision))
      scenario["FechaEmision"] = fechaEmision!.replaceAll('/', '-');

    // === Emisor (optional fields con prioridad a Firebase) ===

    // NombreComercial - usar la misma razonSocial de Firebase
    final nombreComercial = razonSocialFirebase ?? invoice.nombrecomercial;
    if (isValidValue(nombreComercial))
      scenario["NombreComercial"] = nombreComercial;

    // TelefonoEmisor[1] - prioridad a Firebase
    final telefonoFirebase = companyData['telefono'] as String?;
    final telefonoEmisor1 = telefonoFirebase ?? invoice.telefonoemisor1;
    if (isValidValue(telefonoEmisor1))
      scenario["TelefonoEmisor[1]"] = telefonoEmisor1;

    // CorreoEmisor - prioridad a Firebase
    final correoFirebase = companyData['correo'] as String?;
    final correoEmisor = correoFirebase ?? invoice.correoemisor;
    if (isValidValue(correoEmisor)) scenario["CorreoEmisor"] = correoEmisor;

    // WebSite - prioridad a Firebase
    final webSiteFirebase = companyData['website'] as String?;
    final webSite = webSiteFirebase ?? invoice.website;
    if (isValidValue(webSite)) scenario["WebSite"] = webSite;

    // Campos que siguen del invoice (no están en Firebase)
    final municipio = invoice.municipio;
    if (isValidValue(municipio)) scenario["Municipio"] = municipio;

    final provincia = invoice.provincia;
    if (isValidValue(provincia)) scenario["Provincia"] = provincia;

    // === Generar CasoPrueba (RNCEmisor + eNCF) ===
    final rncParaCaso = rncEmisor ?? "";
    final encfParaCaso = encf ?? "";
    if (rncParaCaso.isNotEmpty && encfParaCaso.isNotEmpty) {
      scenario["CasoPrueba"] = "$rncParaCaso$encfParaCaso";
      debugPrint(
        '[HomeController] CasoPrueba generado: $rncParaCaso$encfParaCaso',
      );
    }

    final actividadEconomica = invoice.actividadeconomica;
    if (isValidValue(actividadEconomica))
      scenario["ActividadEconomica"] = actividadEconomica;

    final codigoVendedor = invoice.codigovendedor;
    if (isValidValue(codigoVendedor))
      scenario["CodigoVendedor"] = codigoVendedor;

    final numeroFacturaInterna = invoice.numerofacturainterna;
    if (isValidValue(numeroFacturaInterna))
      scenario["NumeroFacturaInterna"] = numeroFacturaInterna;

    // === Comprador ===
    final rncComprador = invoice.rnccomprador;
    if (isValidValue(rncComprador)) scenario["RNCComprador"] = rncComprador;

    final razonSocialComprador = invoice.razonsocialcomprador;
    if (isValidValue(razonSocialComprador))
      scenario["RazonSocialComprador"] = razonSocialComprador;

    final direccionComprador = invoice.direccioncomprador;
    if (isValidValue(direccionComprador))
      scenario["DireccionComprador"] = direccionComprador;

    final municipioComprador = invoice.municipiocomprador;
    if (isValidValue(municipioComprador))
      scenario["MunicipioComprador"] = municipioComprador;

    final provinciaComprador = invoice.provinciacomprador;
    if (isValidValue(provinciaComprador))
      scenario["ProvinciaComprador"] = provinciaComprador;

    // === Totales (required) ===
    scenario["MontoTotal"] = invoice.montototal ?? "0.00";

    // === Totales (optional) ===
    final montoGravadoTotal = invoice.montogravadototal;
    if (isValidValue(montoGravadoTotal) && montoGravadoTotal != "0.00") {
      scenario["MontoGravadoTotal"] = montoGravadoTotal;
    }

    final montoExento = invoice.montoexento;
    if (isValidValue(montoExento) && montoExento != "0.00") {
      scenario["MontoExento"] = montoExento;
    }

    final totalItbis = invoice.totalitbis;
    if (isValidValue(totalItbis) && totalItbis != "0.00") {
      scenario["TotalITBIS"] = totalItbis;
    }

    // === Items (SOLO campos del XSD) ===
    for (int i = 0; i < detalles.length; i++) {
      final detalle = detalles[i];
      final index = i + 1;

      // NumeroLinea (required)
      scenario["NumeroLinea[$index]"] = detalle.referencia ?? index.toString();

      // IndicadorFacturacion (required)
      scenario["IndicadorFacturacion[$index]"] = "4"; // Exento

      // NombreItem (required)
      final nombreItem = detalle.descripcion;
      if (isValidValue(nombreItem)) scenario["NombreItem[$index]"] = nombreItem;

      // IndicadorBienoServicio (required)
      scenario["IndicadorBienoServicio[$index]"] = "2"; // Servicio

      // CantidadItem (required)
      scenario["CantidadItem[$index]"] = detalle.cantidad?.toString() ?? "1.00";

      // UnidadMedida (optional)
      scenario["UnidadMedida[$index]"] =
          "47"; // Lata (código estándar para servicios médicos)

      // PrecioUnitarioItem (required)
      scenario["PrecioUnitarioItem[$index]"] =
          detalle.precio?.toString() ?? "0.00";

      // MontoItem (required)
      scenario["MontoItem[$index]"] = detalle.total?.toString() ?? "0.00";

      // NO incluir CoberturalItem - NO EXISTE EN EL XSD
    }

    return {"scenario": scenario};
  }

  // Método para extraer el tipo de eCF
  String _extractTipoeCF(ERPInvoice invoice) {
    final encf = invoice.numeroFactura;
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

  // MÉTODO DESHABILITADO - Ahora todo va a la cola
  /*
  void _showSendingDialog(
    ERPInvoice invoice,
    Map<String, dynamic> requestBody,
  ) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
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
                    Text(
                      'Enviando Factura ${invoice.numeroFactura}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
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
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: _sendToEndpoint(requestBody),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Enviando a la DGII...'),
                              SizedBox(height: 8),
                              Text(
                                'Procesando factura electrónica',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.error, color: Colors.red),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Error en el envío',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SelectableText(
                                  'Error: ${snapshot.error}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (snapshot.hasData) {
                          final response = snapshot.data!;
                          final isSuccess = response['success'] == true;
                          final statusCode = response['statusCode'] ?? 0;
                          final responseBody = response['body'] ?? {};

                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isSuccess
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: isSuccess
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isSuccess
                                          ? 'Enviado exitosamente'
                                          : 'Error en el envío',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSuccess
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Status Code: $statusCode',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Respuesta de la DGII:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: SelectableText(
                                    JsonEncoder.withIndent(
                                      '  ',
                                    ).convert(responseBody),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Center(child: Text('Sin respuesta'));
                        }
                      },
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
      ),
      barrierDismissible: false,
    );
  }
  */

  // Método para enviar al endpoint
  Future<Map<String, dynamic>> _sendToEndpoint(
    Map<String, dynamic> requestBody,
  ) async {
    try {
      // Obtener la configuración directamente de Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('Datos de usuario no encontrados');
      }

      final userData = userDoc.data()!;
      final companyRnc = userData['companyRnc'] as String?;

      if (companyRnc == null || companyRnc.isEmpty) {
        throw Exception('RNC de empresa no configurado');
      }

      final companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyRnc)
          .get();

      if (!companyDoc.exists) {
        throw Exception('Datos de empresa no encontrados');
      }

      final companyData = companyDoc.data()!;
      final baseUrl =
          companyData['baseEndpointUrl'] as String? ??
          'https://ecfrecepcion.starsoftdominicana.com/ecf/api';

      if (baseUrl.isEmpty) {
        throw Exception(
          'URL base no configurada. Ve a Configuración para establecer el endpoint.',
        );
      }

      final url = '$baseUrl/test-scenarios-json';

      debugPrint('[HomeController] POST URL: $url');
      debugPrint(
        '[HomeController] Request Body: ${JsonEncoder.withIndent('  ').convert(requestBody)}',
      );

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('[HomeController] Response Status: ${response.statusCode}');
      debugPrint('[HomeController] Response Body: ${response.body}');

      Map<String, dynamic> responseBody = {};
      try {
        responseBody = jsonDecode(response.body);
      } catch (e) {
        responseBody = {'raw_response': response.body};
      }

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'body': responseBody,
      };
    } catch (e) {
      debugPrint('[HomeController] Error en _sendToEndpoint: $e');
      return {
        'success': false,
        'statusCode': 0,
        'body': {'error': e.toString()},
      };
    }
  }

  // Conversión de ERPInvoice a Map para el PDF service
  Map<String, dynamic> _convertERPInvoiceToMap(ERPInvoice erp) {
    return {
      // Campos principales que usa el PDF service
      'ENCF': erp.encf ?? erp.numeroFactura,
      'NumeroFacturaInterna': erp.numerofacturainterna ?? erp.numeroFactura,
      'FechaEmision':
          erp.fechaemision ?? _formatDateForPdf(erp.fechaemisionDateTime),
      'RNCEmisor': erp.rncemisor ?? '',
      'RazonSocialEmisor': erp.razonsocialemisor ?? erp.empresaNombre,
      'RNCComprador': erp.rnccomprador ?? '',
      'RazonSocialComprador': erp.razonsocialcomprador ?? erp.clienteNombre,
      'DireccionComprador': erp.direccioncomprador ?? '',
      'MontoTotal': erp.montototal ?? '0.00',
      'MontoGravadoTotal': erp.montogravadototal ?? '0.00',
      'TotalITBIS': erp.totalitbis ?? '0.00',
      'MontoExento': erp.montoexento ?? '0.00',
      'CodigoSeguridad': '', // Debe ser llenado por el API de DGII
      'TipoeCF': erp.tipoecf ?? '31',

      // URL para QR Code
      'linkOriginal': erp.linkOriginal ?? '',
      'link_original': erp.linkOriginal ?? '',

      // Campos adicionales que pueden ser útiles
      'TelefonoEmisor[1]': erp.telefonoemisor1 ?? '',
      'CorreoEmisor': erp.correoemisor ?? '',
      'Website': erp.website ?? '',
      'DireccionEmisor': erp.direccionemisor ?? '',
      'Municipio': erp.municipio ?? '',
      'Provincia': erp.provincia ?? '',
      'TipoMoneda': erp.tipomoneda ?? 'DOP',

      // Detalle de la factura (JSON string del ERP) - Solo para PDF service
      'DetalleFactura': erp.detalleFactura ?? '',

      // Nuevos campos del ERP actualizado
      'rnc_paciente': erp.rncPaciente ?? '',
      'aseguradora': erp.aseguradora ?? '',
      'no_autorizacion': erp.noAutorizacion ?? '',
      'nss': erp.nss ?? '',
      'medico': erp.medico ?? '',
      'cedula_medico': erp.cedulaMedico ?? '',
      'tipo_factura_titulo': erp.tipoFacturaTitulo ?? 'CONTADO - LABORATORIO',
      'monto_cobertura': erp.montoCobertura ?? '',
    };
  }

  String _formatDateForPdf(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
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
}

class _HomeTab {
  final String label;
  final InvoiceCategory category;
  const _HomeTab(this.label, this.category);
}
