import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../models/erp_invoice.dart';
import '../models/erp_invoice_extensions.dart';
import '../services/company_config_service.dart';
import '../services/enhanced_invoice_pdf_service.dart';
import '../widgets/pdf_viewer_widget.dart';

/// Modal simple para ver el PDF de la factura más grande y descargarlo directamente
class SimpleInvoiceModal extends StatefulWidget {
  final ERPInvoice invoice;
  final String title;

  const SimpleInvoiceModal({
    super.key,
    required this.invoice,
    required this.title,
  });

  @override
  State<SimpleInvoiceModal> createState() => _SimpleInvoiceModalState();
}

class _SimpleInvoiceModalState extends State<SimpleInvoiceModal> {
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
      final bytes = await _buildPdf(PdfPageFormat.a4, widget.invoice);
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
    final companyName = companyData?['razonSocial'] as String? ?? 'Empresa';

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
            // Header del modal
            _buildHeader(companyName),

            // Contenido principal - PDF
            Expanded(
              child: _buildPdfViewer(),
            ),

            // Barra de acciones
            _buildActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String companyName) {
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
            child: const Icon(
              Icons.description,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Información de la factura
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Factura - $companyName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.invoice.encf ?? 'Sin ENCF',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                if (widget.invoice.clienteNombre.isNotEmpty)
                  Text(
                    'Cliente: ${widget.invoice.clienteNombre}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
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

  Widget _buildPdfViewer() {
    if (loading) {
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

    if (generatingPdf) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Generando PDF...',
              style: TextStyle(fontSize: 16),
            ),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
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

    // Vista previa del PDF MÁS GRANDE - ocupa casi todo el modal
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
        child: QuickPdfPreview(
          pdfBytes: pdfBytes!,
          // PDF ocupa casi todo el espacio del modal
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.65,
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
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Información del archivo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getFileName(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Total: ${widget.invoice.formattedTotal}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
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
                icon: Icons.print,
                label: 'Imprimir',
                color: Colors.blue,
                onPressed: pdfBytes != null ? () => _printPdf() : null,
              ),
              const SizedBox(width: 12),

              // Botón Descargar DIRECTO
              _ActionButton(
                icon: Icons.download,
                label: 'Descargar',
                color: Colors.green,
                onPressed: pdfBytes != null ? () => _downloadPdfDirect() : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFileName() {
    final rnc = widget.invoice.rncemisor ?? 'SIN_RNC';
    final encf = widget.invoice.encf ?? 'SIN_ENCF';
    return '${rnc}${encf}.pdf';
  }

  Future<void> _printPdf() async {
    if (pdfBytes == null) return;

    try {
      final rnc = widget.invoice.rncemisor ?? 'SIN_RNC';
      final encf = widget.invoice.encf ?? 'SIN_ENCF';
      final fileName = '${rnc}${encf}';

      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes!,
        name: fileName,
        format: PdfPageFormat.a4,
      );

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

  Future<void> _downloadPdfDirect() async {
    if (pdfBytes == null) return;

    try {
      final fileName = _getFileName();

      // Descarga DIRECTA usando Printing.sharePdf
      await Printing.sharePdf(
        bytes: pdfBytes!,
        filename: fileName,
      );

      Get.snackbar(
        'Descarga',
        'Archivo $fileName descargado',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.download, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo descargar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format, ERPInvoice inv) async {
    debugPrint('');
    debugPrint('📄 GENERANDO PDF MODAL - SIMPLE INVOICE 📄');
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
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    );
  }
}

/// Función helper para mostrar el modal simple
void showSimpleInvoiceModal({
  required BuildContext context,
  required ERPInvoice invoice,
  String? customTitle,
}) {
  final title = customTitle ??
      'Factura ${invoice.numeroFactura.isNotEmpty ? invoice.numeroFactura : 'CENSAVID'}';

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => SimpleInvoiceModal(
      invoice: invoice,
      title: title,
    ),
  );
}
