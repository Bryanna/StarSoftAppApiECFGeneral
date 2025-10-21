import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:facturacion/models/erp_invoice.dart';
import 'package:facturacion/models/erp_invoice_extensions.dart';

void main() {
  group('Invoice Detail Parsing from ERP', () {
    test('should parse detalle_factura JSON string from ERP format', () {
      // JSON exactamente como viene del ERP
      const detalleFacturaJson =
          '''[{"ars": 14, "costo": 0.00, "itbis": 0.00, "total": 556.40, "precio": 556.40, "cantidad": 1.00, "id_medico": 125, "referencia": "1223", "descripcion": "SONOGRAFIA DE ABDOMEN SUPERIOR: HIGADO, PANCREAS, VIAS BILIARES, RINONES, BAZO Y GRANDES VASOS", "clasificacion": 3}]''';

      // Crear factura con el JSON del ERP
      final invoice = ERPInvoice(
        encf: 'E310000000001',
        numerofacturainterna: 'FAC-2024-001',
        razonsocialcomprador: 'JUAN PEREZ',
        fechaemision: '15/01/2024',
        montototal: '556.40',
        detalleFactura: detalleFacturaJson,
      );

      // Verificar que se parsea correctamente usando las extensiones
      final detalles = invoice.detalles;

      expect(detalles.length, equals(1));
      expect(detalles[0].referencia, equals('1223'));
      expect(
        detalles[0].descripcion,
        equals(
          'SONOGRAFIA DE ABDOMEN SUPERIOR: HIGADO, PANCREAS, VIAS BILIARES, RINONES, BAZO Y GRANDES VASOS',
        ),
      );
      expect(detalles[0].precio, equals(556.40));
      expect(detalles[0].total, equals(556.40));
      expect(detalles[0].cantidad, equals(1.00));
      expect(detalles[0].ars, equals(14));
      expect(detalles[0].idMedico, equals(125));
      expect(detalles[0].clasificacion, equals(3));

      // Verificar métodos de conveniencia
      expect(invoice.cantidadItems, equals(1));
      expect(
        invoice.resumenDetalles,
        contains('SONOGRAFIA DE ABDOMEN SUPERIOR'),
      );
      expect(invoice.totalFromDetails, equals(556.40));
    });

    test('should parse multiple items from detalle_factura', () {
      // JSON con múltiples items
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

      final invoice = ERPInvoice(
        encf: 'E310000000002',
        detalleFactura: detalleFacturaJson,
      );

      final detalles = invoice.detalles;

      expect(detalles.length, equals(2));
      expect(detalles[0].referencia, equals('1441'));
      expect(detalles[0].descripcion, equals('SONOGRAFIA ABDOMINAL'));
      expect(detalles[1].referencia, equals('991'));
      expect(
        detalles[1].descripcion,
        equals('ULTRASONOGRAFIA PELVICA TRANSVAGINAL'),
      );

      expect(invoice.cantidadItems, equals(2));
      expect(invoice.totalFromDetails, equals(1421.24));
    });

    test('should handle search within invoice details', () {
      const detalleFacturaJson =
          '''[{"ars": 14, "costo": 0.00, "itbis": 0.00, "total": 556.40, "precio": 556.40, "cantidad": 1.00, "id_medico": 125, "referencia": "1223", "descripcion": "SONOGRAFIA DE ABDOMEN SUPERIOR: HIGADO, PANCREAS, VIAS BILIARES, RINONES, BAZO Y GRANDES VASOS", "clasificacion": 3}]''';

      final invoice = ERPInvoice(
        encf: 'E310000000003',
        numerofacturainterna: 'FAC-2024-003',
        detalleFactura: detalleFacturaJson,
      );

      // Búsquedas en descripción
      expect(invoice.matchesSearch('SONOGRAFIA'), isTrue);
      expect(invoice.matchesSearch('ABDOMEN'), isTrue);
      expect(invoice.matchesSearch('HIGADO'), isTrue);
      expect(invoice.matchesSearch('PANCREAS'), isTrue);

      // Búsqueda en referencia
      expect(invoice.matchesSearch('1223'), isTrue);

      // Búsqueda que no existe
      expect(invoice.matchesSearch('INEXISTENTE'), isFalse);
    });

    test('should handle empty or null detalle_factura', () {
      final invoiceEmpty = ERPInvoice(
        encf: 'E310000000004',
        detalleFactura: '',
      );

      final invoiceNull = ERPInvoice(
        encf: 'E310000000005',
        detalleFactura: null,
      );

      expect(invoiceEmpty.detalles, isEmpty);
      expect(invoiceEmpty.cantidadItems, equals(0));
      expect(invoiceEmpty.resumenDetalles, equals('Sin detalles'));

      expect(invoiceNull.detalles, isEmpty);
      expect(invoiceNull.cantidadItems, equals(0));
      expect(invoiceNull.resumenDetalles, equals('Sin detalles'));
    });

    test('should handle malformed JSON gracefully', () {
      final invoice = ERPInvoice(
        encf: 'E310000000006',
        detalleFactura: 'invalid json string',
      );

      expect(invoice.detalles, isEmpty);
      expect(invoice.cantidadItems, equals(0));
      expect(invoice.resumenDetalles, equals('Sin detalles'));
    });

    test('should simulate PDF service parsing detalle_factura', () {
      // Simular cómo el PDF service parseará el JSON
      const detalleFacturaJson =
          '''[{"ars": 14, "costo": 0.00, "itbis": 0.00, "total": 556.40, "precio": 556.40, "cantidad": 1.00, "id_medico": 125, "referencia": "1223", "descripcion": "SONOGRAFIA DE ABDOMEN SUPERIOR", "clasificacion": 3}]''';

      // Map como lo crea el controller
      final invoiceMap = {
        'ENCF': 'E310000000007',
        'NumeroFacturaInterna': 'FAC-2024-007',
        'DetalleFactura': detalleFacturaJson,
        'detalleFactura': detalleFacturaJson,
        'detalle_factura': detalleFacturaJson,
      };

      // Simular el parsing que hace el PDF service
      final detalleJson =
          invoiceMap['DetalleFactura'] ??
          invoiceMap['detalleFactura'] ??
          invoiceMap['detalle_factura'];

      expect(detalleJson, isNotNull);
      expect(detalleJson, isNotEmpty);

      // Parsear el JSON
      final List<dynamic> detalles = json.decode(detalleJson!);
      expect(detalles.length, equals(1));

      final detalle = detalles[0] as Map<String, dynamic>;
      expect(detalle['referencia'], equals('1223'));
      expect(detalle['descripcion'], equals('SONOGRAFIA DE ABDOMEN SUPERIOR'));
      expect(detalle['precio'], equals(556.40));
      expect(detalle['total'], equals(556.40));
    });
  });
}
