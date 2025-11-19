import 'package:flutter/material.dart';

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
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.SizedBox(height: 20),
                    pw.Text(". "),
                    pw.Text("  "),
                    pw.Text("  "),
                    pw.Text(".  "),
                    pw.SizedBox(height: 20),

                    if (logo != null)
                      pw.Container(
                        width: 120,
                        height: 50,
                        margin: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Image(logo, fit: pw.BoxFit.contain),
                      ),
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
                        style: pw.TextStyle(fontSize: 9),
                        textAlign: pw.TextAlign.center,
                      ),
                    if ((companyData['direccion']?.toString() ?? '').isNotEmpty)
                      pw.SizedBox(height: 2),
                    pw.Text(
                      'RNC: ${companyData['rnc'] ?? ''}',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'No. Factura: ${_getInvoiceNumber(invoice)}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Fecha: ${_getInvoiceDate(invoice)}',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'eNCF: ${_getECF(invoice)}',
                style: pw.TextStyle(fontSize: 9),
              ),
              if ((invoice['fechavencimientosecuencia']?.toString() ?? '')
                  .isNotEmpty)
                pw.Text(
                  'Vencimiento: ${_formatDateString(invoice['fechavencimientosecuencia'])}',
                  style: pw.TextStyle(fontSize: 9),
                ),
              // pw.SizedBox(height: 4),
              if ((_getPatientName(invoice)).isNotEmpty)
                pw.Text(
                  'Cliente: ${_getPatientName(invoice)}',
                  style: pw.TextStyle(fontSize: 9),
                ),
              if ((_getRecord(invoice)).isNotEmpty)
                pw.Text(
                  'RNC/Cédula: ${_getRecord(invoice)}',
                  style: pw.TextStyle(fontSize: 9),
                ),
              pw.SizedBox(height: 10),
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
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Descripción',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  pw.SizedBox(
                    width: 50,
                    child: pw.Text(
                      'Valor',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
              pw.Divider(height: 8),
              ...items.map((e) {
                final qtyStr = e['qty'] ?? '1.00';
                final priceStr = e['price'] ?? '0.00';
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '$qtyStr x $priceStr',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            e['desc'] ?? '',
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.SizedBox(
                          width: 50,
                          child: pw.Text(
                            e['amount'] ?? '',
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                  ],
                );
              }),
              pw.Divider(height: 10),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Subtotal',
                      style: pw.TextStyle(fontSize: 9),
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
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text('ITBIS', style: pw.TextStyle(fontSize: 9)),
                  ),
                  pw.SizedBox(
                    width: 50,
                    child: pw.Text(
                      itbis,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(fontSize: 9),
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
                  style: pw.TextStyle(fontSize: 8),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  pw.Text(
                    'Código de Seguridad:',
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
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ]
              ),

              pw.SizedBox(height: 4),
              pw.Row(
                children: [
                  pw.Text(
                    'Fecha Firma:',
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
                    style: pw.TextStyle(fontSize: 9),
                  ),
                ]
              ),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Por políticas internas, no hacemos reembolsos de dinero. Estamos siempre disponibles para ayudarle con cualquier inconveniente.',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Gracias por su compra',
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(". "),
              pw.Text("  "),
              pw.Text("  "),
              pw.Text(".  "),
              pw.SizedBox(height: 20),


            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static String _receiptTitle(Map<String, dynamic> invoice) {
    final encf = _getECF(invoice).toString().toUpperCase();
    final code = ecf_utils.codeFromEncf(encf);
    if (code != null && code.isNotEmpty) {
      final d = ecf_utils.shortDescriptionForCode(code);
      if (d != null && d.isNotEmpty) return d.toUpperCase();
    }
    final t = _getInvoiceTitle(invoice);
    final s = t.toString();
    return s.isNotEmpty ? s.toUpperCase() : 'FACTURA';
  }
