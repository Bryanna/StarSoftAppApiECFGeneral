import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'pdf_element.dart';

/// Portable template-based PDF generator.
/// Renders positioned elements on the page using a provided template.
class CustomPdfServicePortable {
  static Future<Uint8List> generate({
    required List<PdfElement> template,
    required Map<String, dynamic> data,
    PdfPageFormat format = PdfPageFormat.a4,
    Map<String, dynamic>? companyConfig,
    String? userDisplayName,
    String? logoUrl,
    Uint8List? logoBytes,
  }) async {
    final doc = pw.Document();

    // Resolve logo
    pw.ImageProvider? logo;
    try {
      if (logoBytes != null) {
        logo = pw.MemoryImage(logoBytes);
      } else {
        final url = logoUrl ?? companyConfig?['logoUrl'];
        if (url is String && url.isNotEmpty) {
          logo = await networkImage(url);
        }
      }
    } catch (_) {
      logo = null;
    }

    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(0),
        build: (context) {
          return pw.Stack(
            children: template.map((el) => pw.Positioned(
              left: el.x,
              top: el.y,
              child: _buildElement(el, data, companyConfig, userDisplayName, logo),
            )).toList(),
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildElement(
    PdfElement el,
    Map<String, dynamic> data,
    Map<String, dynamic>? company,
    String? userDisplayName,
    pw.ImageProvider? logo,
  ) {
    switch (el.type) {
      case PdfElementType.text:
        final raw = el.text ?? '';
        final resolved = _resolvePlaceholders(raw, data, company, userDisplayName);
        return pw.Container(
          width: el.width,
          height: el.height,
          decoration: _boxDecoration(el),
          child: _text(resolved, el),
        );
      case PdfElementType.logo:
        return pw.Container(
          width: el.width,
          height: el.height,
          decoration: _boxDecoration(el),
          child: (logo != null)
              ? pw.Image(logo, fit: pw.BoxFit.contain)
              : pw.Center(
                  child: pw.Text(
                    'LOGO',
                    style: pw.TextStyle(
                      fontSize: (el.fontSize ?? 14),
                      fontWeight: el.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                      color: _parseColor(el.color) ?? PdfColors.grey600,
                    ),
                  ),
                ),
        );
      case PdfElementType.line:
        return pw.Container(
          width: el.width,
          height: el.height,
          decoration: pw.BoxDecoration(
            color: _parseColor(el.color) ?? PdfColors.grey400,
          ),
        );
      case PdfElementType.rect:
        return pw.Container(
          width: el.width,
          height: el.height,
          decoration: _boxDecoration(el),
        );
    }
  }

  static pw.Text _text(String value, PdfElement el) {
    pw.TextAlign align = pw.TextAlign.left;
    switch (el.align?.toLowerCase()) {
      case 'center':
        align = pw.TextAlign.center;
        break;
      case 'right':
        align = pw.TextAlign.right;
        break;
      default:
        align = pw.TextAlign.left;
    }
    return pw.Text(
      value,
      textAlign: align,
      style: pw.TextStyle(
        fontSize: el.fontSize ?? 12,
        fontWeight: el.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: _parseColor(el.color) ?? PdfColors.black,
      ),
    );
  }

  static pw.BoxDecoration _boxDecoration(PdfElement el) {
    return pw.BoxDecoration(
      color: _parseColor(el.backgroundColor),
      borderRadius: pw.BorderRadius.circular(el.borderRadius),
      border: el.borderWidth > 0
          ? pw.Border.all(
              color: _parseColor(el.borderColor) ?? PdfColors.grey400,
              width: el.borderWidth,
            )
          : null,
    );
  }

  static PdfColor? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final h = hex.replaceAll('#', '').trim();
    if (h.length == 6) {
      final v = int.tryParse(h, radix: 16);
      if (v != null) return PdfColor.fromInt(0xFF000000 | v);
    } else if (h.length == 8) {
      final v = int.tryParse(h, radix: 16);
      if (v != null) return PdfColor.fromInt(v);
    }
    return null;
  }

  static String _resolvePlaceholders(
    String input,
    Map<String, dynamic> data,
    Map<String, dynamic>? company,
    String? userDisplayName,
  ) {
    String out = input;
    Map<String, dynamic> ctx = {
      ...data,
      'company.razonSocial': company?['razonSocial'],
      'company.rnc': company?['rnc'],
      'company.telefono': company?['telefono'],
      'company.direccion': company?['direccion'],
      'user.displayName': userDisplayName,
    }..removeWhere((key, value) => value == null);

    // Replace {key} occurrences
    ctx.forEach((key, value) {
      out = out.replaceAll('{$key}', _toString(value));
    });
    return out;
  }

  static String _toString(dynamic v) {
    if (v == null) return '';
    if (v is num) {
      final fmt = NumberFormat.currency(symbol: '', decimalDigits: 2, locale: 'es_DO');
      return fmt.format(v);
    }
    return v.toString();
  }
}