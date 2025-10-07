import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/invoice.dart';
import '../../models/tipo_comprobante.dart';
import '../../services/invoice_pdf_service.dart';

class InvoicePreviewScreen extends StatelessWidget {
  const InvoicePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Datum inv = Get.arguments as Datum;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF005285),
        title: const Text('Factura CENSAVID', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PdfPreview(
        canChangeOrientation: true,
        canDebug: false,
        build: (format) => _buildPdf(format, inv),
        pdfFileName: 'Factura_${inv.fDocumento ?? inv.encf ?? 'CENSAVID'}.pdf',
        initialPageFormat: PdfPageFormat.a4,
        allowSharing: true,
        allowPrinting: true,
      ),
    );
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format, Datum inv) async {
    return InvoicePdfService.buildPdf(format, inv);
  }

  pw.TableRow _row(String k, String? v) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.white),
      children: [
        pw.Container(
          padding: pw.EdgeInsets.all(6),
          child: pw.Text(k, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(6),
          child: pw.Text(v ?? '-', style: pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }

  pw.Widget _totalRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(width: 8),
        pw.Text(value, style: pw.TextStyle(fontSize: 11)),
      ],
    );
  }
}