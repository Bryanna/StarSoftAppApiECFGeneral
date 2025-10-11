import '../lib/models/erp_invoice.dart';
import '../lib/models/erp_invoice_extensions.dart';
import '../lib/models/invoice_detail.dart';

void main() {
  // Ejemplo de uso del parsing de detalle_factura

  // JSON como viene del ERP
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

  // Usar las extensiones para acceder a los detalles
  print('Factura: ${invoice.numeroFactura}');
  print('Cliente: ${invoice.clienteNombre}');
  print('Total: ${invoice.formattedTotal}');
  print('Cantidad de items: ${invoice.cantidadItems}');
  print('Resumen: ${invoice.resumenDetalles}');
  print('');

  // Mostrar cada detalle
  print('Detalles de la factura:');
  for (int i = 0; i < invoice.detalles.length; i++) {
    final detail = invoice.detalles[i];
    print('${i + 1}. ${detail.descripcion}');
    print('   Referencia: ${detail.referencia}');
    print('   Cantidad: ${detail.cantidad}');
    print('   Precio: RD\$ ${detail.precio?.toStringAsFixed(2)}');
    print('   Total: RD\$ ${detail.total?.toStringAsFixed(2)}');
    print('');
  }

  // Verificar total calculado vs total de la factura
  print(
    'Total desde detalles: RD\$ ${invoice.totalFromDetails.toStringAsFixed(2)}',
  );
  print('Total de la factura: ${invoice.formattedTotal}');

  // Probar búsqueda en detalles
  print('');
  print('Búsquedas:');
  print('Contiene "SONOGRAFIA": ${invoice.matchesSearch("SONOGRAFIA")}');
  print('Contiene "PELVICA": ${invoice.matchesSearch("PELVICA")}');
  print('Contiene "1441": ${invoice.matchesSearch("1441")}');
  print('Contiene "INEXISTENTE": ${invoice.matchesSearch("INEXISTENTE")}');
}
