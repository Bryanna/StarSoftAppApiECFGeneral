import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/invoice.dart';
import '../models/invoice_extensions.dart';
import '../models/tipo_comprobante.dart';
import '../services/company_config_service.dart';
import '../services/fake_data_service.dart';
import '../services/user_service.dart';

class EnhancedInvoicePdfService {
  static Future<Uint8List> buildPdf(
    PdfPageFormat format,
    dynamic invoice,
  ) async {
    // DEBUG: Confirmar que estamos usando la versión actualizada
    debugPrint('');
    debugPrint('🚀🚀🚀 ENHANCED PDF SERVICE - VERSION UPDATED 🚀🚀🚀');
    debugPrint('🚀 This should show RNC/CED instead of Record');
    debugPrint(
      '🚀 This should use tipo_factura_titulo instead of CONTADO - LABORATORIO',
    );
    debugPrint('');

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

    // Pre-cargar el nombre del usuario logueado
    final userName = await UserService.getUserDisplayName();

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
              // Título pequeño con el tipo de comprobante
              // _buildComprobanteTitle(invoiceData),
              // pw.SizedBox(height: 6),
              // Header con logo y datos de la empresa
              _buildHeader(logo, companyData, invoiceData),

              pw.SizedBox(height: 20),

              // Tabla de productos/servicios
              _buildProductsTableSync(invoiceData, useFakeData, productRows),

              pw.Spacer(),

              // Footer con QR y totales
              _buildFooterSync(invoiceData, useFakeData, userName),
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
                _getTipoFacturaTitulo(invoiceData),
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
                    fontSize: 12,
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
                  _buildCompactInfoRow('RNC/CED', _getRecord(invoiceData)),
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

  // Título de comprobante arriba del todo, centrado y pequeño
  static pw.Widget _buildComprobanteTitle(dynamic invoiceData) {
    final doc = _extractDocumento(invoiceData);
    final code = _extractTipoCodeFromDoc(doc);
    final desc = _getTipoComprobanteDescripcion(invoiceData);
    final text = (code?.isNotEmpty ?? false)
        ? 'eCF ${code!} — ${desc ?? ''}'
        : (desc ?? '');

    if (text.isEmpty) return pw.SizedBox.shrink();

    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  // Extraer ENCF/FDocumento del invoice
  static String? _extractDocumento(dynamic invoiceData) {
    try {
      if (invoiceData is Datum) {
        return invoiceData.fDocumento ?? invoiceData.encf;
      }
      if (invoiceData is Map<String, dynamic>) {
        return (invoiceData['ENCF'] as String?) ??
            (invoiceData['FDocumento'] as String?) ??
            (invoiceData['NumeroFacturaInterna'] as String?);
      }
    } catch (_) {}
    return null;
  }

  // Obtener la descripción o alias desde tipo_comprobante.dart
  static String? _getTipoComprobanteDescripcion(dynamic invoiceData) {
    final doc = _extractDocumento(invoiceData);
    if (doc == null || doc.isEmpty) return null;
    final desc = descripcionDesdeDocumento(doc);
    if (desc != null) return desc;
    final alias = aliasDesdeDocumento(doc);
    if (alias != null && alias.isNotEmpty) return alias;
    return null;
  }

  // Intentar extraer NN de patrones E NN o inicio de cadena
  static String? _extractTipoCodeFromDoc(String? doc) {
    if (doc == null || doc.isEmpty) return null;
    final m = RegExp(r'[Ee]\s*(\d{2})').firstMatch(doc);
    if (m != null) return m.group(1);
    final m2 = RegExp(r'^(\d{2})').firstMatch(doc);
    if (m2 != null) return m2.group(1);
    return null;
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

        // Fila de totales - debe coincidir con las columnas del header
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
          ),
          child: pw.Row(
            children: [
              // ID (flex: 1)
              _buildTableCell('', flex: 1, bold: true),
              // Descripción (flex: 4) - aquí va el conteo de items
              _buildTableCell(
                'Items: ${productRows.length}',
                flex: 4,
                bold: true,
                align: pw.TextAlign.left,
              ),
              // Cantidad (flex: 1)
              _buildTableCell('', flex: 1, bold: true),
              // Precio (flex: 1)
              _buildTableCell('', flex: 1, bold: true),
              // Importe (flex: 1) - suma total de todos los items
              _buildTableCell(
                _getTotalImporte(invoiceData),
                flex: 1,
                bold: true,
                align: pw.TextAlign.right,
              ),
              // Cobertura (flex: 1) - descuento/cobertura aplicada
              _buildTableCell(
                _getCoverageAmount(invoiceData),
                flex: 1,
                bold: true,
                align: pw.TextAlign.right,
              ),
              // Neto / Pagar (flex: 1) - importe total menos cobertura total
              _buildTableCell(
                _getNetAmount(invoiceData, useFakeData),
                flex: 1,
                bold: true,
                align: pw.TextAlign.right,
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
    debugPrint('');
    debugPrint('🔍 [EnhancedInvoicePdfService] _getProductRows called');
    debugPrint('🔍 invoiceData type: ${invoiceData.runtimeType}');
    debugPrint('🔍 useFakeData: $useFakeData');

    // Primero, intentar extraer detalles reales del campo detalle_factura
    try {
      if (invoiceData is Map<String, dynamic>) {
        debugPrint('🔍 Processing Map invoiceData');
        debugPrint('🔍 Available keys: ${invoiceData.keys.toList()}');

        // Buscar el campo detalle_factura en el Map
        final detalleFacturaJson =
            invoiceData['DetalleFactura'] as String? ??
            invoiceData['detalleFactura'] as String? ??
            invoiceData['detalle_factura'] as String?;

        debugPrint(
          '🔍 DetalleFactura field: ${detalleFacturaJson?.substring(0, detalleFacturaJson.length > 100 ? 100 : detalleFacturaJson.length) ?? 'NULL'}...',
        );

        if (detalleFacturaJson != null && detalleFacturaJson.isNotEmpty) {
          debugPrint(
            '[EnhancedInvoicePdfService] ✓ Found detalle_factura JSON: ${detalleFacturaJson.substring(0, detalleFacturaJson.length > 200 ? 200 : detalleFacturaJson.length)}...',
          );

          try {
            final List<dynamic> detalles = json.decode(detalleFacturaJson);
            debugPrint(
              '[EnhancedInvoicePdfService] ✓ Parsed ${detalles.length} invoice details - RETURNING REAL DETAILS',
            );

            // Debug de totales
            double totalImporte = 0.0;
            double totalCobertura = 0.0;
            for (final detalle in detalles) {
              final total =
                  double.tryParse(detalle['total']?.toString() ?? '0') ?? 0.0;
              final cobertura =
                  double.tryParse(detalle['cobertura']?.toString() ?? '0') ??
                  0.0;
              totalImporte += total;
              totalCobertura += cobertura;
            }
            final neto = totalImporte - totalCobertura;

            debugPrint('💰 TOTALES DEBUG:');
            debugPrint(
              '💰 Total Importe (suma items): ${_formatMoney(totalImporte)}',
            );
            debugPrint(
              '💰 Total Cobertura (suma coberturas): ${_formatMoney(totalCobertura)}',
            );
            debugPrint(
              '💰 Neto a Pagar (importe - cobertura): ${_formatMoney(neto)}',
            );

            final rows = detalles.asMap().entries.map((entry) {
              final index = entry.key;
              final detalle = entry.value as Map<String, dynamic>;

              final referencia =
                  detalle['referencia']?.toString() ?? (index + 1).toString();
              final descripcion =
                  detalle['descripcion']?.toString() ?? 'Servicio médico';
              final cantidad = detalle['cantidad']?.toString() ?? '1.00';
              final precioValue =
                  double.tryParse(detalle['precio']?.toString() ?? '0') ?? 0;
              final totalValue =
                  double.tryParse(detalle['total']?.toString() ?? '0') ?? 0;
              final coberturaValue =
                  double.tryParse(detalle['cobertura']?.toString() ?? '0') ?? 0;
              final netoValue = totalValue - coberturaValue;

              final precio = _formatMoney(precioValue);
              final total = _formatMoney(totalValue);
              final cobertura = _formatMoney(coberturaValue);
              final neto = _formatMoney(netoValue);

              debugPrint(
                '[EnhancedInvoicePdfService] ✓ Creating row ${index + 1}: [$referencia] $descripcion',
              );
              debugPrint(
                '  💰 Precio: $precio, Total: $total, Cobertura: $cobertura, Neto: $neto',
              );

              return _buildProductRow(
                referencia, // Usar referencia como ID
                descripcion,
                cantidad,
                precio,
                total, // Importe
                cobertura, // Cobertura del item
                neto, // Neto = total - cobertura
              );
            }).toList();

            debugPrint(
              '[EnhancedInvoicePdfService] ✓ RETURNING ${rows.length} REAL DETAIL ROWS',
            );
            return rows;
          } catch (e) {
            debugPrint(
              '[EnhancedInvoicePdfService] ✗ Error parsing detalle_factura JSON: $e',
            );
          }
        } else {
          debugPrint('❌ No detalle_factura found or empty');
          debugPrint(
            '❌ DetalleFactura value: ${invoiceData['DetalleFactura']}',
          );
          debugPrint(
            '❌ detalleFactura value: ${invoiceData['detalleFactura']}',
          );
          debugPrint(
            '❌ detalle_factura value: ${invoiceData['detalle_factura']}',
          );
        }
      }

      // Fallback para datos fake
      if (invoiceData is Datum) {
        final items = await FakeDataService.getProductDetailsForInvoice(
          invoiceData,
        );
        if (items.isNotEmpty) {
          return items.map((product) {
            final precio = _formatMoney(
              double.tryParse(product['precio'] ?? '0') ?? 0,
            );
            final cantidad = product['cantidad']?.toString() ?? '1.00';
            final monto = _formatMoney(
              double.tryParse(product['monto'] ?? '0') ?? 0,
            );
            final id = (product['linea'] ?? product['id'] ?? '1').toString();
            return _buildProductRow(
              id,
              product['nombre'] ?? 'Producto/Servicio',
              cantidad,
              precio,
              monto,
              '0.00',
              monto,
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint(
        '[EnhancedInvoicePdfService] Error extracting per-invoice items: $e',
      );
    }

    // Si el invoice es un Map (escenario JSON), extraer directamente
    if (invoiceData is Map) {
      final List<pw.Widget> rows = [];
      for (int i = 1; i <= 50; i++) {
        final nombreKey = 'NombreItem[$i]';
        final cantidadKey = 'CantidadItem[$i]';
        final precioKey = 'PrecioUnitarioItem[$i]';
        final montoKey = 'MontoItem[$i]';
        if (invoiceData.containsKey(nombreKey) &&
            invoiceData[nombreKey] != null &&
            invoiceData[nombreKey] != '#e') {
          final precio = _formatMoney(
            double.tryParse(invoiceData[precioKey] ?? '0') ?? 0,
          );
          final cantidad = (invoiceData[cantidadKey] ?? '1.00').toString();
          final monto = _formatMoney(
            double.tryParse(invoiceData[montoKey] ?? '0') ?? 0,
          );
          final lineaKey = 'NumeroLinea[$i]';
          final id = (invoiceData[lineaKey] ?? i.toString()).toString();
          rows.add(
            _buildProductRow(
              id,
              invoiceData[nombreKey] ?? 'Producto/Servicio',
              cantidad,
              precio,
              monto,
              '0.00',
              monto,
            ),
          );
        }
      }
      if (rows.isNotEmpty) return rows;
    }

    // Fallback: NO usar catálogo general para evitar confusión entre facturas.
    // Si no hay ítems reales, muestra una sola línea con el total de la factura.

    // Último recurso: una sola línea con el total
    debugPrint('');
    debugPrint('❌❌❌ FALLBACK: Using generic single row');
    debugPrint('❌ This means no real details were found');
    debugPrint(
      '❌ Check if you are using FAKE DATA or ERP is not sending detalle_factura',
    );
    debugPrint('');
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
          _buildTableCell(id, flex: 1, align: pw.TextAlign.center),
          _buildTableCell(description, flex: 4, align: pw.TextAlign.left),
          _buildTableCell(quantity, flex: 1, align: pw.TextAlign.right),
          _buildTableCell(price, flex: 1, align: pw.TextAlign.right),
          _buildTableCell(amount, flex: 1, align: pw.TextAlign.right),
          _buildTableCell(coverage, flex: 1, align: pw.TextAlign.right),
          _buildTableCell(net, flex: 1, align: pw.TextAlign.right),
        ],
      ),
    );
  }

  static pw.Widget _buildFooterSync(
    dynamic invoiceData,
    bool useFakeData,
    String userName,
  ) {
    final qrUrl = _getQRUrl(invoiceData);

    // Debug: mostrar si se encontró URL para QR
    if (qrUrl.isNotEmpty) {
      debugPrint('[EnhancedInvoicePdfService] QR URL encontrado: $qrUrl');
    } else {
      debugPrint('[EnhancedInvoicePdfService] No se encontró URL para QR');
    }

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        // QR Code (lado izquierdo) - solo si hay URL
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            children: [
              // QR Code o espacio vacío
              if (qrUrl.isNotEmpty)
                pw.Container(
                  width: 100,
                  height: 100,
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: qrUrl,
                  ),
                )
              else
                pw.SizedBox(width: 100, height: 100),

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
              pw.Text(userName, style: pw.TextStyle(fontSize: 8)),
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
                      _getCoverageAmount(invoiceData),
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
    pw.TextAlign align = pw.TextAlign.center,
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
          textAlign: align,
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
    if (invoice is Map) {
      final numeroFactura = invoice['NumeroFacturaInterna'] ?? '';
      debugPrint('📄 PDF Invoice Number: $numeroFactura');
      return numeroFactura;
    }
    if (invoice is Datum) return invoice.fDocumento ?? '';
    return '';
  }

  static String _getInvoiceDate(dynamic invoice) {
    // Usar FechaEmision del JSON
    if (invoice is Map) {
      final dateStr = invoice['FechaEmision'] as String?;
      debugPrint('📅 _getInvoiceDate received: "$dateStr"');

      if (dateStr != null && dateStr != '#e' && dateStr.isNotEmpty) {
        try {
          // Intentar formato DD/MM/YYYY (como viene del ERP)
          if (dateStr.contains('/')) {
            final parts = dateStr.split('/');
            if (parts.length == 3) {
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);
              final date = DateTime(year, month, day);
              final formatted = DateFormat('dd/MM/yyyy').format(date);
              debugPrint('📅 Formatted date (from /): $formatted');
              return formatted;
            }
          }

          // Fallback: formato DD-MM-YYYY
          if (dateStr.contains('-')) {
            final parts = dateStr.split('-');
            if (parts.length == 3) {
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);
              final date = DateTime(year, month, day);
              final formatted = DateFormat('dd/MM/yyyy').format(date);
              debugPrint('📅 Formatted date (from -): $formatted');
              return formatted;
            }
          }

          // Si no se puede parsear, devolver tal como viene
          debugPrint('📅 Could not parse date, returning as-is: $dateStr');
          return dateStr;
        } catch (e) {
          debugPrint('📅 Error parsing date: $e, returning as-is: $dateStr');
          return dateStr;
        }
      }
      debugPrint('📅 Date is null/empty, returning empty');
      return '';
    }
    if (invoice is Datum) {
      final date = invoice.fechaemisionDateTime;
      return date != null ? DateFormat('dd/MM/yyyy').format(date) : '';
    }
    return '';
  }

  static String _getECF(dynamic invoice) {
    // Usar ENCF del JSON
    if (invoice is Map) return invoice['ENCF'] ?? '';
    if (invoice is Datum) return invoice.encf ?? '';
    return '';
  }

  static String _getProductDescription(dynamic invoice) {
    if (invoice == null) return 'Servicios médicos';
    return 'Servicios de laboratorio clínico';
  }

  static String _getUnitPrice(dynamic invoice) {
    if (invoice is Map) return _formatMoney(invoice['total'] ?? 0);
    if (invoice is Datum) {
      final total = _toNum(invoice.montototal) ?? _toNum(invoice.fTotal) ?? 0;
      return _formatMoney(total);
    }
    return '0.00';
  }

  static String _getTotalPrice(dynamic invoice) {
    return _getUnitPrice(invoice);
  }

  static String _getTotalAmount(dynamic invoice, bool useFakeData) {
    // Usar MontoTotal del JSON (total final a pagar)
    if (invoice is Map) {
      final montoStr = invoice['MontoTotal'] as String?;
      if (montoStr != null && montoStr != '#e') {
        final monto = double.tryParse(montoStr) ?? 0;
        return _formatMoney(monto);
      }
      return '0.00';
    }
    if (invoice is Datum) {
      final total = _toNum(invoice.montototal) ?? _toNum(invoice.fTotal) ?? 0;
      return _formatMoney(total);
    }
    return '0.00';
  }

  // Nuevo método: Total de importes (suma de todos los items del detalle)
  static String _getTotalImporte(dynamic invoice) {
    if (invoice is Map) {
      final detalleJson =
          invoice['DetalleFactura'] as String? ??
          invoice['detalleFactura'] as String? ??
          invoice['detalle_factura'] as String?;

      if (detalleJson != null && detalleJson.isNotEmpty) {
        try {
          final List<dynamic> detalles = json.decode(detalleJson);
          double totalImporte = 0.0;
          for (final detalle in detalles) {
            final total =
                double.tryParse(detalle['total']?.toString() ?? '0') ?? 0.0;
            totalImporte += total;
          }
          return _formatMoney(totalImporte);
        } catch (e) {
          debugPrint('[PDF] Error calculating total importe: $e');
        }
      }
    }
    return _getTotalAmount(invoice, false); // Fallback
  }

  static String _getCoverageAmount(dynamic invoice) {
    if (invoice is Map) {
      // Primero intentar usar monto_cobertura del ERP
      final montoCobertura = invoice['monto_cobertura'] as String?;
      if (montoCobertura != null && montoCobertura.isNotEmpty) {
        final cobertura = double.tryParse(montoCobertura) ?? 0.0;
        return _formatMoney(cobertura);
      }

      // Fallback: calcular desde los detalles
      final detalleJson =
          invoice['DetalleFactura'] as String? ??
          invoice['detalleFactura'] as String? ??
          invoice['detalle_factura'] as String?;

      if (detalleJson != null && detalleJson.isNotEmpty) {
        try {
          // Calcular total de importes y cobertura
          final List<dynamic> detalles = json.decode(detalleJson);
          double totalImporte = 0.0;
          double totalCobertura = 0.0;

          for (final detalle in detalles) {
            final total =
                double.tryParse(detalle['total']?.toString() ?? '0') ?? 0.0;
            final cobertura =
                double.tryParse(detalle['cobertura']?.toString() ?? '0') ?? 0.0;
            totalImporte += total;
            totalCobertura += cobertura;
          }

          // Si hay cobertura en los detalles, usarla
          if (totalCobertura > 0) {
            return _formatMoney(totalCobertura);
          }

          // Sino, calcular diferencia (Importe Total - Monto a Pagar)
          final montoStr = invoice['MontoTotal'] as String?;
          final montoPagar = double.tryParse(montoStr ?? '0') ?? 0.0;
          final cobertura = totalImporte - montoPagar;
          return _formatMoney(cobertura > 0 ? cobertura : 0.0);
        } catch (e) {
          debugPrint('[PDF] Error calculating coverage: $e');
        }
      }
    }
    return '0.00';
  }

  static String _getNetAmount(dynamic invoice, bool useFakeData) {
    // El neto debe ser Importe Total - Cobertura Total
    if (invoice is Map) {
      final detalleJson =
          invoice['DetalleFactura'] as String? ??
          invoice['detalleFactura'] as String? ??
          invoice['detalle_factura'] as String?;

      if (detalleJson != null && detalleJson.isNotEmpty) {
        try {
          final List<dynamic> detalles = json.decode(detalleJson);
          double totalImporte = 0.0;
          double totalCobertura = 0.0;

          for (final detalle in detalles) {
            final total =
                double.tryParse(detalle['total']?.toString() ?? '0') ?? 0.0;
            final cobertura =
                double.tryParse(detalle['cobertura']?.toString() ?? '0') ?? 0.0;
            totalImporte += total;
            totalCobertura += cobertura;
          }

          final neto = totalImporte - totalCobertura;
          debugPrint(
            '💰 Net calculation: $totalImporte - $totalCobertura = $neto',
          );
          return _formatMoney(neto);
        } catch (e) {
          debugPrint('[PDF] Error calculating net amount: $e');
        }
      }
    }

    // Fallback: usar el monto total de la factura
    return _getTotalAmount(invoice, useFakeData);
  }

  static String _getTotalClinico(dynamic invoice, bool useFakeData) {
    // Total Clínico = Cobertura + Total Gral (Neto a Pagar)
    if (invoice is Map) {
      final detalleJson =
          invoice['DetalleFactura'] as String? ??
          invoice['detalleFactura'] as String? ??
          invoice['detalle_factura'] as String?;

      if (detalleJson != null && detalleJson.isNotEmpty) {
        try {
          final List<dynamic> detalles = json.decode(detalleJson);
          double totalImporte = 0.0;
          double totalCobertura = 0.0;

          for (final detalle in detalles) {
            final total =
                double.tryParse(detalle['total']?.toString() ?? '0') ?? 0.0;
            final cobertura =
                double.tryParse(detalle['cobertura']?.toString() ?? '0') ?? 0.0;
            totalImporte += total;
            totalCobertura += cobertura;
          }

          // Total Clínico = Total Importe (que es Cobertura + Neto)
          debugPrint(
            '💰 Total Clínico calculation: Total Importe = $totalImporte',
          );
          return _formatMoney(totalImporte);
        } catch (e) {
          debugPrint('[PDF] Error calculating total clínico: $e');
        }
      }
    }

    // Fallback
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
    if (invoice is Datum) {
      final itbis = _toNum(invoice.totalitbis) ?? _toNum(invoice.fItbis) ?? 0;
      return _formatMoney(itbis);
    }
    return '0.00';
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
    if (invoice is Datum) return invoice.codigoSeguridad ?? '';
    return '';
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
    if (invoice is Datum) {
      final date = invoice.fechaHoraFirma ?? invoice.fechaemisionDateTime;
      return date != null ? DateFormat('dd/MM/yy').format(date) : '';
    }
    return '';
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
    // Usar no_autorizacion del JSON
    if (invoice is Map) return invoice['no_autorizacion'] ?? '';
    return '';
  }

  static String _getInsurance(dynamic invoice) {
    // Usar aseguradora del JSON
    if (invoice is Map) return invoice['aseguradora'] ?? '';
    return '';
  }

  static String _getNSS(dynamic invoice) {
    // Usar nss del JSON
    if (invoice is Map) return invoice['nss'] ?? '';
    return '';
  }

  static String _getDoctor(dynamic invoice) {
    // Usar medico del JSON
    if (invoice is Map) return invoice['medico'] ?? '';
    return '';
  }

  // static String _getRecord(dynamic invoice) {
  //   // No existe en el JSON real, siempre vacío
  //   return '';
  // }

  static String _getPatientName(dynamic invoice) {
    // Usar RazonSocialComprador del JSON
    if (invoice is Map) return invoice['RazonSocialComprador'] ?? '';
    if (invoice is Datum) {
      // razonsocialcomprador es un enum, necesitamos convertirlo a string
      final razon = invoice.razonsocialcomprador;
      if (razon != null) {
        return razonsocialcompradorValues.reverse[razon] ?? '';
      }
    }
    return '';
  }

  static String _getRecord(dynamic invoice) {
    // Usar cedula_medico del JSON para RNC/CED
    if (invoice is Map) return invoice['cedula_medico'] ?? '';
    return '';
  }

  static String _getTipoFacturaTitulo(dynamic invoice) {
    // Usar tipo_factura_titulo del JSON
    if (invoice is Map) {
      final tipo = invoice['tipo_factura_titulo'] as String?;
      debugPrint('🏷️ _getTipoFacturaTitulo received: "$tipo"');
      debugPrint('🏷️ Available keys: ${invoice.keys.toList()}');

      if (tipo != null && tipo.trim().isNotEmpty) {
        final result = tipo.trim();
        debugPrint('🏷️ Using tipo_factura_titulo: "$result"');
        return result;
      } else {
        debugPrint('🏷️ tipo_factura_titulo is null/empty, using fallback');
        return 'CONTADO - LABORATORIO';
      }
    }
    debugPrint('🏷️ Invoice is not Map, using fallback');
    return 'CONTADO - LABORATORIO';
  }

  static String _getQRUrl(dynamic invoice) {
    // Debug: mostrar el tipo de invoice y algunos campos
    debugPrint(
      '[EnhancedInvoicePdfService] _getQRUrl - invoice type: ${invoice.runtimeType}',
    );

    if (invoice is Map) {
      // Debug: mostrar las claves disponibles
      debugPrint(
        '[EnhancedInvoicePdfService] Available keys: ${invoice.keys.toList()}',
      );

      // Buscar en cada campo y hacer debug
      final linkOriginal = invoice['linkOriginal'] as String?;
      final linkOriginalUnderscore = invoice['link_original'] as String?;
      final xmlPublicUrl = invoice['xmlPublicUrl'] as String?;

      debugPrint('[EnhancedInvoicePdfService] linkOriginal: $linkOriginal');
      debugPrint(
        '[EnhancedInvoicePdfService] link_original: $linkOriginalUnderscore',
      );
      debugPrint('[EnhancedInvoicePdfService] xmlPublicUrl: $xmlPublicUrl');

      // Campos comunes donde puede venir el URL del QR
      return linkOriginal ??
          linkOriginalUnderscore ??
          xmlPublicUrl ??
          (invoice['qrUrl'] as String?) ??
          (invoice['urlQR'] as String?) ??
          (invoice['qrLink'] as String?) ??
          '';
    }
    if (invoice is Datum) {
      final url = invoice.linkOriginal ?? '';
      debugPrint('[EnhancedInvoicePdfService] Datum linkOriginal: $url');
      return url;
    }
    debugPrint(
      '[EnhancedInvoicePdfService] Unknown invoice type, returning empty',
    );
    return '';
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
