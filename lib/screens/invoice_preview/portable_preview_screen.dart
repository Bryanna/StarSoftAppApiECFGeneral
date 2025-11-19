import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:facturacion/example_portable_pdf.dart';

class PortablePreviewScreen extends StatelessWidget {
  const PortablePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final demoInvoice = {
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
    final demoCompany = {
      'name': 'Mi Empresa SRL',
      'address': 'Calle Principal #123',
      'phone': '809-000-0000',
      'logoBytes': null,
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Factura Portable'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              await generateAndPrintExample();
              if (Get.isSnackbarOpen) return;
              Get.snackbar(
                'Impresión',
                'Se envió el PDF al diálogo de impresión',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          )
        ],
      ),
      body: ExamplePortableInvoicePreview(
        invoice: demoInvoice,
        company: demoCompany,
        user: 'Vendedor Demo',
      ),
    );
  }
}