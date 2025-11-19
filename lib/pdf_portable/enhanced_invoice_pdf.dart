import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Portable PDF generator for invoices
/// - No dependency on app services
/// - Accepts plain Map data and optional company/user info
class EnhancedInvoicePdf {
  /// Build an invoice PDF from a generic map structure.
  /// Required fields in [invoice] are flexible; common keys supported:
  /// - 'ENCF', 'encf', 'NumeroFacturaInterna', 'numero_factura'
  /// - 'FechaEmision', 'fecha_emision', 'fecha'
  /// - 'RNCComprador', 'rnccomprador', 'RazonSocialComprador'
  /// - 'MontoTotal', 'montototal', 'TotalITBIS', 'totalitbis'
  /// - 'DetalleFactura', 'detalle_factura', 'detalleFactura', 'items' (list)
  static Future<Uint8List> buildPdf(
    PdfPageFormat format,
    Map<String, dynamic> invoice, {
    Map<String, dynamic>? companyConfig,
    String? userDisplayName,
    String? logoUrl,
    Uint8List? logoBytes,
  }) async {
    final doc = pw.Document();

    // Company data
    final companyData = _getCompanyData(companyConfig, invoice);

    // Load logo from url or bytes
    pw.ImageProvider? logo;
    try {
      if (logoBytes != null) {
        logo = pw.MemoryImage(logoBytes);
      } else if ((logoUrl ?? companyData['logoUrl']) is String &&
          ((logoUrl ?? companyData['logoUrl']) as String).isNotEmpty) {
        logo = await networkImage((logoUrl ?? companyData['logoUrl']) as String);
      }
    } catch (_) {
      logo = null;
    }

    // Build document
    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _buildHeader(companyData, invoice, logo),
          pw.SizedBox(height: 12),
          _buildCompactInfo(invoice),
          pw.SizedBox(height: 16),
          _buildItemsTable(invoice),
          pw.SizedBox(height: 12),
          _buildTotals(invoice),
          if ((userDisplayName ?? '').isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 16),
              child: pw.Text(
                'Generado por: $userDisplayName',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader(
    Map<String, dynamic> company,
    Map<String, dynamic> invoice,
    pw.ImageProvider? logo,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Logo + company
        pw.Expanded(
          flex: 2,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null)
                pw.Container(
                  width: 64,
                  height: 64,
                  margin: const pw.EdgeInsets.only(right: 12),
                  child: pw.Image(logo, fit: pw.BoxFit.contain),
                ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      company['razonSocial'] ?? 'Nombre de Empresa',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF005285),
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    if (company['direccion'] != null)
                      pw.Text(company['direccion'], style: pw.TextStyle(fontSize: 10)),
                    if (company['telefono'] != null)
                      pw.Text('Tel: ${company['telefono']}', style: pw.TextStyle(fontSize: 10)),
                    if (company['rnc'] != null)
                      pw.Text('RNC: ${company['rnc']}', style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Title and ENCF
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                _getInvoiceTitle(invoice),
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF005285),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text('eCF: ${_getECF(invoice)}', style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildCompactInfo(Map<String, dynamic> invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(children: [
          pw.Expanded(child: _infoRow('No. Factura', _getInvoiceNumber(invoice))),
          pw.SizedBox(width: 10),
          pw.Expanded(child: _infoRow('Fecha', _getInvoiceDate(invoice))),
        ]),
        pw.SizedBox(height: 3),
        pw.Row(children: [
          pw.Expanded(child: _infoRow('Cliente', _getPatientName(invoice))),
          pw.SizedBox(width: 10),
          pw.Expanded(child: _infoRow('RNC/CED', _getRecord(invoice))),
        ]),
      ],
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text('$label: ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 10))),
      ],
    );
  }

  static pw.Widget _buildItemsTable(Map<String, dynamic> invoice) {
    final items = _extractItems(invoice);
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(28),
        1: const pw.FlexColumnWidth(),
        2: const pw.FixedColumnWidth(60),
        3: const pw.FixedColumnWidth(70),
        4: const pw.FixedColumnWidth(80),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE3F2FD)),
          children: [
            _cellHeader('#'),
            _cellHeader('Descripción'),
            _cellHeader('Cant.'),
            _cellHeader('Precio'),
            _cellHeader('Monto'),
          ],
        ),
        ...items.map((e) => pw.TableRow(children: [
              _cellBody(e['id'] ?? ''),
              _cellBody(e['desc'] ?? ''),
              _cellBody(e['qty'] ?? ''),
              _cellBody(e['price'] ?? ''),
              _cellBody(e['amount'] ?? ''),
            ])),
      ],
    );
  }

  static pw.Widget _buildTotals(Map<String, dynamic> invoice) {
    final itbis = _getITBIS(invoice);
    final total = _getNetAmount(invoice);
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 260,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _totalRow('ITBIS', itbis),
            _totalRow('Total Gral', total),
          ],
        ),
      ),
    );
  }

  static pw.Widget _totalRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _cellHeader(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF005285)),
        ),
      );
  static pw.Widget _cellBody(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
      );

  // -------- Helpers ---------
  static Map<String, dynamic> _getCompanyData(
    Map<String, dynamic>? company,
    Map<String, dynamic> invoice,
  ) {
    final razon = company?['razonSocial'] ?? invoice['RazonSocialEmisor'] ?? invoice['razonsocialemisor'] ?? 'Nombre de Empresa';
    final rnc = company?['rnc'] ?? invoice['RNCEmisor'] ?? invoice['rncemisor'];
    final direccion = company?['direccion'] ?? invoice['DireccionEmisor'] ?? invoice['direccionemisor'];
    final telefono = company?['telefono'] ?? invoice['TelefonoEmisor'] ?? invoice['telefonoemisor1'];
    final logoUrl = company?['logoUrl'];
    return {
      'razonSocial': razon,
      'rnc': rnc,
      'direccion': direccion,
      'telefono': telefono,
      'logoUrl': logoUrl,
    };
  }

  static String _getInvoiceTitle(Map<String, dynamic> invoice) {
    return invoice['tipo_factura_titulo']?.toString().trim().isNotEmpty == true
        ? invoice['tipo_factura_titulo']
        : 'FACTURA';
  }

  static String _getECF(Map<String, dynamic> invoice) {
    return (invoice['ENCF'] ?? invoice['encf'] ?? '').toString();
  }

  static String _getInvoiceNumber(Map<String, dynamic> invoice) {
    final v = invoice['NumeroFacturaInterna'] ?? invoice['numero_factura'] ?? invoice['numerofacturainterna'] ?? invoice['fFacturaSecuencia'];
    return v?.toString() ?? '';
  }

  static String _getInvoiceDate(Map<String, dynamic> invoice) {
    final date = invoice['FechaEmision'] ?? invoice['fecha_emision'] ?? invoice['fechaemision'];
    if (date == null) return '';
    final s = date.toString();
    // Try parse common formats
    final formats = [
      DateFormat('dd/MM/yyyy'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('MM/dd/yyyy'),
    ];
    for (final f in formats) {
      try {
        final d = f.parse(s);
        return DateFormat('dd/MM/yyyy').format(d);
      } catch (_) {}
    }
    return s;
  }

  static String _getPatientName(Map<String, dynamic> invoice) {
    return (invoice['NombrePaciente'] ?? invoice['razonsocialcomprador'] ?? invoice['RazonSocialComprador'] ?? '')
        .toString();
  }

  static String _getRecord(Map<String, dynamic> invoice) {
    return (invoice['RNCComprador'] ?? invoice['rnccomprador'] ?? invoice['identificadorextranjero'] ?? '')
        .toString();
  }

  static String _formatMoney(dynamic v) {
    final n = (v is num)
        ? v
        : double.tryParse(v?.toString() ?? '') ?? 0;
    final fmt = NumberFormat.currency(symbol: '', decimalDigits: 2, locale: 'es_DO');
    return fmt.format(n);
  }

  static List<Map<String, String>> _extractItems(Map<String, dynamic> invoice) {
    final raw = invoice['DetalleFactura'] ?? invoice['detalleFactura'] ?? invoice['detalle_factura'] ?? invoice['items'];
    final List<dynamic> list = (raw is List) ? raw : [];
    if (list.isEmpty) {
      // Fallback single item from totals
      final total = invoice['MontoTotal'] ?? invoice['montototal'] ?? invoice['total'];
      return [
        {
          'id': '1',
          'desc': invoice['DescripcionProducto']?.toString() ?? 'Producto/Servicio',
          'qty': '1.00',
          'price': _formatMoney(total),
          'amount': _formatMoney(total),
        }
      ];
    }
    int idx = 0;
    return list.map((item) {
      idx += 1;
      final desc = item['descripcion'] ?? item['nombre'] ?? item['Descripcion'] ?? 'Item';
      final qty = item['cantidad'] ?? item['Cantidad'] ?? '1';
      final price = item['precio'] ?? item['Precio'] ?? item['valor_unitario'] ?? 0;
      final amount = item['monto'] ?? item['Monto'] ?? item['total'] ?? price;
      return {
        'id': '$idx',
        'desc': desc.toString(),
        'qty': (qty is num) ? qty.toStringAsFixed(2) : qty.toString(),
        'price': _formatMoney(price),
        'amount': _formatMoney(amount),
      };
    }).toList();
  }

  static String _getITBIS(Map<String, dynamic> invoice) {
    final itbis = invoice['TotalITBIS'] ?? invoice['totalitbis'] ?? invoice['itbis'] ?? 0;
    return _formatMoney(itbis);
  }

  static String _getNetAmount(Map<String, dynamic> invoice) {
    final total = invoice['MontoTotal'] ?? invoice['montototal'] ?? invoice['total'] ?? 0;
    return _formatMoney(total);
  }
}