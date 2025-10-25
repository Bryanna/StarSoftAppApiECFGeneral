import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/erp_invoice.dart';
import '../models/erp_invoice_extensions.dart';
import '../services/company_config_service.dart';

/// Servicio para generar un PDF con el ENCABEZADO de facturas ARS únicamente
class ArsHeaderPdfService {
  static Future<Uint8List> buildHeaderPdf(
    PdfPageFormat format,
    ERPInvoice invoice,
  ) async {
    final doc = pw.Document();

    // Configuración de empresa
    final configService = CompanyConfigService();
    final companyConfig = await configService.getCompanyConfig();

    // Logo (con fallback seguro)
    pw.ImageProvider? logo;
    final logoUrl = (companyConfig?['logoUrl'] as String?) ?? '';
    try {
      if (logoUrl.isNotEmpty) {
        logo = await networkImage(logoUrl);
      }
    } catch (e) {
      debugPrint('[ArsHeaderPdfService] Error cargando logo: $e');
      try {
        logo = await networkImage(
          'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png',
        );
      } catch (_) {
        logo = null;
      }
    }

    // Datos de empresa con fallback a la factura
    final razonSocial = (companyConfig?['razonSocial'] as String?) ??
        invoice.razonsocialemisor ?? 'Nombre de Empresa';
    final nombreComercial = (companyConfig?['nombreComercial'] as String?) ??
        invoice.nombrecomercial ?? razonSocial;
    final rnc = (companyConfig?['rnc'] as String?) ?? invoice.rncemisor ?? '';
    final direccion = (companyConfig?['direccion'] as String?) ??
        invoice.direccionemisor ?? '';
    final telefono = (companyConfig?['telefono'] as String?) ??
        (invoice.telefonoemisor1 ?? '');
    final email = (companyConfig?['email'] as String?) ??
        (invoice.correoemisor ?? '');
    final website = (companyConfig?['website'] as String?) ??
        (invoice.website ?? '');

    // Datos de factura
    final numeroInterno = invoice.numerofacturainterna ?? '';
    final ncf = invoice.encf ?? '';
    final fechaEmision = invoice.formattedFechaEmision;
    final fechaVenc = invoice.fechavencimientosecuencia ?? '';
    final condicion = invoice.terminopago ?? 'Condición 30 Días';

    // Datos ARS
    final tipoComprobante = (invoice.tipoComprobante ?? invoice.tipoComprobanteDisplay) ?? 'Factura ARS';
    final aseguradora = invoice.razonsocialcomprador ?? invoice.aseguradora ?? '';

    // Estilos
    final primary = const PdfColor.fromInt(0xFF005285);
    final headerTitleStyle = pw.TextStyle(
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: primary,
    );
    final labelStyle = pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.grey800,
    );
    final valueStyle = pw.TextStyle(
      fontSize: 9,
      color: PdfColors.black,
    );

    pw.Widget _labelValue(String label, String value) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: labelStyle),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              value.isNotEmpty ? value : '-',
              style: valueStyle,
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      );
    }

    pw.Widget _sectionTitle(String text) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 6, bottom: 4),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: primary,
          ),
        ),
      );
    }

    String _fmtMoney(num v) => NumberFormat('#,##0.00', 'es_DO').format(v);

    // Preparar resumen por departamento desde detalle_factura
    final detalleStr = invoice.detalleFactura;
    Map<String, Map<String, dynamic>> deptAgg = {};
    int totalCantidad = 0;
    double totalCobertura = 0;
    try {
      if (detalleStr != null && detalleStr.trim().isNotEmpty) {
        final parsed = jsonDecode(detalleStr);
        if (parsed is List) {
          for (final item in parsed) {
            try {
              final dept = (item['departamento'] ?? 'SIN DEPARTAMENTO')
                  .toString()
                  .trim();
              final cobertura = double.tryParse(
                    item['cobertura']?.toString() ?? '0',
                  ) ??
                  0.0;
              final current = deptAgg[dept];
              if (current == null) {
                deptAgg[dept] = {
                  'cantidad': 1,
                  'cobertura': cobertura,
                };
              } else {
                current['cantidad'] = (current['cantidad'] as int) + 1;
                current['cobertura'] =
                    (current['cobertura'] as double) + cobertura;
              }
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      debugPrint('[ArsHeaderPdfService] Error parsing detalle_factura: $e');
    }
    final deptRows = deptAgg.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final e in deptRows) {
      totalCantidad += (e.value['cantidad'] as int);
      totalCobertura += (e.value['cobertura'] as double);
    }

    // Página única con solo encabezado y datos ARS + grid por departamento
    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Fila superior: logo + datos empresa + caja de info factura
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 120,
                    height: 60,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: logo != null
                        ? pw.Image(logo!, fit: pw.BoxFit.contain)
                        : pw.Center(
                            child: pw.Text(
                              'LOGO',
                              style: pw.TextStyle(
                                color: PdfColors.grey600,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Encabezado principal: mostrar nombre de Aseguradora
                        pw.Text(
                          aseguradora.isNotEmpty ? aseguradora : tipoComprobante,
                          style: headerTitleStyle,
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          direccion,
                          style: pw.TextStyle(fontSize: 9),
                        ),
                        pw.SizedBox(height: 1),
                        pw.Text(
                          'RNC: $rnc',
                          style: pw.TextStyle(fontSize: 9),
                        ),
                        pw.Row(
                          children: [
                            pw.Text('Tel.: ${telefono.isEmpty ? '-' : telefono}',
                                style: pw.TextStyle(fontSize: 9)),
                            pw.SizedBox(width: 8),
                            pw.Text('E-mail: ${email.isEmpty ? '-' : email}',
                                style: pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                        if (website.isNotEmpty)
                          pw.Text('Web: $website',
                              style: pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Container(
                    width: 180,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _labelValue('No. Factura', numeroInterno),
                        _labelValue('NCF', ncf),
                        _labelValue('Fecha', fechaEmision),
                        _labelValue('Válido Hasta', fechaVenc),
                        _labelValue('Condición', condicion),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  tipoComprobante.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: primary,
                  ),
                ),
              ),

              pw.SizedBox(height: 8),

              // Grid de resumen por departamento (Cantidad / Descripción / Cobertura)
              if (deptRows.isNotEmpty) ...[
                pw.SizedBox(height: 12),
                _sectionTitle('Detalle por Departamento'),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Table(
                    border: pw.TableBorder.symmetric(
                      inside: pw.BorderSide(color: PdfColors.grey300),
                      outside: pw.BorderSide(color: PdfColors.grey300),
                    ),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(60),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FixedColumnWidth(100),
                    },
                    children: [
                      pw.TableRow(
                        decoration:
                            const pw.BoxDecoration(color: PdfColors.blue100),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Cantidad', style: labelStyle),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Descripción', style: labelStyle),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text('Cobertura', style: labelStyle),
                            ),
                          ),
                        ],
                      ),
                      ...deptRows.map((e) {
                        final dept = e.key.toUpperCase();
                        final cant = e.value['cantidad'] as int;
                        final cobertura = e.value['cobertura'] as double;
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text('$cant', style: valueStyle),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text(dept, style: valueStyle),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Align(
                                alignment: pw.Alignment.centerRight,
                                child: pw.Text(_fmtMoney(cobertura),
                                    style: valueStyle),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'Total : $totalCantidad',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),

                // Totales monetarios debajo del grid
                pw.SizedBox(height: 8),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: 220,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        _labelValue('Subtotal', invoice.formattedSubtotal),
                        _labelValue('ITBIS', invoice.formattedItbis),
                        pw.Divider(color: PdfColors.grey300),
                        _labelValue('Total', invoice.formattedTotal),
                      ],
                    ),
                  ),
                ),
              ],

              // Separador y espacio en blanco para un "header-only"
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 40),

              // Líneas para firmas (opcional)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _signatureLine('ENTREGADO POR'),
                  _signatureLine('RECIBIDO POR'),
                  _signatureLine('FIRMA Y SELLO'),
                ],
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _signatureLine(String label) {
    return pw.Container(
      width: 150,
      child: pw.Column(
        children: [
          pw.SizedBox(height: 40),
          pw.Container(height: 1, color: PdfColors.grey400),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
}