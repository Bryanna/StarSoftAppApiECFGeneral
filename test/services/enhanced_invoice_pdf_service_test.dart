import 'package:flutter_test/flutter_test.dart';
import 'package:facturacion/models/erp_invoice.dart';
import 'package:facturacion/services/enhanced_invoice_pdf_service.dart';
import 'package:pdf/pdf.dart';

void main() {
  group('EnhancedInvoicePdfService with Invoice Details', () {
    test('should parse detalle_factura and generate PDF', () async {
      // JSON de ejemplo como viene del ERP
      const detalleFacturaJson = '''[
        {
          "ars": 6,
          "costo": 0.00,
          "itbis": 0.00,
          "total": 710.62,
          "precio": 710.62,
          "cantidad": 1.00,
          "id_medico": 125,
          "referencia": "1441",
          "descripcion": "SONOGRAFIA ABDOMINAL",
          "clasificacion": 3
        },
        {
          "ars": 6,
          "costo": 0.00,
          "itbis": 0.00,
          "total": 710.62,
          "precio": 710.62,
          "cantidad": 1.00,
          "id_medico": 125,
          "referencia": "991",
          "descripcion": "ULTRASONOGRAFIA PELVICA TRANSVAGINAL",
          "clasificacion": 3
        }
      ]''';

      // Crear factura con detalles
      final invoice = ERPInvoice(
        encf: 'E310000000001',
        numerofacturainterna: 'FAC-2024-001',
        razonsocialcomprador: 'JUAN PEREZ',
        fechaemision: '15/01/2024',
        montototal: '1421.24',
        detalleFactura: detalleFacturaJson,
      );

      // Convertir a Map como lo hace el controller
      final invoiceMap = {
        'ENCF': invoice.encf ?? invoice.numeroFactura,
        'NumeroFacturaInterna': invoice.numeroFactura,
        'FechaEmision': invoice.fechaemision ?? '',
        'RazonSocialComprador': invoice.razonsocialcomprador ?? '',
        'MontoTotal': invoice.montototal ?? '0.00',
        'DetalleFactura': invoice.detalleFactura ?? '',
        'detalleFactura': invoice.detalleFactura ?? '',
        'detalle_factura': invoice.detalleFactura ?? '',
      };

      // Generar PDF
      final pdfBytes = await EnhancedInvoicePdfService.buildPdf(
        PdfPageFormat.a4,
        invoiceMap,
      );

      // Verificar que se generó el PDF
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(0));

      // El PDF debe contener datos binarios válidos
      expect(pdfBytes.sublist(0, 4), equals([0x25, 0x50, 0x44, 0x46])); // %PDF
    });

    test('should handle empty detalle_factura gracefully', () async {
      // Factura sin detalles
      final invoice = ERPInvoice(
        encf: 'E310000000002',
        numerofacturainterna: 'FAC-2024-002',
        razonsocialcomprador: 'MARIA GARCIA',
        fechaemision: '16/01/2024',
        montototal: '500.00',
        detalleFactura: '', // Sin detalles
      );

      final invoiceMap = {
        'ENCF': invoice.encf ?? invoice.numeroFactura,
        'NumeroFacturaInterna': invoice.numeroFactura,
        'FechaEmision': invoice.fechaemision ?? '',
        'RazonSocialComprador': invoice.razonsocialcomprador ?? '',
        'MontoTotal': invoice.montototal ?? '0.00',
        'DetalleFactura': invoice.detalleFactura ?? '',
      };

      // Debe generar PDF sin errores
      final pdfBytes = await EnhancedInvoicePdfService.buildPdf(
        PdfPageFormat.a4,
        invoiceMap,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(0));
    });

    test('should handle malformed detalle_factura JSON', () async {
      // Factura con JSON malformado
      final invoice = ERPInvoice(
        encf: 'E310000000003',
        numerofacturainterna: 'FAC-2024-003',
        razonsocialcomprador: 'PEDRO MARTINEZ',
        fechaemision: '17/01/2024',
        montototal: '300.00',
        detalleFactura: 'invalid json string', // JSON inválido
      );

      final invoiceMap = {
        'ENCF': invoice.encf ?? invoice.numeroFactura,
        'NumeroFacturaInterna': invoice.numeroFactura,
        'FechaEmision': invoice.fechaemision ?? '',
        'RazonSocialComprador': invoice.razonsocialcomprador ?? '',
        'MontoTotal': invoice.montototal ?? '0.00',
        'DetalleFactura': invoice.detalleFactura ?? '',
      };

      // Debe generar PDF sin errores (fallback a item genérico)
      final pdfBytes = await EnhancedInvoicePdfService.buildPdf(
        PdfPageFormat.a4,
        invoiceMap,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(0));
    });
  });
}
