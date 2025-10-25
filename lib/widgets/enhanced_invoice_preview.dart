import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/erp_invoice.dart';
import '../models/erp_invoice_extensions.dart';
import '../services/enhanced_invoice_pdf_service.dart';
import '../services/pdf_viewer_service.dart';

/// Vista previa mejorada de facturas con tamaño grande y opciones de descarga
class EnhancedInvoicePreview extends StatefulWidget {
  final ERPInvoice invoice;
  final String title;

  const EnhancedInvoicePreview({
    super.key,
    required this.invoice,
    required this.title,
  });

  @override
  State<EnhancedInvoicePreview> createState() => _EnhancedInvoicePreviewState();
}

class _EnhancedInvoicePreviewState extends State<EnhancedInvoicePreview> {
  Uint8List? pdfBytes;
  bool isGenerating = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    setState(() {
      isGenerating = true;
      error = null;
    });

    try {
      final invoiceMap = _convertERPInvoiceToMap(widget.invoice);
      final bytes = await EnhancedInvoicePdfService.buildPdf(
        PdfPageFormat.a4,
        invoiceMap,
      );

      setState(() {
        pdfBytes = bytes;
        isGenerating = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error generando PDF: $e';
        isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header mejorado
            _buildHeader(),

            // Contenido principal
            Expanded(child: _buildContent()),

            // Barra de acciones mejorada
            _buildActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Icono de factura
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),

          // Información de la factura
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ENCF: ${widget.invoice.encf ?? 'N/A'} • ${widget.invoice.formattedFechaEmision}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Total: ${widget.invoice.formattedTotal}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Botón cerrar
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isGenerating) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generando vista previa...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error al generar vista previa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.red.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generatePdf,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (pdfBytes == null) {
      return const Center(child: Text('No se pudo generar la vista previa'));
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PdfPreview(
          build: (format) => pdfBytes!,
          allowPrinting: false,
          allowSharing: false,
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          scrollViewDecoration: BoxDecoration(color: Colors.grey.shade50),
          pdfPreviewPageDecoration: const BoxDecoration(color: Colors.white),
          // Hacer la vista previa más grande
          maxPageWidth: MediaQuery.of(context).size.width * 0.8,
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Información adicional
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cliente: ${widget.invoice.clienteNombre}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Tipo: ${widget.invoice.tipoComprobanteDisplay}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Botones de acción
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón Imprimir
              _ActionButton(
                icon: FontAwesomeIcons.print,
                label: 'Imprimir',
                color: Colors.blue,
                onPressed: pdfBytes != null ? () => _printPdf() : null,
              ),
              const SizedBox(width: 12),

              // Botón Descargar
              _ActionButton(
                icon: FontAwesomeIcons.download,
                label: 'Descargar',
                color: Colors.green,
                onPressed: pdfBytes != null ? () => _downloadPdf() : null,
              ),
              const SizedBox(width: 12),

              // Botón Ver Completo
              _ActionButton(
                icon: FontAwesomeIcons.expand,
                label: 'Ver Completo',
                color: Theme.of(context).colorScheme.primary,
                onPressed: pdfBytes != null ? () => _viewFullscreen() : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _printPdf() async {
    if (pdfBytes == null) return;

    try {
      // Crear nombre de archivo con formato RNC+ENCF (sin .pdf para impresión)
      final rnc = widget.invoice.rncemisor ?? 'SIN_RNC';
      final encf = widget.invoice.encf ?? 'SIN_ENCF';
      final fileName = '$rnc$encf';

      await PdfViewerService.printPdf(pdfBytes: pdfBytes!, title: fileName);

      Get.snackbar(
        'Impresión',
        'Factura enviada a impresora',
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

  Future<void> _downloadPdf() async {
    if (pdfBytes == null) return;

    try {
      // Crear nombre de archivo con formato RNC+ENCF.pdf
      final rnc = widget.invoice.rncemisor ?? 'SIN_RNC';
      final encf = widget.invoice.encf ?? 'SIN_ENCF';
      final fileName = '$rnc$encf.pdf';

      // Cerrar el diálogo y mostrar el visor completo con opciones de descarga
      Navigator.of(context).pop();

      PdfViewerService.showPdf(
        pdfBytes: pdfBytes!,
        title: fileName,
        showActions: true,
      );

      Get.snackbar(
        'Descarga',
        'Abriendo visor con opciones de descarga',
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

  void _viewFullscreen() {
    if (pdfBytes == null) return;

    // Crear nombre de archivo con formato RNC+ENCF.pdf
    final rnc = widget.invoice.rncemisor ?? 'SIN_RNC';
    final encf = widget.invoice.encf ?? 'SIN_ENCF';
    final fileName = '$rnc$encf.pdf';

    Navigator.of(context).pop();

    PdfViewerService.showPdfFullscreen(pdfBytes: pdfBytes!, title: fileName);
  }

  Map<String, dynamic> _convertERPInvoiceToMap(ERPInvoice invoice) {
    // Convertir ERPInvoice a Map para el servicio de PDF
    return {
      'ENCF': invoice.encf,
      'Version': invoice.version,
      'TipoeCF': invoice.tipoecf,
      'FechaEmision': invoice.fechaemision,
      'RNCEmisor': invoice.rncemisor,
      'RazonSocialEmisor': invoice.razonsocialemisor,
      'DireccionEmisor': invoice.direccionemisor,
      'TelefonoEmisor[1]': invoice.telefonoemisor1,
      'CorreoEmisor': invoice.correoemisor,
      'RNCComprador': invoice.rnccomprador,
      'RazonSocialComprador': invoice.razonsocialcomprador,
      'DireccionComprador': invoice.direccioncomprador,
      'MontoGravadoTotal': invoice.montogravadototal,
      'MontoExento': invoice.montoexento,
      'TotalITBIS': invoice.totalitbis,
      'MontoTotal': invoice.montototal,
      'DetalleFactura': invoice.detalleFactura,
      'tipo_factura_titulo': invoice.tipoFacturaTitulo,
      'aseguradora': invoice.aseguradora,
      'no_autorizacion': invoice.noAutorizacion,
      'nss': invoice.nss,
      'medico': invoice.medico,
      'cedula_medico': invoice.cedulaMedico,
    };
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: FaIcon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    );
  }
}

/// Función helper para mostrar la vista previa mejorada
void showEnhancedInvoicePreview({
  required BuildContext context,
  required ERPInvoice invoice,
  String? customTitle,
}) {
  final title =
      customTitle ??
      'Factura ${invoice.numeroFactura.isNotEmpty ? invoice.numeroFactura : 'CENSAVID'}';

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) =>
        EnhancedInvoicePreview(invoice: invoice, title: title),
  );
}
