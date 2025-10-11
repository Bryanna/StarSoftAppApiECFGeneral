import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/invoice_detail.dart';
import '../../lib/models/erp_invoice.dart';
import '../../lib/models/erp_invoice_extensions.dart';

void main() {
  group('InvoiceDetail', () {
    test('should parse JSON correctly', () {
      final json = {
        'ars': 6,
        'costo': 0.00,
        'itbis': 0.00,
        'total': 710.62,
        'precio': 710.62,
        'cantidad': 1.00,
        'id_medico': 125,
        'referencia': '1441',
        'descripcion': 'SONOGRAFIA ABDOMINAL',
        'clasificacion': 3,
      };

      final detail = InvoiceDetail.fromJson(json);

      expect(detail.ars, equals(6));
      expect(detail.costo, equals(0.00));
      expect(detail.itbis, equals(0.00));
      expect(detail.total, equals(710.62));
      expect(detail.precio, equals(710.62));
      expect(detail.cantidad, equals(1.00));
      expect(detail.idMedico, equals(125));
      expect(detail.referencia, equals('1441'));
      expect(detail.descripcion, equals('SONOGRAFIA ABDOMINAL'));
      expect(detail.clasificacion, equals(3));
    });

    test('should handle null values gracefully', () {
      final json = <String, dynamic>{'descripcion': 'Test Item'};

      final detail = InvoiceDetail.fromJson(json);

      expect(detail.descripcion, equals('Test Item'));
      expect(detail.ars, isNull);
      expect(detail.costo, isNull);
      expect(detail.total, isNull);
    });
  });

  group('InvoiceDetailParser', () {
    test('should parse detalle_factura JSON string', () {
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

      final details = InvoiceDetailParser.parseDetalleFactura(
        detalleFacturaJson,
      );

      expect(details.length, equals(2));
      expect(details[0].referencia, equals('1441'));
      expect(details[0].descripcion, equals('SONOGRAFIA ABDOMINAL'));
      expect(details[1].referencia, equals('991'));
      expect(
        details[1].descripcion,
        equals('ULTRASONOGRAFIA PELVICA TRANSVAGINAL'),
      );
    });

    test('should return empty list for invalid JSON', () {
      const invalidJson = 'invalid json string';
      final details = InvoiceDetailParser.parseDetalleFactura(invalidJson);
      expect(details, isEmpty);
    });

    test('should return empty list for null input', () {
      final details = InvoiceDetailParser.parseDetalleFactura(null);
      expect(details, isEmpty);
    });
  });

  group('ERPInvoice with details', () {
    test('should parse detalles from detalleFactura field', () {
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
        }
      ]''';

      final invoice = ERPInvoice(
        encf: 'E310000000001',
        detalleFactura: detalleFacturaJson,
      );

      expect(invoice.detalles.length, equals(1));
      expect(invoice.cantidadItems, equals(1));
      expect(invoice.resumenDetalles, contains('SONOGRAFIA ABDOMINAL'));
      expect(invoice.descripcionesItems, contains('SONOGRAFIA ABDOMINAL'));
    });

    test('should search within invoice details', () {
      const detalleFacturaJson = '''[
        {
          "referencia": "1441",
          "descripcion": "SONOGRAFIA ABDOMINAL"
        }
      ]''';

      final invoice = ERPInvoice(
        encf: 'E310000000001',
        detalleFactura: detalleFacturaJson,
      );

      expect(invoice.matchesSearch('SONOGRAFIA'), isTrue);
      expect(invoice.matchesSearch('ABDOMINAL'), isTrue);
      expect(invoice.matchesSearch('1441'), isTrue);
      expect(invoice.matchesSearch('INEXISTENTE'), isFalse);
    });
  });
}
