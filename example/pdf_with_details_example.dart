import 'package:facturacion/models/erp_invoice.dart';
import 'package:facturacion/models/erp_invoice_extensions.dart';

void main() {
  // Ejemplo con el JSON exacto que viene del ERP
  const detalleFacturaFromERP =
      '''[{"ars": 14, "costo": 0.00, "itbis": 0.00, "total": 556.40, "precio": 556.40, "cantidad": 1.00, "id_medico": 125, "referencia": "1223", "descripcion": "SONOGRAFIA DE ABDOMEN SUPERIOR: HIGADO, PANCREAS, VIAS BILIARES, RINONES, BAZO Y GRANDES VASOS", "clasificacion": 3}]''';

  // Crear factura como viene del ERP
  final invoice = ERPInvoice(
    encf: 'E310000000001',
    numerofacturainterna: 'FAC-2024-001',
    razonsocialcomprador: 'JUAN PEREZ',
    fechaemision: '15/01/2024',
    montototal: '556.40',
    rncemisor: '131243932',
    razonsocialemisor: 'CENTRO MEDICO PREVENTIVO SALUD Y VIDA',
    detalleFactura: detalleFacturaFromERP,
  );

  print('=== FACTURA GENERADA ===');
  print('eCF: ${invoice.encf}');
  print('Número Interno: ${invoice.numerofacturainterna}');
  print('Cliente: ${invoice.clienteNombre}');
  print('Fecha: ${invoice.fechaemision}');
  print('Total: ${invoice.formattedTotal}');
  print('');

  print('=== DETALLES DE LA FACTURA ===');
  print('Cantidad de items: ${invoice.cantidadItems}');
  print('Resumen: ${invoice.resumenDetalles}');
  print('');

  print('=== ITEMS DETALLADOS ===');
  for (int i = 0; i < invoice.detalles.length; i++) {
    final detail = invoice.detalles[i];
    print('${i + 1}. ID: ${detail.referencia}');
    print('   Descripción: ${detail.descripcion}');
    print('   Cantidad: ${detail.cantidad}');
    print('   Precio: RD\$ ${detail.precio?.toStringAsFixed(2)}');
    print('   Total: RD\$ ${detail.total?.toStringAsFixed(2)}');
    print('   ARS: ${detail.ars}');
    print('   Médico ID: ${detail.idMedico}');
    print('   Clasificación: ${detail.clasificacion}');
    print('');
  }

  print('=== VERIFICACIÓN DE TOTALES ===');
  print(
    'Total desde detalles: RD\$ ${invoice.totalFromDetails.toStringAsFixed(2)}',
  );
  print('Total de la factura: ${invoice.formattedTotal}');
  print(
    '¿Coinciden?: ${invoice.totalFromDetails == double.parse(invoice.montototal ?? '0')}',
  );
  print('');

  print('=== SIMULACIÓN DEL MAP PARA PDF ===');
  // Simular cómo se convierte para el PDF service
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

  print('Map para PDF service:');
  invoiceMap.forEach((key, value) {
    if (key.contains('Detalle') || key.contains('detalle')) {
      print(
        '  $key: ${value.toString().substring(0, value.toString().length > 100 ? 100 : value.toString().length)}...',
      );
    } else {
      print('  $key: $value');
    }
  });
  print('');

  print('=== BÚSQUEDAS EN DETALLES ===');
  final searchTerms = [
    'SONOGRAFIA',
    'ABDOMEN',
    'HIGADO',
    '1223',
    'INEXISTENTE',
  ];
  for (final term in searchTerms) {
    final found = invoice.matchesSearch(term);
    print('Búsqueda "$term": ${found ? "✓ Encontrado" : "✗ No encontrado"}');
  }
  print('');

  print('=== EJEMPLO CON MÚLTIPLES ITEMS ===');
  const multipleItemsJson = '''[
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

  final multipleItemsInvoice = ERPInvoice(
    encf: 'E310000000002',
    numerofacturainterna: 'FAC-2024-002',
    razonsocialcomprador: 'MARIA GARCIA',
    fechaemision: '16/01/2024',
    montototal: '1421.24',
    detalleFactura: multipleItemsJson,
  );

  print('Factura con múltiples items:');
  print('Total de items: ${multipleItemsInvoice.cantidadItems}');
  print('Resumen: ${multipleItemsInvoice.resumenDetalles}');
  print('Items:');
  for (int i = 0; i < multipleItemsInvoice.detalles.length; i++) {
    final detail = multipleItemsInvoice.detalles[i];
    print(
      '  ${i + 1}. [${detail.referencia}] ${detail.descripcion} - RD\$ ${detail.total?.toStringAsFixed(2)}',
    );
  }
  print(
    'Total calculado: RD\$ ${multipleItemsInvoice.totalFromDetails.toStringAsFixed(2)}',
  );
}
