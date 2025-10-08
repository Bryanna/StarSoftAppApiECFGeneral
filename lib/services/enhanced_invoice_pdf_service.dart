import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../services/company_config_service.dart';
import '../services/fake_data_service.dart';

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

    // Usar datos reales del JSON/endpoint
    final invoiceData = invoice;
    final companyData = _getCompanyData(companyConfig);

    // Pre-cargar datos de productos si es fake data
    final productRows = await _getProductRows(invoiceData, useFakeData);

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
              _buildProductsTableSync(invoiceData, useFakeData, productRows),

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
                  _getInvoiceTitle(invoiceData),
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF005285),
                  ),
                ),
              ),

              pw.SizedBox(height: 15),

              // Datos de la factura en formato compacto
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _buildCompactInfoRow(
                          'No. Factura',
                          _getInvoiceNumber(invoiceData),
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: _buildCompactInfoRow(
                          'Autorización',
                          _getAuthorization(invoiceData),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _buildCompactInfoRow(
                          'Fecha',
                          _getInvoiceDate(invoiceData),
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: _buildCompactInfoRow(
                          'eCF',
                          _getECF(invoiceData),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _buildCompactInfoRow(
                          'Aseguradora',
                          _getInsurance(invoiceData),
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: _buildCompactInfoRow(
                          'NSS',
                          _getNSS(invoiceData),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  _buildCompactInfoRow('Médico', _getDoctor(invoiceData)),
                  pw.SizedBox(height: 3),
                  _buildCompactInfoRow('Record', _getRecord(invoiceData)),
                  pw.SizedBox(height: 3),
                  _buildCompactInfoRow('Nombre', _getPatientName(invoiceData)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildProductsTableSync(
    dynamic invoiceData,
    bool useFakeData,
    List<pw.Widget> productRows,
  ) {
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

        // Filas de productos (pre-cargadas)
        ...productRows,

        // Fila de totales
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
          ),
          child: pw.Row(
            children: [
              _buildTableCell(
                'Items: ${_getItemCount(invoiceData)}',
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

  static Future<List<pw.Widget>> _getProductRows(
    dynamic invoiceData,
    bool useFakeData,
  ) async {
    if (useFakeData) {
      try {
        // Usar datos reales de productos desde el JSON
        final products = await FakeDataService.getProductDetails();
        final selectedProducts = products
            .take(7)
            .toList(); // Tomar los primeros 7

        return selectedProducts.map((product) {
          final precio = _formatMoney(
            double.tryParse(product['precio'] ?? '0') ?? 0,
          );
          final cantidad = product['cantidad'] ?? '1.0';
          final monto = _formatMoney(
            double.tryParse(product['monto'] ?? '0') ?? 0,
          );

          // Calcular cobertura (80% del monto para simular ARS)
          final montoNum = double.tryParse(product['monto'] ?? '0') ?? 0;
          final cobertura = _formatMoney(montoNum * 0.8);
          final neto = _formatMoney(montoNum * 0.2);

          return _buildProductRow(
            product['id'] ?? '1',
            product['nombre'] ?? 'Producto',
            cantidad,
            precio,
            monto,
            cobertura,
            neto,
          );
        }).toList();
      } catch (e) {
        debugPrint(
          '[EnhancedInvoicePdfService] Error loading product data: $e',
        );
        // Fallback a datos básicos
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
        ];
      }
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
                      _getITBIS(invoiceData),
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
  static pw.Widget _buildCompactInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Container(
          width: 60,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 7),
            overflow: pw.TextOverflow.clip,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text, {int flex = 1}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(2),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 6,
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
        padding: const pw.EdgeInsets.all(2),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 6,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
          textAlign: pw.TextAlign.center,
          overflow: pw.TextOverflow.clip,
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

  // Métodos para extraer datos del JSON real
  static String _getInvoiceNumber(dynamic invoice) {
    // Usar NumeroFacturaInterna del JSON
    if (invoice is Map) return invoice['NumeroFacturaInterna'] ?? '';
    return invoice?.fDocumento ?? '';
  }

  static String _getInvoiceDate(dynamic invoice) {
    // Usar FechaEmision del JSON
    if (invoice is Map) {
      final dateStr = invoice['FechaEmision'] as String?;
      if (dateStr != null && dateStr != '#e') {
        try {
          final parts = dateStr.split('-');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            final date = DateTime(year, month, day);
            return DateFormat('dd/MM/yyyy').format(date);
          }
        } catch (e) {
          return dateStr;
        }
      }
      return '';
    }
    final date = invoice?.fechaemision;
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : '';
  }

  static String _getECF(dynamic invoice) {
    // Usar ENCF del JSON
    if (invoice is Map) return invoice['ENCF'] ?? '';
    return invoice?.encf ?? '';
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
    // Usar MontoTotal del JSON
    if (invoice is Map) {
      final montoStr = invoice['MontoTotal'] as String?;
      if (montoStr != null && montoStr != '#e') {
        final monto = double.tryParse(montoStr) ?? 0;
        return _formatMoney(monto);
      }
      return '0.00';
    }
    final total = _toNum(invoice?.montototal) ?? _toNum(invoice?.fTotal) ?? 0;
    return _formatMoney(total);
  }

  static String _getCoverageAmount(bool useFakeData) {
    // No hay cobertura en el JSON real, siempre 0
    return '0.00';
  }

  static String _getNetAmount(dynamic invoice, bool useFakeData) {
    // El neto es igual al total cuando no hay cobertura
    return _getTotalAmount(invoice, useFakeData);
  }

  static String _getTotalClinico(dynamic invoice, bool useFakeData) {
    // Usar MontoTotal del JSON
    return _getTotalAmount(invoice, useFakeData);
  }

  static String _getITBIS(dynamic invoice) {
    // Usar TotalITBIS del JSON
    if (invoice is Map) {
      final itbisStr = invoice['TotalITBIS'] as String?;
      if (itbisStr != null && itbisStr != '#e') {
        final itbis = double.tryParse(itbisStr) ?? 0;
        return _formatMoney(itbis);
      }
      return '0.00';
    }
    final itbis = _toNum(invoice?.totalitbis) ?? _toNum(invoice?.fItbis) ?? 0;
    return _formatMoney(itbis);
  }

  static String _getItemCount(dynamic invoice) {
    // Contar los items reales del JSON
    if (invoice is Map) {
      int count = 0;
      for (int i = 1; i <= 20; i++) {
        final nombreKey = 'NombreItem[$i]';
        if (invoice.containsKey(nombreKey) &&
            invoice[nombreKey] != null &&
            invoice[nombreKey] != '#e') {
          count++;
        }
      }
      return count.toString();
    }
    return '1';
  }

  static String _getSecurityCode(dynamic invoice, bool useFakeData) {
    // Usar CodigoSeguridad del JSON si existe
    if (invoice is Map) return invoice['CodigoSeguridad'] ?? '';
    return invoice?.codigoSeguridad ?? '';
  }

  static String _getSignatureDate(dynamic invoice, bool useFakeData) {
    // Usar FechaEmision como fecha de firma si no hay otra
    if (invoice is Map) {
      final dateStr = invoice['FechaEmision'] as String?;
      if (dateStr != null && dateStr != '#e') {
        try {
          final parts = dateStr.split('-');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            final date = DateTime(year, month, day);
            return DateFormat('dd/MM/yy').format(date);
          }
        } catch (e) {
          return dateStr;
        }
      }
      return '';
    }
    final date = invoice?.fechaHoraFirma ?? invoice?.fechaemision;
    return date != null ? DateFormat('dd/MM/yy').format(date) : '';
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

  // Métodos para extraer datos específicos del JSON real
  static String _getAuthorization(dynamic invoice) {
    // No existe en el JSON real, siempre vacío
    return '';
  }

  static String _getInsurance(dynamic invoice) {
    // No existe en el JSON real, siempre vacío
    return '';
  }

  static String _getNSS(dynamic invoice) {
    // No existe en el JSON real, siempre vacío
    return '';
  }

  static String _getDoctor(dynamic invoice) {
    // No existe en el JSON real, siempre vacío
    return '';
  }

  static String _getRecord(dynamic invoice) {
    // No existe en el JSON real, siempre vacío
    return '';
  }

  static String _getPatientName(dynamic invoice) {
    // Usar RazonSocialComprador del JSON
    if (invoice is Map) return invoice['RazonSocialComprador'] ?? '';
    return invoice?.razonsocialcomprador?.toString() ?? '';
  }

  static String _getInvoiceTitle(dynamic invoice) {
    // Obtener el tipo de comprobante del eCF
    final ecf = _getECF(invoice);
    if (ecf.isNotEmpty && ecf.length >= 3) {
      final tipoCode = ecf.substring(1, 3); // Extraer código después de 'E'
      switch (tipoCode) {
        case '31':
          return 'FACTURA DE CONSUMO';
        case '32':
          return 'FACTURA DE CRÉDITO FISCAL';
        case '33':
          return 'FACTURA GUBERNAMENTAL';
        case '34':
          return 'FACTURA REGÍMENES ESPECIALES';
        case '41':
          return 'NOTA DE DÉBITO';
        case '43':
          return 'NOTA DE CRÉDITO';
        case '44':
          return 'COMPROBANTE DE COMPRAS';
        case '45':
          return 'COMPROBANTE DE GASTOS MENORES';
        default:
          return 'COMPROBANTE FISCAL ELECTRÓNICO';
      }
    }
    return 'FACTURA ELECTRÓNICA';
  }
}
