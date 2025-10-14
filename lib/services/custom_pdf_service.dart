import 'dart:typed_data';
import 'package:facturacion/models/pdf_element.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../screens/pdf_maker/pdf_maker_controller.dart';
import '../services/company_config_service.dart';
import '../services/user_service.dart';

class CustomPdfService {
  static Future<Uint8List> generatePdfFromTemplate({
    required List<PdfElement> template,
    required Map<String, dynamic> invoiceData,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final doc = pw.Document();

    // Obtener configuración de la empresa
    final configService = CompanyConfigService();
    final companyConfig = await configService.getCompanyConfig();

    // Obtener nombre del usuario
    final userName = await UserService.getUserDisplayName();

    // Cargar logo si existe
    pw.ImageProvider? logo;
    try {
      final logoUrl = companyConfig?['logoUrl'] as String?;
      if (logoUrl != null && logoUrl.isNotEmpty) {
        logo = await networkImage(logoUrl);
      }
    } catch (e) {
      debugPrint('Error cargando logo: $e');
    }

    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(0), // Sin márgenes para control total
        build: (context) {
          return pw.Stack(
            children: template.map((element) {
              return pw.Positioned(
                left: element.x,
                top: element.y,
                child: _buildPdfElement(
                  element,
                  invoiceData,
                  companyConfig,
                  userName,
                  logo,
                ),
              );
            }).toList(),
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildPdfElement(
    PdfElement element,
    Map<String, dynamic> invoiceData,
    Map<String, dynamic>? companyConfig,
    String userName,
    pw.ImageProvider? logo,
  ) {
    switch (element.type) {
      case 'text':
        return _buildTextElement(element);

      case 'logo':
        return _buildLogoElement(element, logo);

      case 'line':
        return _buildLineElement(element);

      case 'rectangle':
        return _buildRectangleElement(element);

      case 'invoice_number':
        return _buildDataElement(element, _getInvoiceNumber(invoiceData));

      case 'date':
        return _buildDataElement(element, _getInvoiceDate(invoiceData));

      case 'client':
        return _buildDataElement(element, _getClientName(invoiceData));

      case 'total':
        return _buildDataElement(element, _getTotalAmount(invoiceData));

      case 'company_name':
        return _buildDataElement(
          element,
          companyConfig?['razonSocial'] ?? 'Nombre de la Empresa',
        );

      case 'company_rnc':
        return _buildDataElement(
          element,
          'RNC: ${companyConfig?['rnc'] ?? '000000000'}',
        );

      case 'company_address':
        return _buildDataElement(
          element,
          companyConfig?['direccion'] ?? 'Dirección de la empresa',
        );

      case 'company_phone':
        return _buildDataElement(
          element,
          'Tel: ${companyConfig?['telefono'] ?? '000-000-0000'}',
        );

      case 'products_table':
        return _buildProductsTable(element, invoiceData);

      case 'totals_table':
        return _buildTotalsTable(element, invoiceData);

      default:
        return _buildTextElement(element);
    }
  }

  static pw.Widget _buildTextElement(PdfElement element) {
    return pw.Text(
      element.content,
      style: pw.TextStyle(
        fontSize: element.fontSize,
        fontWeight: element.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: PdfColor.fromInt(element.color.value),
      ),
    );
  }

  static pw.Widget _buildLogoElement(
    PdfElement element,
    pw.ImageProvider? logo,
  ) {
    if (logo != null) {
      return pw.Container(
        width: element.width,
        height: element.height,
        child: pw.Image(logo, fit: pw.BoxFit.contain),
      );
    } else {
      return pw.Container(
        width: element.width,
        height: element.height,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
          borderRadius: pw.BorderRadius.circular(element.borderRadius),
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
      );
    }
  }

  static pw.Widget _buildLineElement(PdfElement element) {
    return pw.Container(
      width: element.width,
      height: 2,
      color: PdfColor.fromInt(element.color.value),
    );
  }

  static pw.Widget _buildRectangleElement(PdfElement element) {
    return pw.Container(
      width: element.width,
      height: element.height,
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(element.backgroundColor.value),
        border: pw.Border.all(color: PdfColor.fromInt(element.color.value)),
        borderRadius: pw.BorderRadius.circular(element.borderRadius),
      ),
    );
  }

  static pw.Widget _buildDataElement(PdfElement element, String data) {
    // Reemplazar placeholders en el contenido
    String content = element.content;
    content = content.replaceAll('{invoice_number}', data);
    content = content.replaceAll('{date}', data);
    content = content.replaceAll('{client_name}', data);
    content = content.replaceAll('{total}', data);
    content = content.replaceAll('{company_name}', data);
    content = content.replaceAll('{company_rnc}', data);
    content = content.replaceAll('{company_address}', data);
    content = content.replaceAll('{company_phone}', data);

    return pw.Text(
      content,
      style: pw.TextStyle(
        fontSize: element.fontSize,
        fontWeight: element.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: PdfColor.fromInt(element.color.value),
      ),
    );
  }

  static pw.Widget _buildProductsTable(
    PdfElement element,
    Map<String, dynamic> invoiceData,
  ) {
    // Construir tabla de productos simplificada
    return pw.Container(
      width: element.width,
      height: element.height,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        children: [
          // Header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF4CAF50)),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    'Descripción',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'Cantidad',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'Precio',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'Total',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Filas de ejemplo (aquí integrarías con los datos reales)
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Productos de la factura...',
                style: pw.TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalsTable(
    PdfElement element,
    Map<String, dynamic> invoiceData,
  ) {
    return pw.Container(
      width: element.width,
      height: element.height,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        children: [
          _buildTotalRow('Subtotal', _getSubtotal(invoiceData)),
          _buildTotalRow('ITBIS', _getITBIS(invoiceData)),
          _buildTotalRow('Total', _getTotalAmount(invoiceData)),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  // Métodos para extraer datos de la factura
  static String _getInvoiceNumber(Map<String, dynamic> invoiceData) {
    return invoiceData['NumeroFacturaInterna']?.toString() ?? 'F-001';
  }

  static String _getInvoiceDate(Map<String, dynamic> invoiceData) {
    final dateStr = invoiceData['FechaEmision'] as String?;
    if (dateStr != null && dateStr.isNotEmpty && dateStr != '#e') {
      try {
        if (dateStr.contains('/')) {
          return dateStr; // Ya está en formato DD/MM/YYYY
        }
      } catch (e) {
        // Si hay error, usar fecha actual
      }
    }
    return DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  static String _getClientName(Map<String, dynamic> invoiceData) {
    return invoiceData['NombrePaciente']?.toString() ?? 'Cliente';
  }

  static String _getTotalAmount(Map<String, dynamic> invoiceData) {
    final total =
        double.tryParse(invoiceData['MontoTotal']?.toString() ?? '0') ?? 0;
    return '\$${total.toStringAsFixed(2)}';
  }

  static String _getSubtotal(Map<String, dynamic> invoiceData) {
    final subtotal =
        double.tryParse(invoiceData['SubTotal']?.toString() ?? '0') ?? 0;
    return '\$${subtotal.toStringAsFixed(2)}';
  }

  static String _getITBIS(Map<String, dynamic> invoiceData) {
    final itbis = double.tryParse(invoiceData['ITBIS']?.toString() ?? '0') ?? 0;
    return '\$${itbis.toStringAsFixed(2)}';
  }
}
