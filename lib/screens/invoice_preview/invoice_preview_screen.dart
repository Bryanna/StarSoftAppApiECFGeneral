import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';

import 'package:printing/printing.dart';

import '../../models/invoice.dart';

import '../../services/invoice_pdf_service.dart';
import '../../services/company_config_service.dart';

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
    final Datum inv = Get.arguments as Datum;

    // Obtener datos de la empresa
    final companyName = companyData?['razonSocial'] as String? ?? 'Empresa';
    final companyRnc = companyData?['rnc'] as String? ?? '';

    // Crear título para el AppBar (solo nombre de empresa)
    final title = 'Factura - $companyName';

    // Crear nombre de archivo más descriptivo
    final fileName = companyRnc.isNotEmpty
        ? 'Factura_${inv.fDocumento ?? inv.encf ?? 'DOC'}_$companyRnc.pdf'
        : 'Factura_${inv.fDocumento ?? inv.encf ?? companyName}.pdf';

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
          : PdfPreview(
              canChangeOrientation: true,
              canDebug: false,
              build: (format) => _buildPdf(format, inv),
              pdfFileName: fileName,
              initialPageFormat: PdfPageFormat.a4,
              allowSharing: true,
              allowPrinting: true,
            ),
    );
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format, Datum inv) async {
    return InvoicePdfService.buildPdf(format, inv);
  }
}
