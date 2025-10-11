import 'dart:convert';
import 'package:facturacion/models/erp_invoice.dart';

void main() {
  // Simular exactamente lo que hace el controller
  const detalleFacturaJson =
      '''[{"ars": 14, "costo": 0.00, "itbis": 0.00, "total": 556.40, "precio": 556.40, "cantidad": 1.00, "id_medico": 125, "referencia": "1223", "descripcion": "SONOGRAFIA DE ABDOMEN SUPERIOR", "clasificacion": 3}]''';

  final invoice = ERPInvoice(
    encf: 'E310000000001',
    numerofacturainterna: 'FAC-2024-001',
    razonsocialcomprador: 'JUAN PEREZ',
    fechaemision: '15/01/2024',
    montototal: '556.40',
    detalleFactura: detalleFacturaJson,
  );

  // Simular la conversión que hace el controller
  final invoiceMap = {
    'ENCF': invoice.encf ?? invoice.numeroFactura,
    'NumeroFacturaInterna': invoice.numeroFactura,
    'FechaEmision': invoice.fechaemision ?? '',
    'RNCEmisor': invoice.rncemisor ?? '',
    'RazonSocialEmisor': invoice.razonsocialemisor ?? invoice.empresaNombre,
    'RNCComprador': invoice.rnccomprador ?? '',
    'RazonSocialComprador':
        invoice.razonsocialcomprador ?? invoice.clienteNombre,
    'DireccionComprador': invoice.direccioncomprador ?? '',
    'MontoTotal': invoice.montototal ?? '0.00',
    'MontoGravadoTotal': invoice.montogravadototal ?? '0.00',
    'TotalITBIS': invoice.totalitbis ?? '0.00',
    'MontoExento': invoice.montoexento ?? '0.00',
    'CodigoSeguridad': '', // Debe ser llenado por el API de DGII
    'TipoeCF': invoice.tipoecf ?? '31',
    'linkOriginal': invoice.linkOriginal ?? '',
    'link_original': invoice.linkOriginal ?? '',
    'TelefonoEmisor[1]': invoice.telefonoemisor1 ?? '',
    'CorreoEmisor': invoice.correoemisor ?? '',
    'Website': invoice.website ?? '',
    'DireccionEmisor': invoice.direccionemisor ?? '',
    'Municipio': invoice.municipio ?? '',
    'Provincia': invoice.provincia ?? '',
    'TipoMoneda': invoice.tipomoneda ?? 'DOP',
    // Detalle de la factura (JSON string del ERP)
    'DetalleFactura': invoice.detalleFactura ?? '',
    'detalleFactura': invoice.detalleFactura ?? '',
    'detalle_factura': invoice.detalleFactura ?? '',
  };

  print('=== DEBUG: MAP QUE SE ENVÍA AL PDF SERVICE ===');
  print('Tipo: ${invoiceMap.runtimeType}');
  print('Keys: ${invoiceMap.keys.toList()}');
  print('');

  print('=== CAMPOS PRINCIPALES ===');
  print('ENCF: ${invoiceMap['ENCF']}');
  print('NumeroFacturaInterna: ${invoiceMap['NumeroFacturaInterna']}');
  print('RazonSocialComprador: ${invoiceMap['RazonSocialComprador']}');
  print('MontoTotal: ${invoiceMap['MontoTotal']}');
  print('');

  print('=== DETALLE FACTURA ===');
  print('DetalleFactura: ${invoiceMap['DetalleFactura']}');
  print('detalleFactura: ${invoiceMap['detalleFactura']}');
  print('detalle_factura: ${invoiceMap['detalle_factura']}');
  print('');

  print('=== VERIFICAR SI HAY ITEMS MOCK ===');
  final mockItems = <String>[];
  for (int i = 1; i <= 10; i++) {
    final nombreKey = 'NombreItem[$i]';
    if (invoiceMap.containsKey(nombreKey)) {
      mockItems.add('$nombreKey: ${invoiceMap[nombreKey]}');
    }
  }

  if (mockItems.isEmpty) {
    print('✓ No hay items mock - perfecto!');
  } else {
    print('✗ PROBLEMA: Se encontraron items mock:');
    for (final item in mockItems) {
      print('  $item');
    }
  }
  print('');

  print('=== SIMULACIÓN DEL PARSING EN PDF SERVICE ===');
  final detalleJson =
      invoiceMap['DetalleFactura'] ??
      invoiceMap['detalleFactura'] ??
      invoiceMap['detalle_factura'];

  if (detalleJson != null && detalleJson.isNotEmpty) {
    print('✓ Se encontró detalle_factura JSON');
    print('Longitud: ${detalleJson.length} caracteres');
    print(
      'Primeros 100 chars: ${detalleJson.substring(0, detalleJson.length > 100 ? 100 : detalleJson.length)}...',
    );

    try {
      final List<dynamic> detalles = json.decode(detalleJson);
      print('✓ JSON parseado exitosamente');
      print('Cantidad de items: ${detalles.length}');

      for (int i = 0; i < detalles.length; i++) {
        final detalle = detalles[i] as Map<String, dynamic>;
        print('Item ${i + 1}:');
        print('  Referencia: ${detalle['referencia']}');
        print('  Descripción: ${detalle['descripcion']}');
        print('  Precio: ${detalle['precio']}');
        print('  Total: ${detalle['total']}');
      }
    } catch (e) {
      print('✗ Error parseando JSON: $e');
    }
  } else {
    print('✗ PROBLEMA: No se encontró detalle_factura JSON');
  }
}
