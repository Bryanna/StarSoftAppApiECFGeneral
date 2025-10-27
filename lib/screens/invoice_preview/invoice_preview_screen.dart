import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';

import '../../models/erp_invoice.dart';
import '../../services/enhanced_invoice_pdf_service.dart';
import '../../services/company_config_service.dart';
import '../../services/pdf_viewer_service.dart';
import '../../widgets/pdf_viewer_widget.dart';

/// Pantalla simple para ver el PDF de la factura más grande y con opciones de descarga
class InvoicePreviewScreen extends StatefulWidget {
  const InvoicePreviewScreen({super.key});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  Map<String, dynamic>? companyData;
  bool loading = true;
  Uint8List? pdfBytes;
  bool generatingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    try {
      final configService = CompanyConfigService();
      final data = await configService.getCompanyConfig();
      setState(() {
        companyData = data;
        loading = false;
      });
      // Generar PDF después de cargar datos de la empresa
      _generatePdf();
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _generatePdf() async {
    if (generatingPdf) return;

    setState(() {
      generatingPdf = true;
    });

    try {
      final ERPInvoice inv = Get.arguments as ERPInvoice;
      final bytes = await _buildPdf(PdfPageFormat.a4, inv);
      setState(() {
        pdfBytes = bytes;
        generatingPdf = false;
      });
    } catch (e) {
      setState(() {
        generatingPdf = false;
      });
      Get.snackbar(
        'Error',
        'No se pudo generar el PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ERPInvoice inv = Get.arguments as ERPInvoice;
    final companyName = companyData?['razonSocial'] as String? ?? 'Empresa';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Factura - $companyName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              inv.encf ?? 'Sin ENCF',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // Botón de descarga
          if (pdfBytes != null)
            IconButton(
              onPressed: () => _downloadPdf(inv),
              icon: const Icon(Icons.download),
              tooltip: 'Descargar PDF',
            ),
          // Botón de impresión
          if (pdfBytes != null)
            IconButton(
              onPressed: () => _printPdf(inv),
              icon: const Icon(Icons.print),
              tooltip: 'Imprimir',
            ),
          // Menú adicional
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, inv),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'fullscreen',
                child: ListTile(
                  leading: Icon(Icons.fullscreen),
                  title: Text('Pantalla Completa'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Compartir'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Regenerar PDF'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: loading ? _buildLoadingState() : _buildPdfViewer(inv),
      floatingActionButton: pdfBytes != null
          ? FloatingActionButton.extended(
              onPressed: () => _downloadPdf(inv),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.download),
              label: const Text('Descargar'),
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando información de la factura...'),
        ],
      ),
    );
  }

  Widget _buildPdfViewer(ERPInvoice inv) {
    if (generatingPdf) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generando PDF...', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(
              'Por favor espera un momento',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (pdfBytes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error al generar el PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No se pudo generar el documento PDF',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generatePdf,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Vista previa del PDF más grande - OCUPA TODA LA PANTALLA
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: QuickPdfPreview(
            pdfBytes: pdfBytes!,
            // Hacer la vista MÁS GRANDE - ocupa casi toda la pantalla
            width: MediaQuery.of(context).size.width - 16,
            height: MediaQuery.of(context).size.height - 200,
          ),
        ),
      ),
    );
  }

  // Métodos de acción
  void _handleMenuAction(String action, ERPInvoice inv) {
    switch (action) {
      case 'fullscreen':
        _viewFullscreen(inv);
        break;
      case 'share':
        _sharePdf(inv);
        break;
      case 'refresh':
        _generatePdf();
        break;
    }
  }

  Future<void> _downloadPdf(ERPInvoice inv) async {
    if (pdfBytes == null) return;

    // Crear nombre de archivo con formato RNC+ENCF.pdf
    final rnc = inv.rncemisor ?? 'SIN_RNC';
    final encf = inv.encf ?? 'SIN_ENCF';
    final fileName = '$rnc$encf.pdf';

    try {
      PdfViewerService.showPdf(
        pdfBytes: pdfBytes!,
        title: fileName,
        showActions: true,
      );

      Get.snackbar(
        'PDF Abierto',
        'Documento abierto en el visor con opciones de descarga',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.download, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo abrir el visor: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _printPdf(ERPInvoice inv) async {
    if (pdfBytes == null) return;

    try {
      // Crear nombre de archivo con formato RNC+ENCF (sin .pdf para impresión)
      final rnc = inv.rncemisor ?? 'SIN_RNC';
      final encf = inv.encf ?? 'SIN_ENCF';
      final fileName = '$rnc$encf';

      await PdfViewerService.printPdf(pdfBytes: pdfBytes!, title: fileName);

      Get.snackbar(
        'Impresión',
        'Documento enviado a impresora',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        icon: const Icon(Icons.print, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo imprimir: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _viewFullscreen(ERPInvoice inv) {
    if (pdfBytes == null) return;

    // Crear nombre de archivo con formato RNC+ENCF.pdf
    final rnc = inv.rncemisor ?? 'SIN_RNC';
    final encf = inv.encf ?? 'SIN_ENCF';
    final fileName = '$rnc$encf.pdf';

    PdfViewerService.showPdfFullscreen(pdfBytes: pdfBytes!, title: fileName,
    );
  }

  Future<void> _sharePdf(ERPInvoice inv) async {
    if (pdfBytes == null) return;

    // Crear nombre de archivo con formato RNC+ENCF.pdf
    final rnc = inv.rncemisor ?? 'SIN_RNC';
    final encf = inv.encf ?? 'SIN_ENCF';
    final fileName = '$rnc$encf.pdf';

    // Mostrar el visor con opciones de compartir
    PdfViewerService.showPdf(
      pdfBytes: pdfBytes!,
      title: fileName,
      showActions: true,
    );
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format, ERPInvoice inv) async {
    debugPrint('');
    debugPrint('📄 GENERANDO PDF SIMPLE - INVOICE PREVIEW 📄');
    debugPrint('📄 ENCF: ${inv.encf}');
    debugPrint('📄 Cliente: ${inv.clienteNombre}');
    debugPrint('📄 Total: ${inv.montototal}');
    debugPrint('');

    // Convertir ERPInvoice a Map para el PDF service
    final invoiceMap = _convertERPInvoiceToMap(inv);

    return EnhancedInvoicePdfService.buildPdf(format, invoiceMap);
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
      'TipoeCF': erp.tipoecf ?? '',

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

      // Detalle de la factura (JSON string del ERP)
      'DetalleFactura': erp.detalleFactura ?? '',
      'detalleFactura': erp.detalleFactura ?? '',
      'detalle_factura': erp.detalleFactura ?? '',

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
}
