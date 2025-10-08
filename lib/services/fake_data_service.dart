import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/invoice.dart';

class FakeDataService {
  static List<Map<String, dynamic>>? _cachedTipos;
  static Map<String, dynamic>? _cachedResponse;

  /// Carga los datos de ejemplos desde el JSON
  static Future<List<Map<String, dynamic>>> loadTiposData() async {
    if (_cachedTipos != null) return _cachedTipos!;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/ejemplos.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> results = jsonData['data']['results'];
      _cachedTipos = results.cast<Map<String, dynamic>>();

      debugPrint(
        '[FakeDataService] Loaded ${_cachedTipos!.length} example records',
      );
      return _cachedTipos!;
    } catch (e) {
      debugPrint('[FakeDataService] Error loading ejemplos.json: $e');
      return [];
    }
  }

  /// Carga los datos de respuesta desde el JSON
  static Future<Map<String, dynamic>?> loadResponseData() async {
    if (_cachedResponse != null) return _cachedResponse!;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/response.json',
      );
      _cachedResponse = json.decode(jsonString);

      debugPrint('[FakeDataService] Loaded response data successfully');
      return _cachedResponse!;
    } catch (e) {
      debugPrint('[FakeDataService] Error loading response.json: $e');
      return null;
    }
  }

  /// Convierte los datos JSON a objetos Datum
  static Future<List<Datum>> generateFakeInvoicesFromJson() async {
    final tiposData = await loadTiposData();
    final List<Datum> invoices = [];

    for (int i = 0; i < tiposData.length; i++) {
      final data = tiposData[i];
      final now = DateTime.now();

      try {
        final invoice = Datum(
          // Información básica
          encf: data['ENCF'] ?? '',
          fDocumento: data['NumeroFacturaInterna'] ?? data['ENCF'] ?? '',
          fechaemision:
              _parseDate(data['FechaEmision']) ??
              now.subtract(Duration(days: i + 1)),
          fechavencimientosecuencia:
              _parseDate(data['FechaVencimientoSecuencia']) ??
              now.add(const Duration(days: 30)),

          // Emisor
          rncemisor: data['RNCEmisor'] ?? '',
          razonsocialemisor: _parseRazonSocial(data['RazonSocialEmisor']),
          direccionemisor: _parseRazonSocial(data['DireccionEmisor']),

          // Comprador
          rnccomprador: data['RNCComprador'] ?? '',
          razonsocialcomprador: _parseRazonSocial(data['RazonSocialComprador']),
          direccioncomprador: data['DireccionComprador'] ?? '',

          // Montos
          montototal: _formatMoney(data['MontoTotal']),
          fSubtotal: _formatMoney(
            data['MontoGravadoTotal'] ?? data['MontoExento'],
          ),
          fItbis: _formatMoney(data['TotalITBIS']),
          fTotal: _formatMoney(data['MontoTotal']),

          // Tipo de comprobante
          tipoecf: data['TipoeCF']?.toString() ?? '',
          tipoComprobante: data['TipoeCF']?.toString() ?? '',

          // Estados simulados basados en el estatus del JSON
          fAnulada: data['estatus'] == 'Rechazado',
          fPagada: data['estatus'] == 'Aprobado',

          // Códigos de seguridad (simulados)
          codigoSeguridad: _generateSecurityCode(i),
          fechaHoraFirma: data['estatus'] != 'Pendiente'
              ? now.subtract(Duration(hours: i * 2))
              : null,

          // Secuencia
          fFacturaSecuencia: i + 1,
        );

        invoices.add(invoice);
      } catch (e) {
        debugPrint('[FakeDataService] Error processing record $i: $e');
        continue;
      }
    }

    debugPrint(
      '[FakeDataService] Generated ${invoices.length} fake invoices from ejemplos.json',
    );
    return invoices;
  }

  /// Genera facturas específicas para diferentes categorías
  static Future<List<Datum>> generateFakeInvoicesByCategory(
    String category,
  ) async {
    debugPrint('[FakeDataService] Generating invoices for category: $category');

    final allInvoices = await generateFakeInvoicesFromJson();
    debugPrint(
      '[FakeDataService] Total invoices loaded: ${allInvoices.length}',
    );

    List<Datum> result;
    switch (category.toLowerCase()) {
      case 'pacientes':
        result = allInvoices
            .where(
              (inv) =>
                  inv.encf?.startsWith('E31') == true ||
                  inv.encf?.startsWith('E32') == true,
            )
            .take(4)
            .toList();
        break;
      case 'ars':
        result = allInvoices.skip(2).take(3).toList();
        break;
      case 'enviados':
        result = allInvoices
            .where((inv) => inv.fechaHoraFirma != null)
            .toList();
        break;
      case 'notascredito':
        result = allInvoices
            .where((inv) => inv.encf?.startsWith('E43') == true)
            .toList();
        break;
      case 'notasdebito':
        result = allInvoices
            .where((inv) => inv.encf?.startsWith('E41') == true)
            .toList();
        break;
      case 'gastos':
        result = allInvoices
            .where((inv) => inv.encf?.startsWith('E45') == true)
            .toList();
        break;
      case 'rechazados':
        result = allInvoices.where((inv) => inv.fAnulada == true).toList();
        break;
      default:
        result = allInvoices;
    }

    debugPrint(
      '[FakeDataService] Returning ${result.length} invoices for category $category',
    );
    return result;
  }

  /// Obtiene datos detallados de productos desde el JSON
  static Future<List<Map<String, dynamic>>> getProductDetails() async {
    final tiposData = await loadTiposData();
    final List<Map<String, dynamic>> products = [];

    for (final data in tiposData) {
      // Extraer productos de cada factura
      for (int i = 1; i <= 20; i++) {
        final nombreKey = 'NombreItem[$i]';
        final cantidadKey = 'CantidadItem[$i]';
        final precioKey = 'PrecioUnitarioItem[$i]';
        final montoKey = 'MontoItem[$i]';

        if (data.containsKey(nombreKey) &&
            data[nombreKey] != null &&
            data[nombreKey] != '#e') {
          products.add({
            'id': i.toString(),
            'nombre': data[nombreKey],
            'cantidad': data[cantidadKey] ?? '1.0',
            'precio': data[precioKey] ?? '0.00',
            'monto': data[montoKey] ?? '0.00',
            'unidad': data['UnidadMedida[$i]'] ?? '43',
          });
        }
      }

      // Limitar a 50 productos para no sobrecargar
      if (products.length >= 50) break;
    }

    debugPrint(
      '[FakeDataService] Extracted ${products.length} product details',
    );
    return products;
  }

  // Métodos auxiliares
  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr == '#e') return null;

    try {
      // Formato esperado: "31-12-2025" o "02-04-2020"
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      debugPrint('[FakeDataService] Error parsing date: $dateStr');
    }

    return null;
  }

  static String _formatMoney(dynamic value) {
    if (value == null || value == '#e') return '0.00';

    if (value is String) {
      // Limpiar el string y convertir a número
      final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
      final number = double.tryParse(cleaned) ?? 0.0;
      return number.toStringAsFixed(2);
    }

    if (value is num) {
      return value.toStringAsFixed(2);
    }

    return '0.00';
  }

  static String _generateSecurityCode(int index) {
    final codes = [
      'WKT3Sa',
      'ABC123',
      'XYZ789',
      'DEF456',
      'GHI789',
      'JKL012',
      'MNO345',
      'PQR678',
      'STU901',
      'VWX234',
    ];
    return codes[index % codes.length];
  }

  static dynamic _parseRazonSocial(dynamic value) {
    if (value == null || value == '#e') return null;
    if (value is String) return value;
    return value.toString();
  }

  /// Limpia la caché para recargar datos
  static void clearCache() {
    _cachedTipos = null;
    _cachedResponse = null;
    debugPrint('[FakeDataService] Cache cleared');
  }
}
