import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../services/firestore_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/custom_pdf_service.dart';
import '../../widgets/pdf_viewer_widget.dart';
import '../../models/pdf_element.dart';
import 'template_selector_widget.dart';

class PdfMakerController extends GetxController {
  final FirestoreService _db = FirestoreService();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final GetStorage _storage = GetStorage();

  List<PdfElement> elements = [];
  int selectedElementIndex = -1;
  bool isDragging = false;

  String templateName = 'Mi Plantilla';
  bool isLoading = false;

  // Datos del ERP para mapeo visual
  Map<String, dynamic> erpData = {};
  bool showDataInspector = true;

  // JSON cargado por el usuario
  String jsonInput = '';
  bool hasLoadedJson = false;
  Map<String, dynamic> loadedJsonData = {};

  // Funcionalidades avanzadas
  bool isGridEnabled = true;
  double gridSize = 10.0;
  bool isSnapToGrid = true;
  double zoomLevel = 1.0;
  bool showRulers = true;
  bool showGuides = false;
  List<double> horizontalGuides = [];
  List<double> verticalGuides = [];

  // Historial de acciones (Undo/Redo)
  List<List<PdfElement>> history = [];
  int historyIndex = -1;

  // Selección múltiple
  List<int> selectedElements = [];
  bool isMultiSelectMode = false;

  // Plantillas predefinidas
  List<Map<String, dynamic>> availableTemplates = [];

  // Auto-mapeo inteligente
  Map<String, String> fieldMappings = {};

  // Configuración de tamaño de papel
  String selectedPageSize = 'A4';
  Map<String, PdfPageFormat> pageSizes = {
    // Formatos estándar
    'A4': PdfPageFormat.a4,
    'A5': PdfPageFormat.a5,
    'Letter': PdfPageFormat.letter,
    'Legal': PdfPageFormat.legal,

    // Formatos térmicos comunes
    'Térmico 80mm': PdfPageFormat(
      80 * PdfPageFormat.mm,
      200 * PdfPageFormat.mm,
    ),
    'Térmico 58mm': PdfPageFormat(
      58 * PdfPageFormat.mm,
      150 * PdfPageFormat.mm,
    ),
    'Térmico 57mm': PdfPageFormat(
      57 * PdfPageFormat.mm,
      150 * PdfPageFormat.mm,
    ),
    'Térmico 48mm': PdfPageFormat(
      48 * PdfPageFormat.mm,
      120 * PdfPageFormat.mm,
    ),

    // Recibos y tickets
    'Recibo 3"': PdfPageFormat(3 * PdfPageFormat.inch, 8 * PdfPageFormat.inch),
    'Recibo 2"': PdfPageFormat(2 * PdfPageFormat.inch, 6 * PdfPageFormat.inch),
    'Ticket Largo': PdfPageFormat(
      72 * PdfPageFormat.mm,
      300 * PdfPageFormat.mm,
    ),
    'Ticket Corto': PdfPageFormat(
      72 * PdfPageFormat.mm,
      150 * PdfPageFormat.mm,
    ),

    // Etiquetas
    'Etiqueta 4x6"': PdfPageFormat(
      4 * PdfPageFormat.inch,
      6 * PdfPageFormat.inch,
    ),
    'Etiqueta 2x1"': PdfPageFormat(
      2 * PdfPageFormat.inch,
      1 * PdfPageFormat.inch,
    ),

    'Personalizado': PdfPageFormat.a4, // Se configurará dinámicamente
  };

  // Dimensiones personalizadas
  double customWidth = 210; // mm
  double customHeight = 297; // mm

  @override
  void onInit() {
    super.onInit();
    _initializeTemplates();
    _loadDefaultTemplate();
    loadSampleData();
  }

  void _initializeTemplates() {
    availableTemplates = [
      {
        'name': 'Factura Clásica',
        'description': 'Plantilla tradicional para facturas',
        'icon': Icons.receipt_long,
        'category': 'Facturación',
        'elements': _getClassicInvoiceTemplate(),
        'preview': 'assets/previews/factura_clasica.png',
        'color': const Color(0xFF005285),
      },
      {
        'name': 'Factura Moderna',
        'description': 'Diseño contemporáneo con colores vibrantes',
        'icon': Icons.receipt_long,
        'category': 'Facturación',
        'elements': _getModernInvoiceTemplate(),
        'preview': 'assets/previews/factura_moderna.png',
        'color': const Color(0xFF2196F3),
      },
      {
        'name': 'Factura Minimalista',
        'description': 'Diseño limpio y simple',
        'icon': Icons.receipt_long,
        'category': 'Facturación',
        'elements': _getMinimalistInvoiceTemplate(),
        'preview': 'assets/previews/factura_minimalista.png',
        'color': const Color(0xFF607D8B),
      },
      {
        'name': 'Recibo Moderno',
        'description': 'Diseño moderno para recibos',
        'icon': Icons.receipt,
        'category': 'Recibos',
        'elements': _getModernReceiptTemplate(),
        'preview': 'assets/previews/recibo_moderno.png',
        'color': const Color(0xFF4CAF50),
      },
      {
        'name': 'Recibo Térmico',
        'description': 'Optimizado para impresoras térmicas',
        'icon': Icons.receipt,
        'category': 'Recibos',
        'elements': _getThermalReceiptTemplate(),
        'preview': 'assets/previews/recibo_termico.png',
        'color': const Color(0xFF795548),
      },
      {
        'name': 'Ticket de Venta',
        'description': 'Formato compacto para tickets',
        'icon': Icons.confirmation_number,
        'category': 'Tickets',
        'elements': _getSalesTicketTemplate(),
        'preview': 'assets/previews/ticket_venta.png',
        'color': const Color(0xFFFF9800),
      },
      {
        'name': 'Etiqueta Simple',
        'description': 'Etiqueta básica para productos',
        'icon': Icons.label,
        'category': 'Etiquetas',
        'elements': _getSimpleLabelTemplate(),
        'preview': 'assets/previews/etiqueta_simple.png',
        'color': const Color(0xFF9C27B0),
      },
      {
        'name': 'Etiqueta de Precio',
        'description': 'Etiqueta con código de barras',
        'icon': Icons.qr_code,
        'category': 'Etiquetas',
        'elements': _getPriceLabelTemplate(),
        'preview': 'assets/previews/etiqueta_precio.png',
        'color': const Color(0xFFE91E63),
      },
      {
        'name': 'Certificado Elegante',
        'description': 'Plantilla para certificados formales',
        'icon': Icons.workspace_premium,
        'category': 'Certificados',
        'elements': _getCertificateTemplate(),
        'preview': 'assets/previews/certificado_elegante.png',
        'color': const Color(0xFF673AB7),
      },
      {
        'name': 'Diploma Académico',
        'description': 'Formato académico tradicional',
        'icon': Icons.school,
        'category': 'Certificados',
        'elements': _getAcademicDiplomaTemplate(),
        'preview': 'assets/previews/diploma_academico.png',
        'color': const Color(0xFF3F51B5),
      },
      {
        'name': 'Reporte Ejecutivo',
        'description': 'Formato para reportes empresariales',
        'icon': Icons.analytics,
        'category': 'Reportes',
        'elements': _getExecutiveReportTemplate(),
        'preview': 'assets/previews/reporte_ejecutivo.png',
        'color': const Color(0xFF009688),
      },
      {
        'name': 'Reporte de Ventas',
        'description': 'Análisis detallado de ventas',
        'icon': Icons.trending_up,
        'category': 'Reportes',
        'elements': _getSalesReportTemplate(),
        'preview': 'assets/previews/reporte_ventas.png',
        'color': const Color(0xFFFF5722),
      },
      {
        'name': 'Cotización Profesional',
        'description': 'Formato elegante para cotizaciones',
        'icon': Icons.request_quote,
        'category': 'Cotizaciones',
        'elements': _getProfessionalQuoteTemplate(),
        'preview': 'assets/previews/cotizacion_profesional.png',
        'color': const Color(0xFF795548),
      },
      {
        'name': 'Orden de Compra',
        'description': 'Formato estándar para órdenes',
        'icon': Icons.shopping_cart,
        'category': 'Órdenes',
        'elements': _getPurchaseOrderTemplate(),
        'preview': 'assets/previews/orden_compra.png',
        'color': const Color(0xFF607D8B),
      },
      {
        'name': 'Nota de Crédito',
        'description': 'Formato para notas de crédito',
        'icon': Icons.credit_card,
        'category': 'Facturación',
        'elements': _getCreditNoteTemplate(),
        'preview': 'assets/previews/nota_credito.png',
        'color': const Color(0xFFE91E63),
      },
    ];
  }

  List<PdfElement> _getClassicInvoiceTemplate() {
    return [
      PdfElement(
        type: 'text',
        x: 50,
        y: 30,
        content: '{empresa_nombre}',
        fontSize: 20,
        bold: true,
        color: const Color(0xFF005285),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 60,
        content: '{empresa_direccion}',
        fontSize: 10,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 80,
        content: 'RNC: {empresa_rnc}',
        fontSize: 10,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 30,
        content: 'FACTURA',
        fontSize: 24,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 70,
        content: 'No. {factura_numero}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 90,
        content: 'Fecha: {factura_fecha}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'line',
        x: 50,
        y: 120,
        width: 495,
        height: 2,
        color: const Color(0xFF005285),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 140,
        content: 'FACTURAR A:',
        fontSize: 12,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 160,
        content: '{cliente_nombre}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 180,
        content: '{cliente_direccion}',
        fontSize: 10,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 200,
        content: '{cliente_telefono}',
        fontSize: 10,
      ),
      PdfElement(
        type: 'products_table',
        x: 50,
        y: 240,
        width: 495,
        height: 200,
        content: 'Tabla de Productos',
      ),
      PdfElement(
        type: 'text',
        x: 350,
        y: 460,
        content: 'Subtotal: {subtotal}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 350,
        y: 480,
        content: 'ITBIS: {itbis}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 350,
        y: 500,
        content: 'TOTAL: {total}',
        fontSize: 16,
        bold: true,
        color: const Color(0xFF005285),
      ),
    ];
  }

  List<PdfElement> _getModernReceiptTemplate() {
    return [
      PdfElement(
        type: 'text',
        x: 20,
        y: 20,
        content: '{empresa_nombre}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 20,
        y: 40,
        content: '--- RECIBO ---',
        fontSize: 12,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 20,
        y: 60,
        content: 'No: {recibo_numero}',
        fontSize: 10,
      ),
      PdfElement(type: 'text', x: 20, y: 80, content: '{fecha}', fontSize: 10),
      PdfElement(type: 'line', x: 20, y: 100, width: 200, height: 1),
      PdfElement(
        type: 'text',
        x: 20,
        y: 120,
        content: '{cliente_nombre}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 20,
        y: 140,
        content: '{descripcion}',
        fontSize: 10,
      ),
      PdfElement(type: 'line', x: 20, y: 160, width: 200, height: 1),
      PdfElement(
        type: 'text',
        x: 20,
        y: 180,
        content: 'TOTAL: {total}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 20,
        y: 200,
        content: 'Gracias por su compra',
        fontSize: 8,
      ),
    ];
  }

  List<PdfElement> _getSimpleLabelTemplate() {
    return [
      PdfElement(
        type: 'text',
        x: 10,
        y: 10,
        content: '{producto_nombre}',
        fontSize: 12,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 10,
        y: 30,
        content: 'Código: {producto_codigo}',
        fontSize: 8,
      ),
      PdfElement(
        type: 'text',
        x: 10,
        y: 45,
        content: 'Precio: {producto_precio}',
        fontSize: 10,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 10,
        y: 60,
        content: '{empresa_nombre}',
        fontSize: 6,
      ),
    ];
  }

  List<PdfElement> _getCertificateTemplate() {
    return [
      PdfElement(
        type: 'text',
        x: 200,
        y: 50,
        content: 'CERTIFICADO',
        fontSize: 24,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 100,
        y: 100,
        content: 'Se certifica que',
        fontSize: 14,
      ),
      PdfElement(
        type: 'text',
        x: 200,
        y: 130,
        content: '{participante_nombre}',
        fontSize: 18,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 100,
        y: 170,
        content: 'ha completado satisfactoriamente',
        fontSize: 14,
      ),
      PdfElement(
        type: 'text',
        x: 200,
        y: 200,
        content: '{curso_nombre}',
        fontSize: 16,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 150,
        y: 250,
        content: 'Fecha: {fecha_certificacion}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 300,
        content: '{instructor_nombre}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 320,
        content: 'Instructor',
        fontSize: 10,
      ),
    ];
  }

  List<PdfElement> _getModernInvoiceTemplate() {
    return [
      PdfElement(
        type: 'rectangle',
        x: 0,
        y: 0,
        width: 595,
        height: 80,
        backgroundColor: const Color(0xFF2196F3),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 25,
        content: '{empresa_nombre}',
        fontSize: 22,
        bold: true,
        color: Colors.white,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 25,
        content: 'FACTURA',
        fontSize: 24,
        bold: true,
        color: Colors.white,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 50,
        content: '{empresa_direccion}',
        fontSize: 10,
        color: Colors.white,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 50,
        content: 'No. {factura_numero}',
        fontSize: 12,
        color: Colors.white,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 100,
        content: 'CLIENTE:',
        fontSize: 12,
        bold: true,
        color: const Color(0xFF2196F3),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 120,
        content: '{cliente_nombre}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 140,
        content: '{cliente_direccion}',
        fontSize: 10,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 100,
        content: 'FECHA: {factura_fecha}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'products_table',
        x: 50,
        y: 180,
        width: 495,
        height: 200,
        content: 'Tabla de Productos',
      ),
      PdfElement(
        type: 'rectangle',
        x: 350,
        y: 400,
        width: 195,
        height: 80,
        backgroundColor: const Color(0xFFF5F5F5),
      ),
      PdfElement(
        type: 'text',
        x: 360,
        y: 420,
        content: 'Subtotal: {subtotal}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 360,
        y: 440,
        content: 'ITBIS: {itbis}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 360,
        y: 460,
        content: 'TOTAL: {total}',
        fontSize: 16,
        bold: true,
        color: const Color(0xFF2196F3),
      ),
    ];
  }

  List<PdfElement> _getMinimalistInvoiceTemplate() {
    return [
      PdfElement(
        type: 'text',
        x: 50,
        y: 50,
        content: '{empresa_nombre}',
        fontSize: 18,
        bold: true,
        color: const Color(0xFF607D8B),
      ),
      PdfElement(
        type: 'line',
        x: 50,
        y: 75,
        width: 200,
        height: 1,
        color: const Color(0xFF607D8B),
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 50,
        content: 'FACTURA',
        fontSize: 20,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 75,
        content: '{factura_numero}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 120,
        content: '{cliente_nombre}',
        fontSize: 14,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 140,
        content: '{cliente_direccion}',
        fontSize: 10,
        color: const Color(0xFF757575),
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 120,
        content: '{factura_fecha}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'products_table',
        x: 50,
        y: 180,
        width: 495,
        height: 200,
        content: 'Tabla de Productos',
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 400,
        content: 'Total: {total}',
        fontSize: 18,
        bold: true,
        color: const Color(0xFF607D8B),
      ),
    ];
  }

  List<PdfElement> _getThermalReceiptTemplate() {
    return [
      PdfElement(
        type: 'text',
        x: 15,
        y: 10,
        content: '{empresa_nombre}',
        fontSize: 12,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 15,
        y: 25,
        content: '{empresa_direccion}',
        fontSize: 8,
      ),
      PdfElement(
        type: 'text',
        x: 15,
        y: 35,
        content: 'Tel: {empresa_telefono}',
        fontSize: 8,
      ),
      PdfElement(
        type: 'line',
        x: 5,
        y: 50,
        width: 70,
        height: 1,
        color: Colors.black,
      ),
      PdfElement(
        type: 'text',
        x: 5,
        y: 60,
        content: 'Recibo: {recibo_numero}',
        fontSize: 9,
      ),
      PdfElement(
        type: 'text',
        x: 5,
        y: 75,
        content: 'Fecha: {fecha}',
        fontSize: 9,
      ),
      PdfElement(
        type: 'text',
        x: 5,
        y: 90,
        content: 'Cliente: {cliente_nombre}',
        fontSize: 9,
      ),
      PdfElement(
        type: 'line',
        x: 5,
        y: 105,
        width: 70,
        height: 1,
        color: Colors.black,
      ),
      PdfElement(
        type: 'text',
        x: 5,
        y: 115,
        content: '{descripcion}',
        fontSize: 9,
      ),
      PdfElement(
        type: 'line',
        x: 5,
        y: 130,
        width: 70,
        height: 1,
        color: Colors.black,
      ),
      PdfElement(
        type: 'text',
        x: 5,
        y: 140,
        content: 'TOTAL: {total}',
        fontSize: 12,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 15,
        y: 160,
        content: 'Gracias por su compra',
        fontSize: 8,
      ),
    ];
  }

  List<PdfElement> _getSalesTicketTemplate() {
    return [
      PdfElement(
        type: 'text',
        x: 20,
        y: 15,
        content: '{empresa_nombre}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 25,
        y: 35,
        content: '*** TICKET DE VENTA ***',
        fontSize: 10,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 10,
        y: 55,
        content: 'Ticket: {ticket_numero}',
        fontSize: 9,
      ),
      PdfElement(
        type: 'text',
        x: 10,
        y: 70,
        content: 'Fecha: {fecha}',
        fontSize: 9,
      ),
      PdfElement(
        type: 'text',
        x: 10,
        y: 85,
        content: 'Cajero: {cajero_nombre}',
        fontSize: 9,
      ),
      PdfElement(
        type: 'line',
        x: 10,
        y: 100,
        width: 60,
        height: 1,
        color: Colors.black,
      ),
      PdfElement(
        type: 'text',
        x: 10,
        y: 110,
        content: '{productos_lista}',
        fontSize: 9,
      ),
      PdfElement(
        type: 'line',
        x: 10,
        y: 130,
        width: 60,
        height: 1,
        color: Colors.black,
      ),
      PdfElement(
        type: 'text',
        x: 10,
        y: 140,
        content: 'Subtotal: {subtotal}',
        fontSize: 9,
      ),
      PdfElement(
        type: 'text',
        x: 10,
        y: 155,
        content: 'Descuento: {descuento}',
        fontSize: 9,
      ),
      PdfElement(
        type: 'text',
        x: 10,
        y: 170,
        content: 'TOTAL: {total}',
        fontSize: 12,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 15,
        y: 190,
        content: 'Vuelva pronto!',
        fontSize: 8,
      ),
    ];
  }

  List<PdfElement> _getPriceLabelTemplate() {
    return [
      PdfElement(
        type: 'text',
        x: 10,
        y: 10,
        content: '{producto_nombre}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 10,
        y: 30,
        content: 'Código: {producto_codigo}',
        fontSize: 10,
      ),
      PdfElement(
        type: 'rectangle',
        x: 10,
        y: 45,
        width: 80,
        height: 20,
        backgroundColor: Colors.black,
      ),
      PdfElement(
        type: 'text',
        x: 15,
        y: 52,
        content: '||||| |||| |||||',
        fontSize: 8,
        color: Colors.white,
      ),
      PdfElement(
        type: 'text',
        x: 10,
        y: 75,
        content: 'PRECIO: {producto_precio}',
        fontSize: 16,
        bold: true,
        color: const Color(0xFFE91E63),
      ),
      PdfElement(
        type: 'text',
        x: 10,
        y: 95,
        content: '{empresa_nombre}',
        fontSize: 8,
      ),
    ];
  }

  List<PdfElement> _getAcademicDiplomaTemplate() {
    return [
      PdfElement(
        type: 'rectangle',
        x: 30,
        y: 30,
        width: 535,
        height: 750,
        backgroundColor: const Color(0xFFFAFAFA),
        borderRadius: 10,
      ),
      PdfElement(
        type: 'text',
        x: 200,
        y: 80,
        content: 'DIPLOMA ACADÉMICO',
        fontSize: 28,
        bold: true,
        color: const Color(0xFF3F51B5),
      ),
      PdfElement(
        type: 'text',
        x: 100,
        y: 150,
        content: 'La {institucion_nombre}',
        fontSize: 16,
      ),
      PdfElement(
        type: 'text',
        x: 100,
        y: 180,
        content: 'Otorga el presente diploma a',
        fontSize: 14,
      ),
      PdfElement(
        type: 'text',
        x: 200,
        y: 220,
        content: '{estudiante_nombre}',
        fontSize: 22,
        bold: true,
        color: const Color(0xFF3F51B5),
      ),
      PdfElement(
        type: 'text',
        x: 100,
        y: 270,
        content: 'Por haber completado satisfactoriamente',
        fontSize: 14,
      ),
      PdfElement(
        type: 'text',
        x: 200,
        y: 300,
        content: '{programa_nombre}',
        fontSize: 18,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 100,
        y: 350,
        content: 'Con una calificación de: {calificacion}',
        fontSize: 14,
      ),
      PdfElement(
        type: 'text',
        x: 150,
        y: 400,
        content: 'Otorgado el {fecha_graduacion}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 100,
        y: 500,
        content: '{director_nombre}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 100,
        y: 520,
        content: 'Director Académico',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 500,
        content: '{secretario_nombre}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 520,
        content: 'Secretario General',
        fontSize: 12,
      ),
    ];
  }

  List<PdfElement> _getSalesReportTemplate() {
    return [
      PdfElement(
        type: 'text',
        x: 50,
        y: 30,
        content: '{empresa_nombre}',
        fontSize: 18,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 55,
        content: 'REPORTE DE VENTAS',
        fontSize: 22,
        bold: true,
        color: const Color(0xFFFF5722),
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 30,
        content: 'Período: {periodo}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 50,
        content: 'Generado: {fecha_generacion}',
        fontSize: 10,
      ),
      PdfElement(
        type: 'line',
        x: 50,
        y: 85,
        width: 495,
        height: 2,
        color: const Color(0xFFFF5722),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 110,
        content: 'RESUMEN DE VENTAS',
        fontSize: 16,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 140,
        content: 'Total de Ventas: {ventas_total}',
        fontSize: 14,
        bold: true,
        color: const Color(0xFFFF5722),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 160,
        content: 'Número de Transacciones: {transacciones_count}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 180,
        content: 'Promedio por Venta: {promedio_venta}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 220,
        content: 'TOP PRODUCTOS',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 250,
        content: '{top_productos}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 350,
        content: 'ANÁLISIS POR PERÍODO',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 380,
        content: '{analisis_periodo}',
        fontSize: 12,
      ),
    ];
  }

  List<PdfElement> _getProfessionalQuoteTemplate() {
    return [
      PdfElement(
        type: 'rectangle',
        x: 0,
        y: 0,
        width: 595,
        height: 100,
        backgroundColor: const Color(0xFF795548),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 30,
        content: '{empresa_nombre}',
        fontSize: 20,
        bold: true,
        color: Colors.white,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 30,
        content: 'COTIZACIÓN',
        fontSize: 24,
        bold: true,
        color: Colors.white,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 60,
        content: '{empresa_direccion}',
        fontSize: 10,
        color: Colors.white,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 60,
        content: 'No. {cotizacion_numero}',
        fontSize: 12,
        color: Colors.white,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 130,
        content: 'COTIZAR PARA:',
        fontSize: 12,
        bold: true,
        color: const Color(0xFF795548),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 150,
        content: '{cliente_nombre}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 170,
        content: '{cliente_direccion}',
        fontSize: 10,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 130,
        content: 'Fecha: {cotizacion_fecha}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 150,
        content: 'Válida hasta: {fecha_vencimiento}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'products_table',
        x: 50,
        y: 200,
        width: 495,
        height: 200,
        content: 'Tabla de Productos/Servicios',
      ),
      PdfElement(
        type: 'text',
        x: 350,
        y: 420,
        content: 'Subtotal: {subtotal}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 350,
        y: 440,
        content: 'Descuento: {descuento}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 350,
        y: 460,
        content: 'TOTAL: {total}',
        fontSize: 16,
        bold: true,
        color: const Color(0xFF795548),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 500,
        content: 'Términos y Condiciones: {terminos}',
        fontSize: 10,
      ),
    ];
  }

  List<PdfElement> _getPurchaseOrderTemplate() {
    return [
      PdfElement(
        type: 'text',
        x: 50,
        y: 30,
        content: '{empresa_nombre}',
        fontSize: 18,
        bold: true,
        color: const Color(0xFF607D8B),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 55,
        content: 'ORDEN DE COMPRA',
        fontSize: 22,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 30,
        content: 'O.C. No. {orden_numero}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 55,
        content: 'Fecha: {orden_fecha}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'line',
        x: 50,
        y: 85,
        width: 495,
        height: 2,
        color: const Color(0xFF607D8B),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 110,
        content: 'PROVEEDOR:',
        fontSize: 12,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 130,
        content: '{proveedor_nombre}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 150,
        content: '{proveedor_direccion}',
        fontSize: 10,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 110,
        content: 'ENTREGAR EN:',
        fontSize: 12,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 130,
        content: '{direccion_entrega}',
        fontSize: 10,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 150,
        content: 'Fecha requerida: {fecha_entrega}',
        fontSize: 10,
      ),
      PdfElement(
        type: 'products_table',
        x: 50,
        y: 180,
        width: 495,
        height: 200,
        content: 'Tabla de Productos',
      ),
      PdfElement(
        type: 'text',
        x: 350,
        y: 400,
        content: 'TOTAL: {total}',
        fontSize: 16,
        bold: true,
        color: const Color(0xFF607D8B),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 450,
        content: 'Autorizado por: {autorizado_por}',
        fontSize: 12,
      ),
    ];
  }

  List<PdfElement> _getCreditNoteTemplate() {
    return [
      PdfElement(
        type: 'text',
        x: 50,
        y: 30,
        content: '{empresa_nombre}',
        fontSize: 18,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 55,
        content: 'NOTA DE CRÉDITO',
        fontSize: 22,
        bold: true,
        color: const Color(0xFFE91E63),
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 30,
        content: 'N.C. No. {nota_numero}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 55,
        content: 'Fecha: {nota_fecha}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 100,
        content: 'Referencia Factura: {factura_referencia}',
        fontSize: 12,
        bold: true,
      ),
      PdfElement(
        type: 'line',
        x: 50,
        y: 125,
        width: 495,
        height: 2,
        color: const Color(0xFFE91E63),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 150,
        content: 'CLIENTE:',
        fontSize: 12,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 170,
        content: '{cliente_nombre}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 190,
        content: '{cliente_direccion}',
        fontSize: 10,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 230,
        content: 'MOTIVO DEL CRÉDITO:',
        fontSize: 12,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 250,
        content: '{motivo_credito}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'products_table',
        x: 50,
        y: 280,
        width: 495,
        height: 150,
        content: 'Detalle del Crédito',
      ),
      PdfElement(
        type: 'text',
        x: 350,
        y: 450,
        content: 'MONTO CRÉDITO: {monto_credito}',
        fontSize: 16,
        bold: true,
        color: const Color(0xFFE91E63),
      ),
    ];
  }

  List<PdfElement> _getExecutiveReportTemplate() {
    return [
      PdfElement(
        type: 'text',
        x: 50,
        y: 30,
        content: '{empresa_nombre}',
        fontSize: 16,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 50,
        content: 'REPORTE EJECUTIVO',
        fontSize: 20,
        bold: true,
        color: const Color(0xFF009688),
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 30,
        content: '{fecha_reporte}',
        fontSize: 10,
      ),
      PdfElement(
        type: 'text',
        x: 400,
        y: 50,
        content: 'Página 1',
        fontSize: 10,
      ),
      PdfElement(
        type: 'line',
        x: 50,
        y: 80,
        width: 495,
        height: 2,
        color: const Color(0xFF009688),
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 100,
        content: 'Resumen Ejecutivo',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 130,
        content: '{resumen_contenido}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 200,
        content: 'Métricas Principales',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 230,
        content: 'Ventas: {ventas_total}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 250,
        content: 'Clientes: {clientes_total}',
        fontSize: 12,
      ),
      PdfElement(
        type: 'text',
        x: 50,
        y: 270,
        content: 'Crecimiento: {crecimiento_porcentaje}%',
        fontSize: 12,
      ),
    ];
  }

  void loadTemplate(int templateIndex) {
    if (templateIndex < 0 || templateIndex >= availableTemplates.length) return;

    _saveToHistory();

    final template = availableTemplates[templateIndex];
    elements = (template['elements'] as List<PdfElement>)
        .map((e) => PdfElement.fromJson(e.toJson()))
        .toList();

    templateName = template['name'];
    selectedElementIndex = -1;

    Get.snackbar(
      'Plantilla Cargada',
      'Plantilla "${template['name']}" cargada correctamente',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
    );

    update();
  }

  void showTemplateSelector() {
    Get.dialog(TemplateSelectorWidget(controller: this));
  }

  Map<String, dynamic> getSampleDataForTemplate(String templateName) {
    // Datos de ejemplo específicos para cada tipo de plantilla
    final baseData = {
      'empresa_nombre': 'Mi Empresa S.A.',
      'empresa_direccion': 'Av. Principal #123, Santo Domingo',
      'empresa_telefono': '809-555-1234',
      'empresa_rnc': '131-24393-2',
      'fecha': '15/12/2024',
      'cliente_nombre': 'Juan Pérez',
      'cliente_direccion': 'Calle Secundaria #456',
      'cliente_telefono': '809-555-5678',
    };

    switch (templateName) {
      case 'Factura Clásica':
      case 'Factura Moderna':
      case 'Factura Minimalista':
        return {
          ...baseData,
          'factura_numero': 'F-001234',
          'factura_fecha': '15/12/2024',
          'subtotal': '\$1,327.43',
          'itbis': '\$172.57',
          'total': '\$1,500.00',
        };

      case 'Recibo Moderno':
      case 'Recibo Térmico':
        return {
          ...baseData,
          'recibo_numero': 'R-001234',
          'descripcion': 'Pago de servicios profesionales',
          'total': '\$500.00',
        };

      case 'Ticket de Venta':
        return {
          ...baseData,
          'ticket_numero': 'T-001234',
          'cajero_nombre': 'María González',
          'productos_lista': 'Producto A x2\nProducto B x1',
          'subtotal': '\$450.00',
          'descuento': '\$50.00',
          'total': '\$400.00',
        };

      case 'Etiqueta Simple':
      case 'Etiqueta de Precio':
        return {
          ...baseData,
          'producto_nombre': 'Producto Ejemplo',
          'producto_codigo': 'PRD-001',
          'producto_precio': '\$25.00',
        };

      case 'Certificado Elegante':
        return {
          ...baseData,
          'participante_nombre': 'Juan Pérez',
          'curso_nombre': 'Curso de Capacitación Profesional',
          'fecha_certificacion': '15/12/2024',
          'instructor_nombre': 'Dr. María González',
        };

      case 'Diploma Académico':
        return {
          ...baseData,
          'institucion_nombre': 'Universidad Ejemplo',
          'estudiante_nombre': 'Juan Pérez',
          'programa_nombre': 'Licenciatura en Administración',
          'calificacion': 'Magna Cum Laude',
          'fecha_graduacion': '15/12/2024',
          'director_nombre': 'Dr. Carlos Rodríguez',
          'secretario_nombre': 'Lic. Ana Martínez',
        };

      case 'Cotización Profesional':
        return {
          ...baseData,
          'cotizacion_numero': 'COT-001234',
          'cotizacion_fecha': '15/12/2024',
          'fecha_vencimiento': '30/12/2024',
          'subtotal': '\$2,000.00',
          'descuento': '\$200.00',
          'total': '\$1,800.00',
          'terminos': 'Válida por 15 días. Precios sujetos a cambio.',
        };

      default:
        return baseData;
    }
  }

  void _loadDefaultTemplate() {
    // Cargar plantilla por defecto o la última guardada
    final savedTemplate = _storage.read('last_pdf_template');
    if (savedTemplate != null) {
      try {
        final templateData = json.decode(savedTemplate);
        templateName = templateData['name'] ?? 'Mi Plantilla';
        elements = (templateData['elements'] as List)
            .map((e) => PdfElement.fromJson(e))
            .toList();
        update();
      } catch (e) {
        print('Error cargando plantilla: $e');
        _createDefaultTemplate();
      }
    } else {
      _createDefaultTemplate();
    }
  }

  void _createDefaultTemplate() {
    // Crear plantilla basada en el tamaño de papel seleccionado
    switch (selectedPageSize) {
      case 'Térmico 80mm':
      case 'Térmico 58mm':
      case 'Térmico 57mm':
      case 'Térmico 48mm':
        _createThermalTemplate();
        break;
      case 'Ticket Largo':
      case 'Ticket Corto':
        _createTicketTemplate();
        break;
      case 'Etiqueta 4x6"':
      case 'Etiqueta 2x1"':
        _createLabelTemplate();
        break;
      default:
        _createStandardTemplate();
        break;
    }
  }

  void _createStandardTemplate() {
    elements = [
      // Logo de la empresa
      PdfElement(
        type: 'logo',
        x: 50,
        y: 50,
        width: 120,
        height: 80,
        content: 'Logo de la Empresa',
      ),

      // Título de la factura
      PdfElement(
        type: 'text',
        x: 400,
        y: 50,
        content: 'FACTURA',
        fontSize: 24,
        bold: true,
        color: const Color(0xFF005285),
      ),

      // Número de factura
      PdfElement(
        type: 'invoice_number',
        x: 400,
        y: 90,
        content: 'No. Factura: {invoice_number}',
        fontSize: 12,
      ),

      // Fecha
      PdfElement(
        type: 'date',
        x: 400,
        y: 110,
        content: 'Fecha: {date}',
        fontSize: 12,
      ),

      // Datos de la empresa
      PdfElement(
        type: 'company_name',
        x: 50,
        y: 150,
        content: '{company_name}',
        fontSize: 14,
        bold: true,
      ),

      PdfElement(
        type: 'company_address',
        x: 50,
        y: 170,
        content: '{company_address}',
        fontSize: 10,
      ),

      PdfElement(
        type: 'company_phone',
        x: 50,
        y: 190,
        content: 'Tel: {company_phone}',
        fontSize: 10,
      ),

      // Datos del cliente
      PdfElement(
        type: 'text',
        x: 50,
        y: 230,
        content: 'FACTURAR A:',
        fontSize: 12,
        bold: true,
      ),

      PdfElement(
        type: 'client',
        x: 50,
        y: 250,
        content: '{client_name}',
        fontSize: 12,
      ),

      // Tabla de productos (placeholder)
      PdfElement(
        type: 'products_table',
        x: 50,
        y: 300,
        width: 495,
        height: 200,
        content: 'Tabla de Productos',
      ),

      // Total
      PdfElement(
        type: 'total',
        x: 400,
        y: 520,
        content: 'Total: {total}',
        fontSize: 16,
        bold: true,
      ),
    ];
    update();
  }

  void _createThermalTemplate() {
    // Plantilla optimizada para impresoras térmicas
    elements = [
      PdfElement(
        type: 'text',
        x: 20,
        y: 10,
        content: 'FACTURA',
        fontSize: 16,
        bold: true,
      ),
      PdfElement(
        type: 'line',
        x: 5,
        y: 35,
        width: 70,
        height: 1,
        color: Colors.black,
      ),
      PdfElement(
        type: 'company_name',
        x: 5,
        y: 45,
        content: '{company_name}',
        fontSize: 10,
        bold: true,
      ),
      PdfElement(
        type: 'company_rnc',
        x: 5,
        y: 60,
        content: 'RNC: {company_rnc}',
        fontSize: 8,
      ),
      PdfElement(
        type: 'invoice_number',
        x: 5,
        y: 100,
        content: 'No: {invoice_number}',
        fontSize: 9,
      ),
      PdfElement(type: 'date', x: 5, y: 115, content: '{date}', fontSize: 9),
      PdfElement(
        type: 'client',
        x: 5,
        y: 130,
        content: 'Cliente: {client_name}',
        fontSize: 9,
      ),
      PdfElement(
        type: 'total',
        x: 5,
        y: 155,
        content: 'TOTAL: {total}',
        fontSize: 14,
        bold: true,
      ),
    ];
    update();
  }

  void _createTicketTemplate() {
    elements = [
      PdfElement(
        type: 'company_name',
        x: 10,
        y: 10,
        content: '{company_name}',
        fontSize: 12,
        bold: true,
      ),
      PdfElement(
        type: 'text',
        x: 25,
        y: 30,
        content: '--- TICKET ---',
        fontSize: 10,
        bold: true,
      ),
      PdfElement(
        type: 'invoice_number',
        x: 10,
        y: 50,
        content: 'Ticket: {invoice_number}',
        fontSize: 9,
      ),
      PdfElement(type: 'date', x: 10, y: 65, content: '{date}', fontSize: 9),
      PdfElement(
        type: 'client',
        x: 10,
        y: 85,
        content: '{client_name}',
        fontSize: 9,
      ),
      PdfElement(
        type: 'total',
        x: 10,
        y: 110,
        content: 'Total: {total}',
        fontSize: 12,
        bold: true,
      ),
    ];
    update();
  }

  void _createLabelTemplate() {
    elements = [
      PdfElement(
        type: 'company_name',
        x: 10,
        y: 10,
        content: '{company_name}',
        fontSize: 10,
        bold: true,
      ),
      PdfElement(
        type: 'invoice_number',
        x: 10,
        y: 30,
        content: '{invoice_number}',
        fontSize: 14,
        bold: true,
      ),
      PdfElement(
        type: 'client',
        x: 10,
        y: 50,
        content: '{client_name}',
        fontSize: 8,
      ),
      PdfElement(
        type: 'total',
        x: 10,
        y: 70,
        content: '{total}',
        fontSize: 12,
        bold: true,
      ),
    ];
    update();
  }

  void addElement(String type) {
    final newElement = PdfElement(
      type: type,
      x: 100,
      y: 100,
      content: _getDefaultContent(type),
      fontSize: type == 'text' ? 12 : 0,
      width: _getDefaultWidth(type),
      height: _getDefaultHeight(type),
    );

    elements.add(newElement);
    selectedElementIndex = elements.length - 1;
    update();
  }

  String _getDefaultContent(String type) {
    switch (type) {
      case 'text':
        return 'Nuevo texto';
      case 'invoice_number':
        return 'No. Factura: {invoice_number}';
      case 'date':
        return 'Fecha: {date}';
      case 'client':
        return '{client_name}';
      case 'total':
        return 'Total: {total}';
      case 'company_name':
        return '{company_name}';
      case 'company_rnc':
        return 'RNC: {company_rnc}';
      case 'company_address':
        return '{company_address}';
      case 'company_phone':
        return 'Tel: {company_phone}';
      case 'products_table':
        return 'Tabla de Productos';
      case 'totals_table':
        return 'Tabla de Totales';
      default:
        return 'Elemento';
    }
  }

  double _getDefaultWidth(String type) {
    switch (type) {
      case 'logo':
        return 120;
      case 'line':
        return 200;
      case 'rectangle':
        return 100;
      case 'products_table':
        return 495;
      case 'totals_table':
        return 200;
      default:
        return 0; // Auto width for text
    }
  }

  double _getDefaultHeight(String type) {
    switch (type) {
      case 'logo':
        return 80;
      case 'line':
        return 2;
      case 'rectangle':
        return 50;
      case 'products_table':
        return 200;
      case 'totals_table':
        return 100;
      default:
        return 0; // Auto height for text
    }
  }

  void selectElement(int index) {
    selectedElementIndex = index;
    update();
  }

  void moveElement(int index, Offset delta) {
    if (index >= 0 && index < elements.length) {
      elements[index].x += delta.dx;
      elements[index].y += delta.dy;

      // Mantener dentro de los límites de la página actual
      final format = getCurrentPageFormat();
      elements[index].x = elements[index].x.clamp(
        0,
        format.width - elements[index].width,
      );
      elements[index].y = elements[index].y.clamp(
        0,
        format.height - elements[index].height,
      );

      update();
    }
  }

  void updateElementProperty(String property, dynamic value) {
    if (selectedElementIndex >= 0 && selectedElementIndex < elements.length) {
      final element = elements[selectedElementIndex];

      final format = getCurrentPageFormat();

      switch (property) {
        case 'x':
          element.x = (value as double).clamp(0, format.width);
          break;
        case 'y':
          element.y = (value as double).clamp(0, format.height);
          break;
        case 'width':
          element.width = (value as double).clamp(10, format.width);
          break;
        case 'height':
          element.height = (value as double).clamp(10, format.height);
          break;
        case 'content':
          element.content = value as String;
          break;
        case 'fontSize':
          element.fontSize = (value as double).clamp(6, 72);
          break;
        case 'bold':
          element.bold = value as bool;
          break;
        case 'color':
          element.color = value as Color;
          break;
        case 'backgroundColor':
          element.backgroundColor = value as Color;
          break;
        case 'borderRadius':
          element.borderRadius = (value as double).clamp(0, 50);
          break;
      }

      update();
    }
  }

  void deleteElement(int index) {
    if (index >= 0 && index < elements.length) {
      elements.removeAt(index);
      selectedElementIndex = -1;
      update();
    }
  }

  Future<void> saveTemplate() async {
    try {
      isLoading = true;
      update();

      final templateData = {
        'name': templateName,
        'elements': elements.map((e) => e.toJson()).toList(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Guardar localmente
      _storage.write('last_pdf_template', json.encode(templateData));

      // Guardar en Firestore si el usuario está autenticado
      final user = _auth.currentUser;
      if (user != null) {
        await _db.set('pdf_templates/${user.uid}', templateData);
      }

      Get.snackbar(
        'Éxito',
        'Plantilla guardada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar la plantilla: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> previewPdf() async {
    try {
      isLoading = true;
      update();

      // Usar datos cargados o datos de ejemplo
      final sampleData = hasLoadedJson
          ? erpData
          : {
              'NumeroFacturaInterna': 'F-001',
              'FechaEmision': '15/12/2024',
              'NombrePaciente': 'Juan Pérez',
              'MontoTotal': '1500.00',
              'SubTotal': '1327.43',
              'ITBIS': '172.57',
            };

      // Generar PDF con la plantilla actual y tamaño seleccionado
      final pdfBytes = await CustomPdfService.generatePdfFromTemplate(
        template: elements,
        invoiceData: sampleData,
        format: getCurrentPageFormat(),
      );

      // Mostrar vista previa en el visor personalizado
      Get.to(
        () => PdfViewerWidget(
          pdfBytes: pdfBytes,
          title: 'Vista Previa - $templateName',
          showActions: true,
        ),
      );

      Get.snackbar(
        'Vista Previa',
        'PDF generado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo generar la vista previa: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> printDirectly() async {
    try {
      isLoading = true;
      update();

      Get.snackbar(
        'Imprimiendo',
        'Generando PDF y enviando a impresora...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // Usar datos cargados o datos de ejemplo para la impresión
      final sampleData = hasLoadedJson
          ? erpData
          : {
              'NumeroFacturaInterna':
                  'F-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
              'FechaEmision':
                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              'NombrePaciente': 'Cliente de Prueba',
              'MontoTotal': '1500.00',
              'SubTotal': '1327.43',
              'ITBIS': '172.57',
              'company_name': 'Mi Empresa S.A.',
              'company_rnc': '131-24393-2',
              'company_address': 'Av. Principal #123, Santo Domingo',
              'company_phone': '809-555-1234',
              'client_name': 'Cliente de Prueba',
              'invoice_number':
                  'F-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
              'date':
                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              'total': '\$1,500.00',
            };

      // Generar PDF con la plantilla actual y tamaño seleccionado
      final pdfBytes = await CustomPdfService.generatePdfFromTemplate(
        template: elements,
        invoiceData: sampleData,
        format: getCurrentPageFormat(),
      );

      // Intentar imprimir directamente usando múltiples métodos
      bool printSuccess = false;
      String errorMessage = '';

      print('🖨️ Iniciando impresión directa desde PDF Maker...');

      // Método 1: layoutPdf
      try {
        print('🖨️ Intentando layoutPdf...');
        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: 'Factura - $templateName',
          format: getCurrentPageFormat(),
        );
        printSuccess = true;
        print('✅ layoutPdf exitoso');
      } catch (e1) {
        errorMessage = e1.toString();
        print('❌ layoutPdf falló: $e1');

        // Método 2: directPrintPdf
        try {
          print('🖨️ Intentando directPrintPdf...');
          final printers = await Printing.listPrinters();
          print('🖨️ Impresoras encontradas: ${printers.length}');

          if (printers.isNotEmpty) {
            final defaultPrinter = printers.firstWhere(
              (p) => p.isDefault,
              orElse: () => printers.first,
            );
            print('🖨️ Usando impresora: ${defaultPrinter.name}');

            await Printing.directPrintPdf(
              printer: defaultPrinter,
              onLayout: (format) async => pdfBytes,
              name: 'Factura - $templateName',
              format: getCurrentPageFormat(),
            );
            printSuccess = true;
            print('✅ directPrintPdf exitoso');
          } else {
            throw Exception('No hay impresoras disponibles');
          }
        } catch (e2) {
          print('❌ directPrintPdf falló: $e2');

          // Método 3: sharePdf como último recurso
          try {
            print('🖨️ Intentando sharePdf...');
            await Printing.sharePdf(
              bytes: pdfBytes,
              filename:
                  'Factura_${templateName}_${DateTime.now().millisecondsSinceEpoch}.pdf',
            );

            Get.snackbar(
              'PDF Compartido',
              'Selecciona tu impresora desde la aplicación que se abrió',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.shade600,
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
            );
            print('✅ sharePdf exitoso');
            return;
          } catch (e3) {
            print('❌ sharePdf falló: $e3');
            throw Exception(
              'Todos los métodos de impresión fallaron: $errorMessage',
            );
          }
        }
      }

      if (printSuccess) {
        Get.snackbar(
          'Impresión Exitosa',
          '¡PDF enviado a impresora correctamente!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('💥 Error en impresión directa: $e');

      Get.snackbar(
        'Error de Impresión',
        'No se pudo imprimir: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // Mostrar diálogo con opciones alternativas
      _showPrintingOptions();
    } finally {
      isLoading = false;
      update();
    }
  }

  void _showPrintingOptions() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.print, color: Colors.orange),
            SizedBox(width: 8),
            Text('Opciones de Impresión'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La impresión directa no funcionó. Prueba estas alternativas:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            Text('• Usar "Vista Previa" y luego "Compartir"'),
            Text('• Verificar que la impresora esté encendida'),
            Text('• Configurar la impresora como predeterminada'),
            Text('• Revisar la conexión USB/WiFi de la impresora'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cerrar')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              previewPdf();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005285),
              foregroundColor: Colors.white,
            ),
            child: const Text('Usar Vista Previa'),
          ),
        ],
      ),
    );
  }

  void loadTemplateById(String templateId) {
    // Cargar plantilla específica
    // TODO: Implementar carga de plantillas guardadas
  }

  void duplicateElement(int index) {
    if (index >= 0 && index < elements.length) {
      final original = elements[index];
      final duplicate = PdfElement.fromJson(original.toJson());
      duplicate.x += 20;
      duplicate.y += 20;
      elements.add(duplicate);
      selectedElementIndex = elements.length - 1;
      update();
    }
  }

  void alignElements(String alignment) {
    if (selectedElementIndex >= 0) {
      final element = elements[selectedElementIndex];

      switch (alignment) {
        case 'left':
          element.x = 50;
          break;
        case 'center':
          element.x = (595 - element.width) / 2;
          break;
        case 'right':
          element.x = 595 - element.width - 50;
          break;
        case 'top':
          element.y = 50;
          break;
        case 'middle':
          element.y = (842 - element.height) / 2;
          break;
        case 'bottom':
          element.y = 842 - element.height - 50;
          break;
      }

      update();
    }
  }

  // Métodos para manejo de datos del ERP
  void loadSampleData() {
    erpData = {
      'Factura': {
        'NumeroFacturaInterna': 'F-001234',
        'FechaEmision': '15/12/2024',
        'MontoTotal': '2500.00',
        'SubTotal': '2212.39',
        'ITBIS': '287.61',
        'TipoComprobante': 'E31',
        'Estado': 'Emitida',
      },
      'Cliente': {
        'NombrePaciente': 'Juan Carlos Pérez',
        'CedulaPaciente': '001-1234567-8',
        'TelefonoPaciente': '809-555-1234',
        'DireccionPaciente': 'Calle Principal #123, Santiago',
        'EmailPaciente': 'juan.perez@email.com',
        'NSS': '12345678901',
        'Aseguradora': 'ARS Universal',
      },
      'Empresa': {
        'RazonSocial': 'Centro Médico Salud Total',
        'RNC': '131-24393-2',
        'Direccion': 'Av. 27 de Febrero #456, Santo Domingo',
        'Telefono': '809-580-3555',
        'Email': 'info@saludtotal.com.do',
        'Web': 'www.saludtotal.com.do',
      },
      'Detalles': [
        {
          'Descripcion': 'Consulta Médica General',
          'Cantidad': '1.00',
          'PrecioUnitario': '1500.00',
          'Total': '1500.00',
          'Cobertura': '1200.00',
          'Copago': '300.00',
        },
        {
          'Descripcion': 'Análisis de Laboratorio',
          'Cantidad': '1.00',
          'PrecioUnitario': '800.00',
          'Total': '800.00',
          'Cobertura': '600.00',
          'Copago': '200.00',
        },
        {
          'Descripcion': 'Medicamentos',
          'Cantidad': '2.00',
          'PrecioUnitario': '100.00',
          'Total': '200.00',
          'Cobertura': '0.00',
          'Copago': '200.00',
        },
      ],
      'Medico': {
        'NombreMedico': 'Dr. María González',
        'EspecialidadMedico': 'Medicina General',
        'ExequaturMedico': 'EX-12345',
        'TelefonoMedico': '809-555-9876',
      },
      'Sistema': {
        'FechaCreacion': '15/12/2024 10:30:00',
        'UsuarioCreador': 'admin@saludtotal.com',
        'Version': '1.0.0',
        'CodigoSeguridad': 'ABC123XYZ789',
        'URLValidacion': 'https://dgii.gov.do/validar/ABC123XYZ789',
      },
    };
    update();
  }

  void loadRealErpData(Map<String, dynamic> realData) {
    erpData = realData;
    update();
  }

  void loadJsonData(String jsonString) {
    try {
      jsonInput = jsonString;
      loadedJsonData = json.decode(jsonString);
      hasLoadedJson = true;

      // Actualizar erpData con los datos cargados
      erpData = _flattenJsonData(loadedJsonData);

      Get.snackbar(
        'JSON Cargado',
        'Datos cargados correctamente. ${countFields(erpData)} campos disponibles.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      update();
    } catch (e) {
      Get.snackbar(
        'Error JSON',
        'El JSON no es válido: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Map<String, dynamic> _flattenJsonData(
    Map<String, dynamic> data, [
    String prefix = '',
  ]) {
    Map<String, dynamic> flattened = {};

    data.forEach((key, value) {
      String newKey = prefix.isEmpty ? key : '${prefix}_$key';

      if (value is Map<String, dynamic>) {
        // Si es un objeto, aplanarlo recursivamente
        flattened.addAll(_flattenJsonData(value, newKey));
      } else if (value is List) {
        // Si es una lista, agregar cada elemento con índice
        for (int i = 0; i < value.length; i++) {
          if (value[i] is Map<String, dynamic>) {
            flattened.addAll(
              _flattenJsonData(
                value[i] as Map<String, dynamic>,
                '${newKey}_$i',
              ),
            );
          } else {
            flattened['${newKey}_$i'] = value[i];
          }
        }
        // También agregar la lista completa como string para tablas
        flattened[newKey] = value;
      } else {
        // Si es un valor primitivo, agregarlo directamente
        flattened[newKey] = value;
      }
    });

    return flattened;
  }

  int countFields(Map<String, dynamic> data) {
    return data.keys.where((key) => data[key] is! List).length;
  }

  void clearJsonData() {
    jsonInput = '';
    hasLoadedJson = false;
    loadedJsonData = {};

    // Volver a cargar datos de ejemplo
    loadSampleData();

    Get.snackbar(
      'Datos Limpiados',
      'Se han restaurado los datos de ejemplo',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
    );

    update();
  }

  void showJsonInputDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.code, color: Color(0xFF005285)),
            SizedBox(width: 8),
            Text('Cargar Datos JSON'),
          ],
        ),
        content: SizedBox(
          width: Get.width * 0.8,
          height: Get.height * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pega aquí tu JSON de respuesta:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Text(
                  'Ejemplo:\n{\n  "factura": {\n    "numero": "F-001",\n    "fecha": "2024-12-15"\n  },\n  "cliente": {\n    "nombre": "Juan Pérez",\n    "email": "juan@email.com"\n  }\n}',
                  style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: jsonInput),
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: 'Pega tu JSON aquí...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  onChanged: (value) {
                    jsonInput = value;
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          if (hasLoadedJson)
            TextButton(
              onPressed: () {
                Get.back();
                clearJsonData();
              },
              child: const Text('Limpiar'),
            ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              loadJsonData(jsonInput);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005285),
              foregroundColor: Colors.white,
            ),
            child: const Text('Cargar JSON'),
          ),
        ],
      ),
    );
  }

  void toggleDataInspector() {
    showDataInspector = !showDataInspector;
    update();
  }

  void changePageSize(String newSize) {
    selectedPageSize = newSize;

    // Si es personalizado, actualizar el formato
    if (newSize == 'Personalizado') {
      pageSizes['Personalizado'] = PdfPageFormat(
        customWidth * PdfPageFormat.mm,
        customHeight * PdfPageFormat.mm,
      );
    }

    // Ajustar elementos si es necesario para el nuevo tamaño
    _adjustElementsToPageSize();
    update();
  }

  void updateCustomDimensions(double width, double height) {
    customWidth = width;
    customHeight = height;

    if (selectedPageSize == 'Personalizado') {
      pageSizes['Personalizado'] = PdfPageFormat(
        customWidth * PdfPageFormat.mm,
        customHeight * PdfPageFormat.mm,
      );
      _adjustElementsToPageSize();
    }
    update();
  }

  void _adjustElementsToPageSize() {
    final format = getCurrentPageFormat();
    final maxWidth = format.width;
    final maxHeight = format.height;

    // Ajustar elementos que estén fuera de los límites
    for (final element in elements) {
      if (element.x + element.width > maxWidth) {
        element.x = (maxWidth - element.width).clamp(0, maxWidth);
      }
      if (element.y + element.height > maxHeight) {
        element.y = (maxHeight - element.height).clamp(0, maxHeight);
      }
    }
  }

  PdfPageFormat getCurrentPageFormat() {
    return pageSizes[selectedPageSize] ?? PdfPageFormat.a4;
  }

  Map<String, dynamic> getPageSizeInfo() {
    final format = getCurrentPageFormat();
    return {
      'name': selectedPageSize,
      'width': format.width,
      'height': format.height,
      'widthMM': format.width / PdfPageFormat.mm,
      'heightMM': format.height / PdfPageFormat.mm,
      'widthInch': format.width / PdfPageFormat.inch,
      'heightInch': format.height / PdfPageFormat.inch,
    };
  }

  void addElementFromData(String key, String displayValue, String dataType) {
    final newElement = PdfElement(
      type: _mapDataTypeToElementType(dataType),
      x: 100 + (elements.length * 20), // Offset para evitar superposición
      y: 100 + (elements.length * 20),
      content: '{$key}', // Usar placeholder para mapeo dinámico
      fontSize: _getDefaultFontSize(dataType),
      width: _getDefaultWidthForDataType(dataType),
      height: _getDefaultHeightForDataType(dataType),
      bold: _shouldBeBold(key, dataType),
      color: _getColorForDataType(dataType),
    );

    elements.add(newElement);
    selectedElementIndex = elements.length - 1;

    Get.snackbar(
      'Elemento Agregado',
      'Campo "$key" agregado al PDF',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    update();
  }

  String _mapDataTypeToElementType(String dataType) {
    switch (dataType) {
      case 'number':
      case 'integer':
      case 'decimal':
        return 'currency';
      case 'date':
        return 'date';
      case 'email':
        return 'email';
      case 'phone':
        return 'phone';
      default:
        return 'text';
    }
  }

  double _getDefaultFontSize(String dataType) {
    switch (dataType) {
      case 'number':
      case 'decimal':
        return 14; // Números más grandes
      case 'date':
        return 10; // Fechas más pequeñas
      default:
        return 12;
    }
  }

  double _getDefaultWidthForDataType(String dataType) {
    switch (dataType) {
      case 'date':
        return 100;
      case 'phone':
        return 120;
      case 'email':
        return 200;
      case 'number':
      case 'decimal':
        return 80;
      default:
        return 0; // Auto width
    }
  }

  double _getDefaultHeightForDataType(String dataType) {
    return 0; // Auto height para texto
  }

  bool _shouldBeBold(String key, String dataType) {
    final boldKeys = ['total', 'subtotal', 'nombre', 'razonsocial', 'titulo'];
    return boldKeys.any((boldKey) => key.toLowerCase().contains(boldKey)) ||
        dataType == 'number' ||
        dataType == 'decimal';
  }

  Color _getColorForDataType(String dataType) {
    switch (dataType) {
      case 'number':
      case 'decimal':
        return Colors.green.shade700; // Verde para montos
      case 'date':
        return Colors.blue.shade700; // Azul para fechas
      case 'email':
        return Colors.purple.shade700; // Púrpura para emails
      case 'phone':
        return Colors.teal.shade700; // Teal para teléfonos
      default:
        return Colors.black;
    }
  }

  void acceptDataDrop(Map<String, dynamic> dragData, Offset position) {
    final key = dragData['key'] as String;
    final dataType = dragData['type'] as String;

    // Ajustar posición a la grilla si está habilitado
    final adjustedPosition = isSnapToGrid ? _snapToGrid(position) : position;

    final newElement = PdfElement(
      type: _mapDataTypeToElementType(dataType),
      x: adjustedPosition.dx,
      y: adjustedPosition.dy,
      content: '{$key}',
      fontSize: _getDefaultFontSize(dataType),
      width: _getDefaultWidthForDataType(dataType),
      height: _getDefaultHeightForDataType(dataType),
      bold: _shouldBeBold(key, dataType),
      color: _getColorForDataType(dataType),
    );

    // Guardar estado para undo
    _saveToHistory();

    elements.add(newElement);
    selectedElementIndex = elements.length - 1;

    Get.snackbar(
      'Campo Mapeado',
      'Campo "$key" agregado en posición (${adjustedPosition.dx.toInt()}, ${adjustedPosition.dy.toInt()})',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    update();
  }

  // ========== FUNCIONALIDADES AVANZADAS ==========

  // Grilla y ajuste
  Offset _snapToGrid(Offset position) {
    if (!isSnapToGrid) return position;

    final snappedX = (position.dx / gridSize).round() * gridSize;
    final snappedY = (position.dy / gridSize).round() * gridSize;

    return Offset(snappedX, snappedY);
  }

  void toggleGrid() {
    isGridEnabled = !isGridEnabled;
    update();
  }

  void toggleSnapToGrid() {
    isSnapToGrid = !isSnapToGrid;
    update();
  }

  void setGridSize(double size) {
    gridSize = size.clamp(5.0, 50.0);
    update();
  }

  // Zoom
  void zoomIn() {
    zoomLevel = (zoomLevel * 1.2).clamp(0.1, 5.0);
    update();
  }

  void zoomOut() {
    zoomLevel = (zoomLevel / 1.2).clamp(0.1, 5.0);
    update();
  }

  void resetZoom() {
    zoomLevel = 1.0;
    update();
  }

  void setZoom(double zoom) {
    zoomLevel = zoom.clamp(0.1, 5.0);
    update();
  }

  // Historial (Undo/Redo)
  void _saveToHistory() {
    // Remover elementos futuros si estamos en el medio del historial
    if (historyIndex < history.length - 1) {
      history.removeRange(historyIndex + 1, history.length);
    }

    // Agregar estado actual
    history.add(elements.map((e) => PdfElement.fromJson(e.toJson())).toList());
    historyIndex = history.length - 1;

    // Limitar historial a 50 elementos
    if (history.length > 50) {
      history.removeAt(0);
      historyIndex--;
    }
  }

  void undo() {
    if (canUndo()) {
      historyIndex--;
      elements = history[historyIndex]
          .map((e) => PdfElement.fromJson(e.toJson()))
          .toList();
      selectedElementIndex = -1;
      update();

      Get.snackbar(
        'Deshacer',
        'Acción deshecha',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    }
  }

  void redo() {
    if (canRedo()) {
      historyIndex++;
      elements = history[historyIndex]
          .map((e) => PdfElement.fromJson(e.toJson()))
          .toList();
      selectedElementIndex = -1;
      update();

      Get.snackbar(
        'Rehacer',
        'Acción rehecha',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    }
  }

  bool canUndo() => historyIndex > 0;
  bool canRedo() => historyIndex < history.length - 1;

  // Selección múltiple
  void toggleMultiSelect() {
    isMultiSelectMode = !isMultiSelectMode;
    if (!isMultiSelectMode) {
      selectedElements.clear();
    }
    update();
  }

  void selectMultipleElements(int index) {
    if (isMultiSelectMode) {
      if (selectedElements.contains(index)) {
        selectedElements.remove(index);
      } else {
        selectedElements.add(index);
      }
    } else {
      selectedElementIndex = index;
    }
    update();
  }

  void selectAllElements() {
    selectedElements = List.generate(elements.length, (index) => index);
    isMultiSelectMode = true;
    update();
  }

  void deselectAll() {
    selectedElements.clear();
    selectedElementIndex = -1;
    update();
  }

  // Operaciones con selección múltiple
  void deleteSelectedElements() {
    if (selectedElements.isNotEmpty) {
      _saveToHistory();

      // Ordenar índices de mayor a menor para eliminar correctamente
      selectedElements.sort((a, b) => b.compareTo(a));

      for (int index in selectedElements) {
        if (index < elements.length) {
          elements.removeAt(index);
        }
      }

      selectedElements.clear();
      selectedElementIndex = -1;
      update();

      Get.snackbar(
        'Elementos Eliminados',
        '${selectedElements.length} elementos eliminados',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (selectedElementIndex >= 0) {
      deleteElement(selectedElementIndex);
    }
  }

  void duplicateSelectedElements() {
    if (selectedElements.isNotEmpty) {
      _saveToHistory();

      List<PdfElement> newElements = [];

      for (int index in selectedElements) {
        if (index < elements.length) {
          final original = elements[index];
          final duplicate = PdfElement.fromJson(original.toJson());
          duplicate.x += 20;
          duplicate.y += 20;
          newElements.add(duplicate);
        }
      }

      elements.addAll(newElements);

      // Seleccionar los elementos duplicados
      selectedElements.clear();
      for (int i = 0; i < newElements.length; i++) {
        selectedElements.add(elements.length - newElements.length + i);
      }

      update();

      Get.snackbar(
        'Elementos Duplicados',
        '${newElements.length} elementos duplicados',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Alineación de elementos
  void alignSelectedElements(String alignment) {
    if (selectedElements.length < 2) return;

    _saveToHistory();

    final selectedElementsList = selectedElements
        .map((i) => elements[i])
        .toList();

    switch (alignment) {
      case 'left':
        final leftMost = selectedElementsList
            .map((e) => e.x)
            .reduce((a, b) => a < b ? a : b);
        for (int index in selectedElements) {
          elements[index].x = leftMost;
        }
        break;
      case 'right':
        final rightMost = selectedElementsList
            .map((e) => e.x + e.width)
            .reduce((a, b) => a > b ? a : b);
        for (int index in selectedElements) {
          elements[index].x = rightMost - elements[index].width;
        }
        break;
      case 'top':
        final topMost = selectedElementsList
            .map((e) => e.y)
            .reduce((a, b) => a < b ? a : b);
        for (int index in selectedElements) {
          elements[index].y = topMost;
        }
        break;
      case 'bottom':
        final bottomMost = selectedElementsList
            .map((e) => e.y + e.height)
            .reduce((a, b) => a > b ? a : b);
        for (int index in selectedElements) {
          elements[index].y = bottomMost - elements[index].height;
        }
        break;
      case 'center_horizontal':
        final centerX =
            selectedElementsList
                .map((e) => e.x + e.width / 2)
                .reduce((a, b) => a + b) /
            selectedElementsList.length;
        for (int index in selectedElements) {
          elements[index].x = centerX - elements[index].width / 2;
        }
        break;
      case 'center_vertical':
        final centerY =
            selectedElementsList
                .map((e) => e.y + e.height / 2)
                .reduce((a, b) => a + b) /
            selectedElementsList.length;
        for (int index in selectedElements) {
          elements[index].y = centerY - elements[index].height / 2;
        }
        break;
    }

    update();
  }

  // Distribución de elementos
  void distributeSelectedElements(String direction) {
    if (selectedElements.length < 3) return;

    _saveToHistory();

    final selectedElementsList = selectedElements
        .map((i) => elements[i])
        .toList();

    if (direction == 'horizontal') {
      selectedElementsList.sort((a, b) => a.x.compareTo(b.x));
      final leftMost = selectedElementsList.first.x;
      final rightMost =
          selectedElementsList.last.x + selectedElementsList.last.width;
      final totalSpace = rightMost - leftMost;
      final spacing = totalSpace / (selectedElementsList.length - 1);

      for (int i = 1; i < selectedElementsList.length - 1; i++) {
        selectedElementsList[i].x = leftMost + (spacing * i);
      }
    } else {
      selectedElementsList.sort((a, b) => a.y.compareTo(b.y));
      final topMost = selectedElementsList.first.y;
      final bottomMost =
          selectedElementsList.last.y + selectedElementsList.last.height;
      final totalSpace = bottomMost - topMost;
      final spacing = totalSpace / (selectedElementsList.length - 1);

      for (int i = 1; i < selectedElementsList.length - 1; i++) {
        selectedElementsList[i].y = topMost + (spacing * i);
      }
    }

    update();
  }

  // Auto-mapeo inteligente
  void autoMapFields() {
    if (!hasLoadedJson) {
      Get.snackbar(
        'Sin Datos',
        'Primero carga un JSON para usar el auto-mapeo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
      );
      return;
    }

    _saveToHistory();

    // Limpiar elementos existentes
    elements.clear();

    // Mapeo inteligente basado en nombres de campos comunes
    final commonMappings = {
      // Facturas
      'numero': {'x': 400.0, 'y': 50.0, 'fontSize': 16.0, 'bold': true},
      'fecha': {'x': 400.0, 'y': 80.0, 'fontSize': 12.0},
      'total': {'x': 400.0, 'y': 500.0, 'fontSize': 18.0, 'bold': true},
      'subtotal': {'x': 400.0, 'y': 470.0, 'fontSize': 14.0},

      // Cliente
      'nombre': {'x': 50.0, 'y': 200.0, 'fontSize': 14.0, 'bold': true},
      'email': {'x': 50.0, 'y': 230.0, 'fontSize': 10.0},
      'telefono': {'x': 50.0, 'y': 250.0, 'fontSize': 10.0},
      'direccion': {'x': 50.0, 'y': 270.0, 'fontSize': 10.0},

      // Empresa
      'empresa': {'x': 50.0, 'y': 50.0, 'fontSize': 16.0, 'bold': true},
      'rnc': {'x': 50.0, 'y': 80.0, 'fontSize': 10.0},
    };

    int yOffset = 0;

    erpData.forEach((key, value) {
      if (value is! List) {
        final lowerKey = key.toLowerCase();
        Map<String, dynamic>? mapping;

        // Buscar mapeo por coincidencia de palabras clave
        for (String commonKey in commonMappings.keys) {
          if (lowerKey.contains(commonKey)) {
            mapping = commonMappings[commonKey];
            break;
          }
        }

        // Si no hay mapeo específico, usar posición por defecto
        mapping ??= {
          'x': 50.0,
          'y': 300.0 + (yOffset * 25.0),
          'fontSize': 12.0,
          'bold': false,
        };

        final element = PdfElement(
          type: 'text',
          x: mapping['x'],
          y: mapping['y'],
          content: '{$key}',
          fontSize: mapping['fontSize'],
          bold: mapping['bold'] ?? false,
          color: _getColorForDataType(_inferDataType(value)),
        );

        elements.add(element);
        yOffset++;
      }
    });

    Get.snackbar(
      'Auto-mapeo Completado',
      '${elements.length} campos mapeados automáticamente',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
    );

    update();
  }

  String _inferDataType(dynamic value) {
    if (value is num) return 'number';
    if (value is String) {
      if (value.contains('@')) return 'email';
      if (value.contains('-') && value.length >= 8) return 'phone';
      if (value.contains('/') || value.contains('-')) return 'date';
    }
    return 'text';
  }
}
