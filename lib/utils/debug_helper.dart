import 'package:flutter/foundation.dart';
import '../models/erp_invoice.dart';
import '../models/erp_invoice_extensions.dart';

class DebugHelper {
  static void debugInvoiceForPDF(ERPInvoice invoice) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('🔍🔍🔍 DEBUG INVOICE FOR PDF 🔍🔍🔍');
    debugPrint('eCF: ${invoice.encf}');
    debugPrint('Número Interno: ${invoice.numerofacturainterna}');
    debugPrint('Cliente: ${invoice.clienteNombre}');
    debugPrint('');

    debugPrint('🔍 DETALLE FACTURA FIELD:');
    final detalleField = invoice.detalleFactura;
    if (detalleField == null || detalleField.isEmpty) {
      debugPrint('❌ detalleFactura is NULL or EMPTY');
      debugPrint('❌ This means you are using FAKE DATA');
      debugPrint('❌ Go to Settings and DISABLE "Usar datos fake"');
    } else {
      debugPrint('✅ detalleFactura found!');
      debugPrint('Length: ${detalleField.length} characters');
      debugPrint(
        'Content: ${detalleField.substring(0, detalleField.length > 200 ? 200 : detalleField.length)}...',
      );

      try {
        final detalles = invoice.detalles;
        debugPrint('✅ Successfully parsed ${detalles.length} details');
        for (int i = 0; i < detalles.length && i < 3; i++) {
          final detail = detalles[i];
          debugPrint(
            '  ${i + 1}. [${detail.referencia}] ${detail.descripcion}',
          );
        }
      } catch (e) {
        debugPrint('❌ Error parsing details: $e');
      }
    }
    debugPrint('🔍🔍🔍 END DEBUG 🔍🔍🔍');
    debugPrint('');
  }
}
