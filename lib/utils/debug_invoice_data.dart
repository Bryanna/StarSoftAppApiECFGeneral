import 'package:flutter/foundation.dart';
import '../models/erp_invoice.dart';
import '../models/erp_invoice_extensions.dart';

class DebugInvoiceData {
  static void debugInvoice(ERPInvoice invoice, String context) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('=== DEBUG INVOICE DATA ($context) ===');
    debugPrint('eCF: ${invoice.encf}');
    debugPrint('Número Interno: ${invoice.numerofacturainterna}');
    debugPrint('Cliente: ${invoice.clienteNombre}');
    debugPrint('Total: ${invoice.montototal}');
    debugPrint('');

    debugPrint('=== DETALLE FACTURA FIELD ===');
    final detalleField = invoice.detalleFactura;
    if (detalleField == null || detalleField.isEmpty) {
      debugPrint('❌ detalleFactura is NULL or EMPTY');
      debugPrint('This means the ERP is not sending invoice details');
    } else {
      debugPrint('✅ detalleFactura found');
      debugPrint('Length: ${detalleField.length} characters');
      debugPrint(
        'First 200 chars: ${detalleField.substring(0, detalleField.length > 200 ? 200 : detalleField.length)}...',
      );

      // Try to parse
      try {
        final detalles = invoice.detalles;
        debugPrint('✅ Successfully parsed ${detalles.length} details');
        for (int i = 0; i < detalles.length; i++) {
          final detail = detalles[i];
          debugPrint(
            '  ${i + 1}. [${detail.referencia}] ${detail.descripcion} - RD\$ ${detail.total}',
          );
        }
      } catch (e) {
        debugPrint('❌ Error parsing details: $e');
      }
    }

    debugPrint('');
    debugPrint('=== ALL ERP INVOICE FIELDS ===');
    debugPrint('fFacturaSecuencia: ${invoice.fFacturaSecuencia}');
    debugPrint('version: ${invoice.version}');
    debugPrint('tipoecf: ${invoice.tipoecf}');
    debugPrint('encf: ${invoice.encf}');
    debugPrint('numerofacturainterna: ${invoice.numerofacturainterna}');
    debugPrint('fechaemision: ${invoice.fechaemision}');
    debugPrint('razonsocialcomprador: ${invoice.razonsocialcomprador}');
    debugPrint('montototal: ${invoice.montototal}');
    debugPrint(
      'detalleFactura: ${invoice.detalleFactura?.substring(0, invoice.detalleFactura!.length > 100 ? 100 : invoice.detalleFactura!.length) ?? 'NULL'}...',
    );
    debugPrint('linkOriginal: ${invoice.linkOriginal}');
    debugPrint('=== END DEBUG ===');
    debugPrint('');
  }

  static void debugInvoiceMap(Map<String, dynamic> invoiceMap, String context) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('=== DEBUG INVOICE MAP FOR PDF ($context) ===');
    debugPrint('Map type: ${invoiceMap.runtimeType}');
    debugPrint('Keys: ${invoiceMap.keys.toList()}');
    debugPrint('');

    // Check for mock items
    final mockItems = <String>[];
    for (int i = 1; i <= 10; i++) {
      final nombreKey = 'NombreItem[$i]';
      if (invoiceMap.containsKey(nombreKey)) {
        mockItems.add('$nombreKey: ${invoiceMap[nombreKey]}');
      }
    }

    if (mockItems.isEmpty) {
      debugPrint('✅ No mock items found - good!');
    } else {
      debugPrint('❌ PROBLEM: Mock items found:');
      for (final item in mockItems) {
        debugPrint('  $item');
      }
    }

    // Check for detalle_factura
    final detalleFactura =
        invoiceMap['DetalleFactura'] as String? ??
        invoiceMap['detalleFactura'] as String? ??
        invoiceMap['detalle_factura'] as String?;

    if (detalleFactura == null || detalleFactura.isEmpty) {
      debugPrint('❌ No DetalleFactura found in map');
    } else {
      debugPrint('✅ DetalleFactura found in map');
      debugPrint('Length: ${detalleFactura.length} characters');
      debugPrint(
        'Content: ${detalleFactura.substring(0, detalleFactura.length > 150 ? 150 : detalleFactura.length)}...',
      );
    }

    debugPrint('=== END DEBUG MAP ===');
    debugPrint('');
  }
}
