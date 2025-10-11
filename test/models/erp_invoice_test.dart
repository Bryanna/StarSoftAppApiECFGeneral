import 'package:flutter_test/flutter_test.dart';
import 'package:facturacion/models/erp_invoice.dart';
import 'package:facturacion/models/erp_invoice_extensions.dart';

void main() {
  group('ERPInvoice', () {
    test('should create from JSON with API format', () {
      final json = {
        'ENCF': 'E310000000002',
        'FechaEmision': '01-04-2020',
        'RNCEmisor': '132177975',
        'RazonSocialEmisor': 'DOCUMENTOS ELECTRONICOS DE 02',
        'RNCComprador': '131880681',
        'RazonSocialComprador': 'DOCUMENTOS ELECTRONICOS DE 03',
        'MontoTotal': '4674.35',
        'MontoGravadoTotal': '3230.00',
        'TotalITBIS': '713.04',
        'MontoExento': '0.00',
        'TipoeCF': '31',
        'Version': '1.0',
      };

      final invoice = ERPInvoice.fromJson(json);

      expect(invoice.encf, equals('E310000000002'));
      expect(invoice.fechaemision, equals('01-04-2020'));
      expect(invoice.rncemisor, equals('132177975'));
      expect(
        invoice.razonsocialemisor,
        equals('DOCUMENTOS ELECTRONICOS DE 02'),
      );
      expect(invoice.rnccomprador, equals('131880681'));
      expect(
        invoice.razonsocialcomprador,
        equals('DOCUMENTOS ELECTRONICOS DE 03'),
      );
      expect(invoice.montototal, equals('4674.35'));
      expect(invoice.montogravadototal, equals('3230.00'));
      expect(invoice.totalitbis, equals('713.04'));
      expect(invoice.tipoecf, equals('31'));
      expect(invoice.version, equals('1.0'));
    });

    test('should handle legacy field names', () {
      final json = {
        'encf': 'E310000000002',
        'fechaemision': '01-04-2020',
        'rncemisor': '132177975',
        'montototal': '4674.35',
      };

      final invoice = ERPInvoice.fromJson(json);

      expect(invoice.encf, equals('E310000000002'));
      expect(invoice.fechaemision, equals('01-04-2020'));
      expect(invoice.rncemisor, equals('132177975'));
      expect(invoice.montototal, equals('4674.35'));
    });

    test('should provide compatibility getters', () {
      final invoice = ERPInvoice(
        encf: 'E310000000002',
        fechaemision: '01-04-2020',
        razonsocialemisor: 'Test Company',
        rncemisor: '132177975',
        razonsocialcomprador: 'Test Client',
        rnccomprador: '131880681',
        montototal: '4674.35',
        montogravadototal: '3230.00',
        totalitbis: '713.04',
        montoexento: '0.00',
      );

      expect(invoice.fDocumento, equals('E310000000002'));
      expect(invoice.fTotal, equals('4674.35'));
      expect(invoice.fSubtotal, equals('3230.00'));
      expect(invoice.fItbis, equals('713.04'));
      expect(invoice.numeroFactura, equals('E310000000002'));
      expect(invoice.clienteNombre, equals('Test Client'));
      expect(invoice.clienteRnc, equals('131880681'));
      expect(invoice.empresaNombre, equals('Test Company'));
      expect(invoice.empresaRnc, equals('132177975'));
    });

    test('should parse amounts correctly', () {
      final invoice = ERPInvoice(
        montototal: '4,674.35',
        montogravadototal: '3,230.00',
        totalitbis: '713.04',
        montoexento: '0.00',
      );

      expect(invoice.totalAmount, equals(4674.35));
      expect(invoice.subtotalAmount, equals(3230.00));
      expect(invoice.itbisAmount, equals(713.04));
      expect(invoice.exentoAmount, equals(0.00));
    });

    test('should parse dates correctly', () {
      final invoice = ERPInvoice(
        fechaemision: '01-04-2020',
        fechavencimientosecuencia: '31-12-2025',
      );

      final fechaEmision = invoice.fechaemisionDateTime;
      final fechaVencimiento = invoice.fechaVencimientoDateTime;

      expect(fechaEmision, isNotNull);
      expect(fechaEmision!.day, equals(1));
      expect(fechaEmision.month, equals(4));
      expect(fechaEmision.year, equals(2020));

      expect(fechaVencimiento, isNotNull);
      expect(fechaVencimiento!.day, equals(31));
      expect(fechaVencimiento.month, equals(12));
      expect(fechaVencimiento.year, equals(2025));
    });

    test('should handle null and empty values gracefully', () {
      final invoice = ERPInvoice();

      expect(invoice.numeroFactura, equals(''));
      expect(invoice.clienteNombre, equals(''));
      expect(invoice.totalAmount, equals(0.0));
      expect(invoice.fechaemisionDateTime, isNull);
      expect(invoice.isValid, isFalse);
    });

    test('should format currency correctly', () {
      final invoice = ERPInvoice(
        montototal: '1234567.89',
        montogravadototal: '1000000.00',
        totalitbis: '180000.00',
      );

      expect(invoice.formattedTotal, equals('RD\$ 1,234,567.89'));
      expect(invoice.formattedSubtotal, equals('RD\$ 1,000,000.00'));
      expect(invoice.formattedItbis, equals('RD\$ 180,000.00'));
    });

    test('should provide correct tipo comprobante display', () {
      final facturaCreditoFiscal = ERPInvoice(tipoecf: '31');
      final facturaConsumo = ERPInvoice(tipoecf: '32');
      final notaDebito = ERPInvoice(tipoecf: '33');
      final notaCredito = ERPInvoice(tipoecf: '34');

      expect(
        facturaCreditoFiscal.tipoComprobanteDisplay,
        equals('Factura de Crédito Fiscal'),
      );
      expect(
        facturaConsumo.tipoComprobanteDisplay,
        equals('Factura de Consumo'),
      );
      expect(notaDebito.tipoComprobanteDisplay, equals('Nota de Débito'));
      expect(notaCredito.tipoComprobanteDisplay, equals('Nota de Crédito'));
    });

    test('should match search queries correctly', () {
      final invoice = ERPInvoice(
        encf: 'E310000000002',
        razonsocialcomprador: 'DOCUMENTOS ELECTRONICOS DE 03',
        rnccomprador: '131880681',
        fechaemision: '01-04-2020',
      );

      expect(invoice.matchesSearch('E31'), isTrue);
      expect(invoice.matchesSearch('DOCUMENTOS'), isTrue);
      expect(invoice.matchesSearch('131880681'), isTrue);
      expect(invoice.matchesSearch('01-04'), isTrue);
      expect(invoice.matchesSearch('xyz'), isFalse);
      expect(invoice.matchesSearch(''), isTrue);
    });

    test('should filter by date range correctly', () {
      final invoice = ERPInvoice(fechaemision: '15-06-2020');

      final startDate = DateTime(2020, 6, 1);
      final endDate = DateTime(2020, 6, 30);
      final beforeRange = DateTime(2020, 5, 1);
      final afterRange = DateTime(2020, 7, 1);

      expect(invoice.isInDateRange(startDate, endDate), isTrue);
      expect(invoice.isInDateRange(afterRange, null), isFalse);
      expect(invoice.isInDateRange(null, beforeRange), isFalse);
      expect(invoice.isInDateRange(null, null), isTrue);
    });
  });
}
