import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/invoice_detail.dart';

/// Servicio para generar PDFs de recibos de 80mm (impresoras térmicas)
class Receipt80mmPdfService {
  /// Construye un PDF de recibo de 80mm para impresoras térmicas
  static Future<Uint8List> buildReceipt80(
    Map<String, dynamic> invoice, {
    Map<String, dynamic>? companyConfig,
    String? logoUrl,
    Uint8List? logoBytes,
  }) async {
    final doc = pw.Document();

    final companyData = _getCompanyData(companyConfig, invoice);

    pw.ImageProvider? logo;
    try {
      if (logoBytes != null) {
        logo = pw.MemoryImage(logoBytes);
      } else if ((logoUrl ?? companyData['logoUrl']) is String &&
          ((logoUrl ?? companyData['logoUrl']) as String).isNotEmpty) {
        logo = await networkImage(
          (logoUrl ?? companyData['logoUrl']) as String,
        );
      }
    } catch (_) {
      logo = null;
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 48),
        build: (context) {
          final items = _extractItems(invoice);
          final itbis = _getITBIS(invoice);
          final total = _getNetAmount(invoice);

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Espaciado superior
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.SizedBox(height: 20),
                    pw.Text('. '),
                    pw.Text('  '),
                    pw.Text('  '),
                    pw.Text('.  '),
                    pw.SizedBox(height: 20),

                    // Logo
                    if (logo != null)
                      pw.Container(
                        width: 120,
                        height: 50,
                        margin: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Image(logo, fit: pw.BoxFit.contain),
                      ),

                    // Información de la empresa
                    pw.Text(
                      (companyData['razonSocial'] ?? 'EMPRESA')
                          .toString()
                          .toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    if ((companyData['direccion']?.toString() ?? '').isNotEmpty)
                      pw.Text(
                        companyData['direccion'].toString(),
                        style: const pw.TextStyle(fontSize: 9),
                        textAlign: pw.TextAlign.center,
                      ),
                    if ((companyData['direccion']?.toString() ?? '').isNotEmpty)
                      pw.SizedBox(height: 2),
                    pw.Text(
                      'RNC: ${companyData['rnc'] ?? ''}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // Información de la factura
              pw.Text(
                'No. Factura: ${_getInvoiceNumber(invoice)}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Fecha: ${_getInvoiceDate(invoice)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'eNCF: ${_getECF(invoice)}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              if ((invoice['fechavencimientosecuencia']?.toString() ?? '')
                  .isNotEmpty)
                pw.Text(
                  'Vencimiento: ${_formatDateString(invoice['fechavencimientosecuencia'])}',
                  style: const pw.TextStyle(fontSize: 9),
                ),

              // Información del cliente
              if ((_getPatientName(invoice)).isNotEmpty)
                pw.Text(
                  'Cliente: ${_getPatientName(invoice)}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              if ((_getRecord(invoice)).isNotEmpty)
                pw.Text(
                  'RNC/Cédula: ${_getRecord(invoice)}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              if ((_getAseguradora(invoice)).isNotEmpty)
                pw.Text(
                  'Aseguradora: ${_getAseguradora(invoice)}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              if ((_getNSS(invoice)).isNotEmpty)
                pw.Text(
                  'NSS: ${_getNSS(invoice)}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              if ((_getNoAutorizacion(invoice)).isNotEmpty)
                pw.Text(
                  'No. Autorización: ${_getNoAutorizacion(invoice)}',
                  style: const pw.TextStyle(fontSize: 9),
                ),

              pw.SizedBox(height: 10),

              // Título del recibo
              pw.Center(
                child: pw.Text(
                  _receiptTitle(invoice),
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 8),

              // Encabezado de items
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Descripción',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.SizedBox(width: 2),
                  pw.SizedBox(
                    width: 35,
                    child: pw.Text(
                      'Cober.',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                  pw.SizedBox(width: 2),
                  pw.SizedBox(
                    width: 35,
                    child: pw.Text(
                      'Valor',
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
                ],
              ),
              pw.Divider(height: 8),

              // Items
              ...items.map((e) {
                final qtyStr = e['qty'] ?? '1.00';
                final priceStr = e['price'] ?? '0.00';
                final coberturaStr = e['cobertura'] ?? '';
                final hasCoberturaValue =
                    coberturaStr.isNotEmpty &&
                    coberturaStr != 'RD\$ 0.00' &&
                    coberturaStr != '0.00';

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '$qtyStr x $priceStr',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            e['desc'] ?? '',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.SizedBox(width: 2),
                        pw.SizedBox(
                          width: 35,
                          child: pw.Text(
                            hasCoberturaValue ? coberturaStr : '-',
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.SizedBox(width: 2),
                        pw.SizedBox(
                          width: 35,
                          child: pw.Text(
                            e['amount'] ?? '',
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                  ],
                );
              }),

              pw.Divider(height: 10),

              // Totales
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Subtotal',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.SizedBox(
                    width: 50,
                    child: pw.Text(
                      _formatMoney(
                        invoice['MontoGravadoTotal'] ??
                            invoice['montogravadototal'] ??
                            0,
                      ),
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'ITBIS',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.SizedBox(
                    width: 50,
                    child: pw.Text(
                      itbis,
                      textAlign: pw.TextAlign.right,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(
                    width: 50,
                    child: pw.Text(
                      total,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 8),
              pw.Divider(height: 8),

              // QR Code
              if ((invoice['link_original'] ?? invoice['linkOriginal'] ?? '')
                  .toString()
                  .isNotEmpty)
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: (invoice['link_original'] ?? invoice['linkOriginal'])
                        .toString(),
                    width: 100,
                    height: 100,
                  ),
                ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Escanea para verificar',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),

              pw.SizedBox(height: 10),

              // Código de seguridad y fecha de firma
              pw.Row(
                children: [
                  pw.Text(
                    'Código de Seguridad: ',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    (invoice['codigoseguridad'] ??
                            invoice['CodigoSeguridad'] ??
                            '-')
                        .toString(),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),

              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Text(
                    'Fecha Firma: ',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    (invoice['fechahorafirma'] ??
                            invoice['f_fecha_firma'] ??
                            invoice['FechaHoraFirma'] ??
                            '-')
                        .toString(),
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),

              pw.SizedBox(height: 6),

              // Mensaje final
              pw.Center(
                child: pw.Column(
                  children: [
                    // pw.Text(
                    //   'Por políticas internas, no hacemos reembolsos de dinero. Estamos siempre disponibles para ayudarle con cualquier inconveniente.',
                    //   style: pw.TextStyle(
                    //     fontSize: 8,
                    //     fontWeight: pw.FontWeight.bold,
                    //   ),
                    //   textAlign: pw.TextAlign.center,
                    // ),
                    pw.SizedBox(height: 8),
                    // pw.Text(
                    //   'Gracias por su compra',
                    //   style: const pw.TextStyle(fontSize: 9),
                    // ),
                  ],
                ),
              ),

              // Espaciado inferior
              pw.SizedBox(height: 20),
              pw.Text('. '),
              pw.Text('  '),
              pw.Text('  '),
              pw.Text('.  '),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  // Métodos auxiliares
  static Map<String, dynamic> _getCompanyData(
    Map<String, dynamic>? companyConfig,
    Map<String, dynamic> invoice,
  ) {
    return {
      'razonSocial':
          companyConfig?['razonSocial'] ??
          invoice['RazonSocialEmisor'] ??
          invoice['razonsocialemisor'] ??
          'EMPRESA',
      'rnc':
          companyConfig?['rnc'] ??
          invoice['RNCEmisor'] ??
          invoice['rncemisor'] ??
          '',
      'direccion':
          companyConfig?['direccion'] ??
          invoice['DireccionEmisor'] ??
          invoice['direccionemisor'] ??
          '',
      'logoUrl': companyConfig?['logoUrl'] ?? '',
    };
  }

  static List<Map<String, String>> _extractItems(Map<String, dynamic> invoice) {
    final items = <Map<String, String>>[];

    // Intentar parsear DetalleFactura usando el parser existente
    final detalleStr = invoice['DetalleFactura'] ?? invoice['detalleFactura'];
    if (detalleStr != null && detalleStr.toString().isNotEmpty) {
      try {
        final List<InvoiceDetail> detalleList =
            InvoiceDetailParser.parseDetalleFactura(detalleStr.toString());

        if (detalleList.isNotEmpty) {
          for (final item in detalleList) {
            items.add({
              'desc': item.descripcion ?? 'Servicio',
              'qty': (item.cantidad ?? 1.0).toStringAsFixed(2),
              'price': _formatMoney(item.precio ?? 0),
              'amount': _formatMoney(item.total ?? 0),
              'cobertura': _formatMoney(item.cobertura ?? 0),
            });
          }
        }
      } catch (e) {
        // Si falla el parsing, usar datos básicos
        print('Error parsing invoice details: $e');
      }
    }

    // Si no hay items, crear uno genérico
    if (items.isEmpty) {
      items.add({
        'desc': 'Servicios médicos',
        'qty': '1.00',
        'price': _formatMoney(
          invoice['MontoTotal'] ?? invoice['montototal'] ?? 0,
        ),
        'amount': _formatMoney(
          invoice['MontoTotal'] ?? invoice['montototal'] ?? 0,
        ),
      });
    }

    return items;
  }

  static String _getITBIS(Map<String, dynamic> invoice) {
    final itbis = invoice['TotalITBIS'] ?? invoice['totalitbis'] ?? 0;
    return _formatMoney(itbis);
  }

  static String _getNetAmount(Map<String, dynamic> invoice) {
    final total = invoice['MontoTotal'] ?? invoice['montototal'] ?? 0;
    return _formatMoney(total);
  }

  static String _formatMoney(dynamic value) {
    if (value == null) return 'RD\$ 0.00';
    final double amount = double.tryParse(value.toString()) ?? 0.0;

    // Formatear con separador de miles
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    // Agregar comas cada 3 dígitos
    final buffer = StringBuffer();
    var count = 0;
    for (var i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integerPart[i]);
      count++;
    }

    // Invertir el string
    final formattedInteger = buffer.toString().split('').reversed.join('');

    return 'RD\$ $formattedInteger.$decimalPart';
  }

  static String _getInvoiceNumber(Map<String, dynamic> invoice) {
    return (invoice['NumeroFacturaInterna'] ??
            invoice['numerofacturainterna'] ??
            invoice['numeroFactura'] ??
            '')
        .toString();
  }

  static String _getInvoiceDate(Map<String, dynamic> invoice) {
    final fecha = invoice['FechaEmision'] ?? invoice['fechaemision'] ?? '';
    return _formatDateString(fecha);
  }

  static String _getECF(Map<String, dynamic> invoice) {
    return (invoice['ENCF'] ?? invoice['encf'] ?? '').toString();
  }

  static String _getPatientName(Map<String, dynamic> invoice) {
    return (invoice['RazonSocialComprador'] ??
            invoice['razonsocialcomprador'] ??
            '')
        .toString();
  }

  static String _getRecord(Map<String, dynamic> invoice) {
    return (invoice['RNCComprador'] ?? invoice['rnccomprador'] ?? '')
        .toString();
  }

  static String _getAseguradora(Map<String, dynamic> invoice) {
    return (invoice['aseguradora'] ?? invoice['Aseguradora'] ?? '')
        .toString()
        .trim();
  }

  static String _getNSS(Map<String, dynamic> invoice) {
    return (invoice['nss'] ?? invoice['NSS'] ?? '').toString().trim();
  }

  static String _getNoAutorizacion(Map<String, dynamic> invoice) {
    return (invoice['no_autorizacion'] ??
            invoice['noAutorizacion'] ??
            invoice['NoAutorizacion'] ??
            '')
        .toString()
        .trim();
  }

  static String _formatDateString(dynamic date) {
    if (date == null || date.toString().isEmpty) return '';
    final dateStr = date.toString();
    // Intentar formatear la fecha si es necesario
    return dateStr;
  }

  static String _receiptTitle(Map<String, dynamic> invoice) {
    final encf = _getECF(invoice).toString().toUpperCase();

    // Extraer código del ENCF (primeros 3 caracteres)
    if (encf.length >= 3) {
      final code = encf.substring(0, 3);

      // Mapeo de códigos a descripciones
      final descriptions = {
        'E31': 'FACTURA CRÉDITO FISCAL ELECTRÓNICO',
        'E32': 'FACTURA CONSUMO ELECTRÓNICO',
        'E33': 'NOTA DE DÉBITO ELECTRÓNICA',
        'E34': 'NOTA DE CRÉDITO ELECTRÓNICA',
        'E41': 'COMPRAS ELECTRÓNICO',
        'E43': 'GASTOS MENORES ELECTRÓNICO',
        'B01': 'FACTURA CRÉDITO FISCAL',
        'B02': 'FACTURA CONSUMO',
        'B03': 'NOTA DE DÉBITO',
        'B04': 'NOTA DE CRÉDITO',
        'B11': 'COMPRAS',
        'B13': 'GASTOS MENORES',
        'B15': 'GACTURA GUBERNAMENTAL',
      };

      if (descriptions.containsKey(code)) {
        return descriptions[code]!;
      }
    }

    return 'FACTURA';
  }
}


//
