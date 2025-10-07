import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../models/tipo_comprobante.dart';
import '../services/company_config_service.dart';

class InvoicePdfService {
  static Future<Uint8List> buildPdf(PdfPageFormat format, Datum inv) async {
    final doc = pw.Document();

    // Obtener configuración de la empresa
    final configService = CompanyConfigService();
    final companyConfig = await configService.getCompanyConfig();

    // Usar logo configurado o logo por defecto
    final logoUrl =
        companyConfig?['logoUrl'] as String? ??
        'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png';

    pw.ImageProvider? logo;
    try {
      logo = await networkImage(logoUrl);
    } catch (e) {
      // Si falla cargar el logo, usar uno por defecto o null
      try {
        logo = await networkImage(
          'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png',
        );
      } catch (e2) {
        logo = null; // No mostrar logo si no se puede cargar ninguno
      }
    }

    final headerStyle = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: PdfColor.fromInt(0xFF005285),
    );
    final sectionTitleStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColor.fromInt(0xFF005285),
    );
    final labelStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );
    final valueStyle = pw.TextStyle(fontSize: 10);

    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 120,
                    height: 60,
                    child: logo != null
                        ? pw.Image(logo, fit: pw.BoxFit.contain)
                        : pw.Container(
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey300),
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                'LOGO',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  color: PdfColors.grey600,
                                ),
                              ),
                            ),
                          ),
                  ),
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Text(
                        companyConfig?['razonSocial'] as String? ??
                            'CENTRO MEDICO PREVENTIVO SALUD Y VIDA SRL',
                        style: headerStyle,
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ),
                  pw.Container(
                    width: 160,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'FACTURA ELECTRÓNICA',
                          style: headerStyle.copyWith(fontSize: 14),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'e-CF: ${inv.encf ?? inv.fDocumento ?? '-'}',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Fecha Emisión: ${_fmtDateDt(inv.fechaemision)}',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Fecha Vencimiento: ${_fmtDateDt(inv.fechavencimientosecuencia)}',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(),

              pw.SizedBox(height: 8),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Datos del Emisor', style: sectionTitleStyle),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'RNC: ${inv.rncemisor ?? inv.fRncEmisor ?? '-'}',
                          style: valueStyle,
                        ),
                        pw.Text(
                          'Nombre: ${inv.razonsocialemisor?.toString().split('.').last ?? '-'}',
                          style: valueStyle,
                        ),
                        pw.Text(
                          'Dirección: ${inv.direccionemisor?.toString().split('.').last ?? '-'}',
                          style: valueStyle,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Datos del Comprador',
                          style: sectionTitleStyle,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'RNC: ${inv.rnccomprador ?? inv.fRncReceptor ?? '-'}',
                          style: valueStyle,
                        ),
                        pw.Text(
                          'Nombre: ${inv.razonsocialcomprador?.toString().split('.').last ?? inv.fReceptorNombre ?? '-'}',
                          style: valueStyle,
                        ),
                        pw.Text(
                          'Dirección: ${inv.direccioncomprador ?? inv.fDireccionReceptor ?? '-'}',
                          style: valueStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),
              pw.Text(
                'Detalle de Productos',
                style: headerStyle.copyWith(fontSize: 14),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                columnWidths: {
                  0: pw.FlexColumnWidth(0.7),
                  1: pw.FlexColumnWidth(3.0),
                  2: pw.FlexColumnWidth(1.0),
                  3: pw.FlexColumnWidth(1.3),
                  4: pw.FlexColumnWidth(1.3),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFF7E6BE),
                    ),
                    children: [
                      _cell('#', bold: true),
                      _cell('Descripción', bold: true),
                      _cell('Cant.', bold: true),
                      _cell('Precio Unitario', bold: true),
                      _cell('Total', bold: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _cell('1'),
                      _cell(
                        descripcionDesdeDocumento(inv.fDocumento) ??
                            'Detalle de comprobante',
                      ),
                      _cell('1'),
                      _cell(
                        _fmtMoneySafe(
                          _toNum(inv.fSubtotal) ?? _toNum(inv.montototal),
                        ),
                      ),
                      _cell(
                        _fmtMoneySafe(
                          _toNum(inv.fSubtotal) ?? _toNum(inv.montototal),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 12),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        pw.Container(
                          width: 140,
                          height: 140,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                          ),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            'QR (pendiente)',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text(
                            'Código de Seguridad: ${inv.codigoSeguridad ?? '—'}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ),
                        pw.Align(
                          alignment: pw.Alignment.centerLeft,
                          child: pw.Text(
                            'Fecha Firma: ${_fmtDateDt(inv.fechaHoraFirma)}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _totalRow(
                          'Subtotal Gravado:',
                          _fmtMoneySafe(
                            _toNum(inv.montogravadototal) ??
                                _toNum(inv.fSubtotal),
                          ),
                        ),
                        _totalRow(
                          'Total ITBIS:',
                          _fmtMoneySafe(
                            _toNum(inv.totalitbis) ?? _toNum(inv.fItbis),
                          ),
                        ),
                        _totalRow(
                          'Monto Total:',
                          _fmtMoneySafe(
                            _toNum(inv.montototal) ?? _toNum(inv.fTotal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Generado por CENSAVID',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return iso;
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      return iso;
    }
  }

  static String _fmtMoney(num? n) {
    final f = NumberFormat.currency(locale: 'es_DO', symbol: ' 24');
    return f.format((n ?? 0).toDouble());
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _totalRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(width: 8),
        pw.Text(value, style: pw.TextStyle(fontSize: 11)),
      ],
    );
  }

  // Safe helpers that match Datum field types
  static String _fmtDateDt(DateTime? dt) {
    if (dt == null) return '-';
    try {
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (_) {
      return '-';
    }
  }

  static String _fmtMoneySafe(num? n) {
    final f = NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$');
    return f.format((n ?? 0).toDouble());
  }

  static num? _toNum(String? s) {
    if (s == null) return null;
    final cleaned = s.replaceAll(',', '');
    return double.tryParse(cleaned);
  }
}
