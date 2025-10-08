import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../services/company_config_service.dart';

class EnhancedInvoicePdfService {
  static Future<Uint8List> buildPdf(
    PdfPageFormat format,
    Datum? invoice,
  ) async {
    final doc = pw.Document();

    // Obtener configuración de la empresa
    final configService = CompanyConfigService();
    final companyConfig = await configService.getCompanyConfig();

    // Verificar si usar datos fake
    final useFakeData = companyConfig?['useFakeData'] ?? false;

    debugPrint('[EnhancedInvoicePdfService] Using fake data: $useFakeData');

    // Usar datos fake o reales según configuración
    final invoiceData = useFakeData ? _getFakeInvoiceData() : invoice;
    final companyData = _getCompanyData(companyConfig);

    // Cargar logo de la empresa
    pw.ImageProvider? logo;
    try {
      final logoUrl = companyConfig?['logoUrl'] as String?;
      if (logoUrl != null && logoUrl.isNotEmpty) {
        logo = await networkImage(logoUrl);
        debugPrint('[EnhancedInvoicePdfService] Logo cargado exitosamente');
      }
    } catch (e) {
      debugPrint('[EnhancedInvoicePdfService] Error cargando logo: $e');
      logo = null;
    }

    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header con logo y datos de la empresa
              _buildHeader(logo, companyData, invoiceData),

              pw.SizedBox(height: 20),

              // Tabla de productos/servicios
              _buildProductsTable(invoiceData, useFakeData),

              pw.Spacer(),

              // Footer con QR y totales
              _buildFooter(invoiceData, useFakeData),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader(
    pw.ImageProvider? logo,
    Map<String, dynamic> companyData,
    dynamic invoiceData,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Logo y datos de la empresa (lado izquierdo)
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo
              if (logo != null)
                pw.Container(
                  width: 120,
                  height: 80,
                  child: pw.Image(logo, fit: pw.BoxFit.contain),
                )
              else
                pw.Container(
                  width: 120,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'LOGO',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey600,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              pw.SizedBox(height: 10),

              // Datos de la empresa
              pw.Text(
                companyData['direccion'] ??
                    'Calle Real Tamboril #138, Santiago, Rep. Dom.',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Rif: ${companyData['rnc'] ?? '131243932'} Tel: ${companyData['telefono'] ?? '809-580-3555'}',
                style: pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'CONTADO - LABORATORIO',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        pw.SizedBox(width: 20),

        // Información de la factura (lado derecho)
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Título
              pw.Center(
                child: pw.Text(
                  'FACTURA DE CONSUMO',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF005285),
                  ),
                ),
              ),

              pw.SizedBox(height: 15),

              // Datos de la factura en dos columnas
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          'No. Factura',
                          _getInvoiceNumber(invoiceData),
                        ),
                        _buildInfoRow('Autorización', '941984081'),
                        _buildInfoRow('Fecha', _getInvoiceDate(invoiceData)),
                        _buildInfoRow('NCF', _getNCF(invoiceData)),
                        _buildInfoRow('Aseguradora', 'ARS PRIMERA'),
                        _buildInfoRow('NSS', '48021452600'),
                        _buildInfoRow(
                          'Médico',
                          'Dra. Liliana Altagracia Grullon Nuñez',
                        ),
                        _buildInfoRow('Record', '82779 Rnc/Ced. 03200125635'),
                        _buildInfoRow(
                          'Nombre',
                          'Modesto Antonio Padilla Cespedes',
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(
                          height: 60,
                        ), // Espacio para alinear con la segunda columna
                        _buildInfoRow('', 'N/A'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildProductsTable(dynamic invoiceData, bool useFakeData) {
    return pw.Column(
      children: [
        // Header de la tabla
        pw.Container(
          decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF4CAF50)),
          child: pw.Row(
            children: [
              _buildTableHeader('ID', flex: 1),
              _buildTableHeader('Descripción', flex: 4),
              _buildTableHeader('Cantidad', flex: 1),
              _buildTableHeader('Precio', flex: 1),
              _buildTableHeader('Importe', flex: 1),
              _buildTableHeader('Cobertura', flex: 1),
              _buildTableHeader('Neto / Pagar', flex: 1),
            ],
          ),
        ),

        // Filas de productos
        ...(_getProductRows(invoiceData, useFakeData)),

        // Fila de totales
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
          ),
          child: pw.Row(
            children: [
              _buildTableCell(
                'Items: ${_getItemCount(useFakeData)}',
                flex: 6,
                bold: true,
              ),
              _buildTableCell(
                _getTotalAmount(invoiceData, useFakeData),
                flex: 1,
                bold: true,
              ),
              _buildTableCell(
                _getCoverageAmount(useFakeData),
                flex: 1,
                bold: true,
              ),
              _buildTableCell(
                _getNetAmount(invoiceData, useFakeData),
                flex: 1,
                bold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static List<pw.Widget> _getProductRows(
    dynamic invoiceData,
    bool useFakeData,
  ) {
    if (useFakeData) {
      return [
        _buildProductRow(
          '1500',
          'ANTIGENO CARCINOEMBRIOGENICO (CEA)',
          '1.0',
          '427.34',
          '427.34',
          '341.87',
          '85.47',
        ),
        _buildProductRow(
          '377',
          'ANTI HCV (HEPATITI C)',
          '1.0',
          '427.34',
          '427.34',
          '341.87',
          '85.47',
        ),
        _buildProductRow(
          '288',
          'ANTI HIV',
          '1.0',
          '388.85',
          '388.85',
          '319.08',
          '79.77',
        ),
        _buildProductRow(
          '290',
          'ANTIGENO AUSTRALIANO (HBS AG) HEPATITIS B',
          '1.0',
          '427.34',
          '427.34',
          '341.87',
          '85.47',
        ),
        _buildProductRow(
          '295',
          'BILIRRUBINAS TOTAL Y DIRECTA',
          '1.0',
          '212.99',
          '212.99',
          '170.39',
          '42.60',
        ),
        _buildProductRow(
          '393',
          'LIPASA',
          '1.0',
          '469.40',
          '469.40',
          '375.52',
          '93.88',
        ),
        _buildProductRow(
          '486',
          'CA 19-9',
          '1.0',
          '454.47',
          '454.47',
          '363.58',
          '90.89',
        ),
      ];
    } else {
      // Usar datos reales del invoice si están disponibles
      return [
        _buildProductRow(
          '1',
          _getProductDescription(invoiceData),
          '1.0',
          _getUnitPrice(invoiceData),
          _getTotalPrice(invoiceData),
          '0.00',
          _getTotalPrice(invoiceData),
        ),
      ];
    }
  }

  static pw.Widget _buildProductRow(
    String id,
    String description,
    String quantity,
    String price,
    String amount,
    String coverage,
    String net,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
      ),
      child: pw.Row(
        children: [
          _buildTableCell(id, flex: 1),
          _buildTableCell(description, flex: 4),
          _buildTableCell(quantity, flex: 1),
          _buildTableCell(price, flex: 1),
          _buildTableCell(amount, flex: 1),
          _buildTableCell(coverage, flex: 1),
          _buildTableCell(net, flex: 1),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(dynamic invoiceData, bool useFakeData) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        // QR Code (lado izquierdo)
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            children: [
              pw.Container(
                width: 100,
                height: 100,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'QR CODE',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Código de Seguridad: ${_getSecurityCode(invoiceData, useFakeData)}',
                style: pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                'Fecha de Firma Digital: ${_getSignatureDate(invoiceData, useFakeData)}',
                style: pw.TextStyle(fontSize: 8),
              ),
              pw.Text('Página 1/1', style: pw.TextStyle(fontSize: 8)),
              pw.Text('Ing Abel Medrano', style: pw.TextStyle(fontSize: 8)),
            ],
          ),
        ),

        pw.SizedBox(width: 40),

        // Totales (lado derecho)
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(4),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFF2196F3),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'Firma',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    _buildTotalRow(
                      'Total Clínico',
                      _getTotalClinico(invoiceData, useFakeData),
                      PdfColor.fromInt(0xFF2196F3),
                    ),
                    _buildTotalRow(
                      'Cobertura',
                      _getCoverageAmount(useFakeData),
                      PdfColor.fromInt(0xFF2196F3),
                    ),
                    _buildTotalRow(
                      'ITBIS',
                      '0.00',
                      PdfColor.fromInt(0xFF2196F3),
                    ),
                    _buildTotalRow(
                      'Total Gral',
                      _getNetAmount(invoiceData, useFakeData),
                      PdfColor.fromInt(0xFF2196F3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods para construir widgets
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 9))),
        ],
      ),
    );
  }

  static pw.Widget _buildTableHeader(String text, {int flex = 1}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    int flex = 1,
    bool bold = false,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, String value, PdfColor color) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: color,
        border: pw.Border.all(color: PdfColors.white, width: 0.5),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Métodos para obtener datos fake
  static dynamic _getFakeInvoiceData() {
    return {
      'invoiceNumber': '0000034807',
      'date': DateTime.now(),
      'ncf': 'B0200308927',
      'total': 2817.73,
      'subtotal': 2254.18,
      'coverage': 2254.18,
      'net': 563.55,
    };
  }

  static Map<String, dynamic> _getCompanyData(Map<String, dynamic>? config) {
    return {
      'razonSocial':
          config?['razonSocial'] ?? 'CENTRO MEDICO PREVENTIVO SALUD Y VIDA',
      'direccion':
          config?['direccion'] ??
          'Calle Real Tamboril #138, Santiago, Rep. Dom.',
      'rnc': config?['rnc'] ?? '131243932',
      'telefono': config?['telefono'] ?? '809-580-3555',
    };
  }

  // Métodos para extraer datos del invoice real o fake
  static String _getInvoiceNumber(dynamic invoice) {
    if (invoice is Map) return invoice['invoiceNumber'] ?? '0000034807';
    return invoice?.encf ?? invoice?.fDocumento ?? '0000034807';
  }

  static String _getInvoiceDate(dynamic invoice) {
    if (invoice is Map) {
      final date = invoice['date'] as DateTime?;
      return date != null
          ? DateFormat('dd/MM/yyyy').format(date)
          : DateFormat('dd/MM/yyyy').format(DateTime.now());
    }
    final date = invoice?.fechaemision;
    return date != null
        ? DateFormat('dd/MM/yyyy').format(date)
        : DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  static String _getNCF(dynamic invoice) {
    if (invoice is Map) return invoice['ncf'] ?? 'B0200308927';
    return invoice?.encf ?? 'B0200308927';
  }

  static String _getProductDescription(dynamic invoice) {
    if (invoice == null) return 'Servicios médicos';
    return 'Servicios de laboratorio clínico';
  }

  static String _getUnitPrice(dynamic invoice) {
    if (invoice is Map) return _formatMoney(invoice['total'] ?? 0);
    final total = _toNum(invoice?.montototal) ?? _toNum(invoice?.fTotal) ?? 0;
    return _formatMoney(total);
  }

  static String _getTotalPrice(dynamic invoice) {
    return _getUnitPrice(invoice);
  }

  static String _getTotalAmount(dynamic invoice, bool useFakeData) {
    if (useFakeData) return '2,817.73';
    if (invoice is Map) return _formatMoney(invoice['total'] ?? 0);
    final total = _toNum(invoice?.montototal) ?? _toNum(invoice?.fTotal) ?? 0;
    return _formatMoney(total);
  }

  static String _getCoverageAmount(bool useFakeData) {
    if (useFakeData) return '2,254.18';
    return '0.00';
  }

  static String _getNetAmount(dynamic invoice, bool useFakeData) {
    if (useFakeData) return '563.55';
    if (invoice is Map) return _formatMoney(invoice['total'] ?? 0);
    final total = _toNum(invoice?.montototal) ?? _toNum(invoice?.fTotal) ?? 0;
    return _formatMoney(total);
  }

  static String _getTotalClinico(dynamic invoice, bool useFakeData) {
    if (useFakeData) return '2,817.73';
    if (invoice is Map) return _formatMoney(invoice['total'] ?? 0);
    final total = _toNum(invoice?.montototal) ?? _toNum(invoice?.fTotal) ?? 0;
    return _formatMoney(total);
  }

  static String _getItemCount(bool useFakeData) {
    return useFakeData ? '7' : '1';
  }

  static String _getSecurityCode(dynamic invoice, bool useFakeData) {
    if (useFakeData) return 'WKT3Sa';
    return invoice?.codigoSeguridad ?? 'WKT3Sa';
  }

  static String _getSignatureDate(dynamic invoice, bool useFakeData) {
    if (useFakeData) return '20/09/24';
    final date = invoice?.fechaHoraFirma ?? DateTime.now();
    return DateFormat('dd/MM/yy').format(date);
  }

  // Utility methods
  static String _formatMoney(num value) {
    return NumberFormat('#,##0.00').format(value);
  }

  static num? _toNum(String? s) {
    if (s == null) return null;
    final cleaned = s.replaceAll(',', '');
    return double.tryParse(cleaned);
  }
}
