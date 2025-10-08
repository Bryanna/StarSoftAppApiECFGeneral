// Script de prueba para verificar los datos fake
import 'lib/services/fake_invoices_data.dart';

void main() {
  final invoices = getAllFakeInvoices();

  print('Total de facturas: ${invoices.length}');
  print('\nFacturas por tipo:');

  final byType = <String, int>{};
  for (final inv in invoices) {
    byType[inv.tipoecf ?? 'null'] = (byType[inv.tipoecf ?? 'null'] ?? 0) + 1;
  }

  byType.forEach((type, count) {
    print('  Tipo $type: $count facturas');
  });

  print('\nPrimeras 5 facturas:');
  for (var i = 0; i < 5 && i < invoices.length; i++) {
    final inv = invoices[i];
    print(
      '  ${i + 1}. ${inv.encf} - Tipo: ${inv.tipoecf} - Total: ${inv.montototal}',
    );
  }

  print('\nFacturas rechazadas:');
  final rechazadas = invoices.where((inv) => inv.fAnulada == true).toList();
  print('  Total: ${rechazadas.length}');
  for (final inv in rechazadas) {
    print('    - ${inv.encf}');
  }
}
