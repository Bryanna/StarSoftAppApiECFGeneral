import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';

import '../../models/erp_invoice.dart';

import '../../services/enhanced_invoice_pdf_service.dart';
import '../../services/company_config_service.dart';
import '../../widgets/pdf_viewer_widget.dart';

class InvoicePreviewScreen extends StatefulWidget {
  const InvoicePreviewScreen({super.key});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  Map<String, dynamic>? companyData;
  bool loading = true;

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
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ERPInvoice inv = Get.arguments as ERPInvoice;

    // Obtener datos de la empresa
    final companyName = companyData?['razonSocial'] as String? ?? 'Empresa';
    final companyRnc = companyData?['rnc'] as String? ?? '';

    // Crear título para el AppBar (solo nombre de empresa)
    final title = 'Factura - $companyName';

    // Crear nombre de archivo más descriptivo
    final fileName = companyRnc.isNotEmpty
        ? 'Factura_${inv.numeroFactura.isNotEmpty ? inv.numeroFactura : 'DOC'}_$companyRnc.pdf'
        : 'Factura_${inv.numeroFactura.isNotEmpty ? inv.numeroFactura : companyName}.pdf';

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: const Color(0xFF005285),
        title: loading
            ? const Text('Cargando...', style: TextStyle(color: Colors.white))
            : Text(title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF005285)),
              ),
            )
          : FutureBuilder<Uint8List>(
              future: _buildPdf(PdfPageFormat.a4, inv),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF005285),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error generando PDF: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                return QuickPdfPreview(pdfBytes: snapshot.data!);
              },
            ),
    );
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format, ERPInvoice inv) async {
    debugPrint('');
    debugPrint('🔥🔥🔥 BUILD PDF CALLED - INVOICE PREVIEW 🔥🔥🔥');
    debugPrint('🔥 About to call EnhancedInvoicePdfService.buildPdf');
    debugPrint('');

    // Debug de los campos del ERP
    debugPrint('🔍 INVOICE PREVIEW DEBUG:');
    debugPrint('🔍 encf (eCF): ${inv.encf}');
    debugPrint(
      '🔍 numerofacturainterna (No. Factura): ${inv.numerofacturainterna}',
    );
    debugPrint('🔍 tipoFacturaTitulo: "${inv.tipoFacturaTitulo}"');
    debugPrint('🔍 aseguradora: "${inv.aseguradora}"');
    debugPrint('🔍 nss: "${inv.nss}"');
    debugPrint('🔍 medico: "${inv.medico}"');
    debugPrint('🔍 cedulaMedico: "${inv.cedulaMedico}"');
    debugPrint('🔍 fechaemision: "${inv.fechaemision}"');

    // Convertir ERPInvoice a Map para el PDF service (más seguro que Datum)
    final invoiceMap = _convertERPInvoiceToMap(inv);

    // Debug del map
    debugPrint(
      '🔍 Map tipo_factura_titulo: "${invoiceMap['tipo_factura_titulo']}"',
    );
    debugPrint(
      '🔍 Map NumeroFacturaInterna: "${invoiceMap['NumeroFacturaInterna']}"',
    );
    debugPrint('🔍 Map FechaEmision: "${invoiceMap['FechaEmision']}"');

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
