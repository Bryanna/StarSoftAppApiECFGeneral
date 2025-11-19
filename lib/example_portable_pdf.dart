import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:facturacion/pdf_portable/enhanced_invoice_pdf.dart';

class ExamplePortableInvoicePreview extends StatelessWidget {
  final Map<String, dynamic> invoice;
  final Map<String, dynamic>? company;
  final String? user;

  const ExamplePortableInvoicePreview({
    super.key,
    required this.invoice,
    this.company,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      build: (format) => EnhancedInvoicePdf.buildPdf(
        PdfPageFormat.a4,
        invoice,
        companyConfig: company,
        userDisplayName: user,
      ),
    );
  }
}

Future<void> generateAndPrintExample() async {
  final invoice = {
    'invoiceNumber': 'F0001-00000123',
    'date': DateTime.now().toIso8601String(),
    'customerName': 'Cliente Demo',
    'customerId': '001-0000000-0',
    'items': [
      {'name': 'Producto A', 'qty': 2, 'price': 500.0},
      {'name': 'Producto B', 'qty': 1, 'price': 350.0},
    ],
    'tax': 0.18,
  };
  final company = {
    'name': 'Mi Empresa SRL',
    'address': 'Calle Principal #123',
    'phone': '809-000-0000',
    'logoBytes': null,
  };

  final bytes = await EnhancedInvoicePdf.buildPdf(
    PdfPageFormat.a4,
    invoice,
    companyConfig: company,
    userDisplayName: 'Vendedor Demo',
  );

  await Printing.layoutPdf(onLayout: (_) async => bytes);
}