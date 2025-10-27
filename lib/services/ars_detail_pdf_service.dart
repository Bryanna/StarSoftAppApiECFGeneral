import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/erp_invoice.dart';
import '../models/erp_invoice_extensions.dart';
import '../services/company_config_service.dart';

/// Servicio para generar el PDF "Ver Detalle ARS" con el mismo encabezado
/// y una tabla detallada por departamento como en las imágenes aportadas.
class ArsDetailPdfService {
  static Future<Uint8List> buildDetailPdf(
    PdfPageFormat format,
    ERPInvoice invoice,
  ) async {
    final doc = pw.Document();

    // Configuración de empresa
    final configService = CompanyConfigService();
    final companyConfig = await configService.getCompanyConfig();

    // Logo
    pw.ImageProvider? logo;
    final logoUrl = (companyConfig?['logoUrl'] as String?) ?? '';
    try {
      if (logoUrl.isNotEmpty) {
        logo = await networkImage(logoUrl);
      }
    } catch (e) {
      debugPrint('[ArsDetailPdfService] Error cargando logo: $e');
      try {
        logo = await networkImage(
          'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png',
        );
      } catch (_) {
        logo = null;
      }
    }

    // Datos de empresa/factura
    final razonSocial =
        (companyConfig?['razonSocial'] as String?) ??
        invoice.razonsocialemisor ??
        'Nombre de Empresa';
    final rnc = (companyConfig?['rnc'] as String?) ?? invoice.rncemisor ?? '';
    final direccion =
        (companyConfig?['direccion'] as String?) ??
        invoice.direccionemisor ??
        '';
    final telefono =
        (companyConfig?['telefono'] as String?) ??
        (invoice.telefonoemisor1 ?? '');
    final email =
        (companyConfig?['email'] as String?) ?? (invoice.correoemisor ?? '');
    final website =
        (companyConfig?['website'] as String?) ?? (invoice.website ?? '');

    final numeroInterno = invoice.numerofacturainterna ?? '';
    final ncf = invoice.encf ?? '';
    final fechaEmision = invoice.formattedFechaEmision;
    final fechaVenc = invoice.fechavencimientosecuencia ?? '';
    final condicion = invoice.terminopago ?? 'Condición 30 Días';

    final tipoComprobante =
        (invoice.tipoComprobante ?? invoice.tipoComprobanteDisplay) ??
        'Factura ARS';
    final aseguradora =
        invoice.razonsocialcomprador ?? invoice.aseguradora ?? '';

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
    final valueStyle = pw.TextStyle(fontSize: 9, color: PdfColors.black);

    pw.Widget labelValue(String label, String value) {
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

    String fmtMoney(num v) => NumberFormat('#,##0.00', 'es_DO').format(v);

    // Parse y agrupación por departamento desde detalle_factura
    final detalleStr = invoice.detalleFactura;
    final Map<String, List<Map<String, dynamic>>> groups = {};
    int totalServicios = 0;
    double totalCoberturaGlobal = 0.0;
    try {
      if (detalleStr != null && detalleStr.trim().isNotEmpty) {
        final parsed = jsonDecode(detalleStr);
        if (parsed is List) {
          for (final raw in parsed) {
            if (raw is Map<String, dynamic>) {
              final dept = (raw['departamento'] ?? 'SIN DEPARTAMENTO')
                  .toString()
                  .trim();
              final cobertura =
                  double.tryParse(raw['cobertura']?.toString() ?? '0') ?? 0.0;
              groups.putIfAbsent(dept, () => []);
              groups[dept]!.add(raw);
              totalServicios += 1;
              totalCoberturaGlobal += cobertura;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[ArsDetailPdfService] Error parsing detalle_factura: $e');
    }

    List<MapEntry<String, List<Map<String, dynamic>>>> ordered =
        groups.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    // Construye widgets de departamento en chunks para evitar TooManyPagesException
    List<pw.Widget> buildDepartmentWidgets(
      String departamento,
      List<Map<String, dynamic>> items,
    ) {
      double totalDepto = 0.0;
      for (final it in items) {
        totalDepto +=
            double.tryParse(it['cobertura']?.toString() ?? '0') ?? 0.0;
      }

      pw.TableRow headerRow() {
        return pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue100),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Autorización', style: labelStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Fecha', style: labelStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Afiliado', style: labelStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Paciente', style: labelStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Fact. No.', style: labelStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Cobertura', style: labelStyle),
            ),
          ],
        );
      }

      pw.TableRow dataRow(Map<String, dynamic> it) {
        final autorizacion = (it['autorizacion'] ?? '').toString();
        final fecha = (it['fecha_factura'] ?? '').toString();
        final afiliado = (it['paciente'] ?? it['referencia'] ?? '').toString();
        final paciente = (it['descripcion'] ?? '').toString();
        final factura = (it['factura_paciente'] ?? '').toString();
        final cobertura =
            double.tryParse(it['cobertura']?.toString() ?? '0') ?? 0.0;
        return pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(autorizacion, style: valueStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(fecha, style: valueStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(afiliado, style: valueStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                paciente,
                style: valueStyle,
                maxLines: 1,
                overflow: pw.TextOverflow.clip,
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(factura, style: valueStyle),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(fmtMoney(cobertura), style: valueStyle),
              ),
            ),
          ],
        );
      }

      // Chunk de filas para que cada tabla sea razonable y pueda paginar
      const int rowsPerChunk = 18; // tamaño conservador por página
      final List<pw.Widget> widgets = [];

      // Encabezado del departamento
      widgets.add(
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: PdfColors.green600,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            departamento,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      );
      widgets.add(pw.SizedBox(height: 4));

      // Crear tablas por chunk
      for (int i = 0; i < items.length; i += rowsPerChunk) {
        final chunk = items.sublist(
          i,
          i + rowsPerChunk > items.length ? items.length : i + rowsPerChunk,
        );
        final isLastChunk = i + rowsPerChunk >= items.length;
        final isFirstChunk = i == 0;

        widgets.add(
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(85),
              1: const pw.FixedColumnWidth(70),
              2: const pw.FixedColumnWidth(60),
              3: const pw.FlexColumnWidth(4),
              4: const pw.FixedColumnWidth(95),
              5: const pw.FixedColumnWidth(85),
            },
            children: [
              if (isFirstChunk) headerRow(),
              ...chunk.map(dataRow),
              if (isLastChunk)
                pw.TableRow(
                  children: [
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.SizedBox(),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        'Total $departamento',
                        style: labelStyle,
                        maxLines: 1,
                        overflow: pw.TextOverflow.clip,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(4),
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        fmtMoney(totalDepto),
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );

        // Espacio entre tablas
        widgets.add(pw.SizedBox(height: 4));
      }

      return widgets;
    }

    // Construcción de la página
    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(20),
        maxPages: 2000,
        build: (context) => [
          // Encabezado común (logo + datos + caja de info)
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
                    ? pw.Image(logo, fit: pw.BoxFit.contain)
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
                    pw.Text(
                      aseguradora.isNotEmpty ? aseguradora : tipoComprobante,
                      style: headerTitleStyle,
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(direccion, style: pw.TextStyle(fontSize: 7)),
                    pw.SizedBox(height: 1),
                    pw.Text('RNC: $rnc', style: pw.TextStyle(fontSize: 7)),
                    pw.Row(
                      children: [
                        pw.Text(
                          'Tel.: ${telefono.isEmpty ? '-' : telefono}',
                          style: pw.TextStyle(fontSize: 7),
                        ),
                        pw.SizedBox(width: 8),
                        pw.Text(
                          'E-mail: ${email.isEmpty ? '-' : email}',
                          style: pw.TextStyle(fontSize: 7),
                        ),
                      ],
                    ),
                    if (website.isNotEmpty)
                      pw.Text(
                        'Web: $website',
                        style: pw.TextStyle(fontSize: 7),
                      ),
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
                    labelValue('No. Factura', numeroInterno),
                    labelValue('NCF', ncf),
                    labelValue('Fecha', fechaEmision),
                    labelValue('Válido Hasta', fechaVenc),
                    labelValue('Condición', condicion),
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
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: primary,
              ),
            ),
          ),

          pw.SizedBox(height: 8),

          // Secciones por departamento en chunks para paginación segura
          if (ordered.isNotEmpty)
            ...ordered.expand((e) => buildDepartmentWidgets(e.key, e.value)),

          // Resumen final (Servicios y Total facturado por ARS)
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '$totalServicios Servicios',
                style: pw.TextStyle(fontSize: 8),
              ),
              pw.Row(
                children: [
                  pw.Text(
                    'Total Facturado por ${aseguradora.isNotEmpty ? aseguradora : 'ARS'}: ',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    invoice.formattedTotal.isNotEmpty
                        ? invoice.formattedTotal
                        : fmtMoney(totalCoberturaGlobal),
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 20),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 40),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _signatureLine('ENTREGADO POR'),
              _signatureLine('RECIBIDO POR'),
              _signatureLine('FIRMA Y SELLO'),
            ],
          ),
        ],
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
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }
}
