import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/invoice.dart';
import '../models/invoice_extensions.dart';

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

  /// Convierte los datos JSON a objetos Datum usando el parser del modelo
  static Future<List<Datum>> generateFakeInvoicesFromJson() async {
    final tiposData = await loadTiposData();
    final List<Datum> invoices = [];

    for (int i = 0; i < tiposData.length; i++) {
      final data = Map<String, dynamic>.from(tiposData[i]);

      try {
        // Agregar campo tipo_tab_envio_factura si no existe
        if (!data.containsKey('tipo_tab_envio_factura') &&
            !data.containsKey('tipoTabEnvioFactura')) {
          data['tipo_tab_envio_factura'] = _generateTipoTabEnvioFactura(data);
        }

        // Usar el parser del modelo Invoice para crear el Datum
        final invoice = Datum.fromJson(data);
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

  /// Genera un tipo_tab_envio_factura basado en los datos de la factura
  static String _generateTipoTabEnvioFactura(Map<String, dynamic> data) {
    // Obtener el tipo de ENCF
    String? encf = data['encf']?.toString();
    String? tipoecf = data['tipoecf']?.toString();

    // Determinar el tipo basado en ENCF o tipoecf
    String tipoBase = '';

    if (tipoecf != null && tipoecf.isNotEmpty) {
      switch (tipoecf) {
        case '31':
          tipoBase = 'FacturaCredito';
          break;
        case '32':
          tipoBase = 'FacturaConsumo';
          break;
        case '33':
          tipoBase = 'NotaDebito';
          break;
        case '34':
          tipoBase = 'NotaCredito';
          break;
        case '41':
          tipoBase = 'CompraLocal';
          break;
        case '43':
          tipoBase = 'GastoMenor';
          break;
        case '44':
          tipoBase = 'RegimenEspecial';
          break;
        case '45':
          tipoBase = 'CompraGubernamental';
          break;
        case '46':
          tipoBase = 'Exportacion';
          break;
        case '47':
          tipoBase = 'PagoExterior';
          break;
        default:
          tipoBase = 'FacturaGeneral';
      }
    } else if (encf != null && encf.length >= 3) {
      String tipoFromEncf = encf.substring(1, 3);
      switch (tipoFromEncf) {
        case '31':
          tipoBase = 'FacturaCredito';
          break;
        case '32':
          tipoBase = 'FacturaConsumo';
          break;
        case '33':
          tipoBase = 'NotaDebito';
          break;
        case '34':
          tipoBase = 'NotaCredito';
          break;
        default:
          tipoBase = 'FacturaGeneral';
      }
    } else {
      tipoBase = 'FacturaGeneral';
    }

    // Agregar variación para ARS si es apropiado
    String? razonsocial = data['razonsocialcomprador']
        ?.toString()
        .toLowerCase();
    if (razonsocial != null &&
        (razonsocial.contains('ars') || razonsocial.contains('salud'))) {
      if (tipoBase.startsWith('Factura')) {
        tipoBase = 'FacturaArs';
      }
    }

    return tipoBase;
  }

  /// Genera facturas específicas para diferentes categorías
  static Future<List<Datum>> generateFakeInvoicesByCategory(
    String category,
  ) async {
    debugPrint('[FakeDataService] Generating invoices for category: $category');

    var allInvoices = await generateFakeInvoicesFromJson();
    debugPrint(
      '[FakeDataService] Total invoices loaded: ${allInvoices.length}',
    );

    // Si no se cargó nada, retornar lista vacía
    if (allInvoices.isEmpty) {
      debugPrint('[FakeDataService] No invoices loaded from ejemplos.json');
      return [];
    }

    List<Datum> result;
    switch (category.toLowerCase()) {
      case 'pacientes':
        result = allInvoices
            .where(
              (inv) =>
                  inv.encf?.startsWith('E31') == true ||
                  inv.encf?.startsWith('E32') == true,
            )
            .toList();
        break;
      case 'ars':
        // Si se requiere una lógica específica para ARS, reemplazar este filtro.
        // Por ahora, se muestran todas (sin recortar) para que no haya límites.
        result = allInvoices.toList();
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

  /// Obtiene los items reales de una factura específica (por ENCF o Número Interno)
  static Future<List<Map<String, dynamic>>> getProductDetailsForInvoice(
    Datum invoice,
  ) async {
    final tiposData = await loadTiposData();
    Map<String, dynamic>? record;

    final encf = invoice.encf ?? '';
    final numero = invoice.fDocumento ?? '';

    // Buscar el registro correspondiente en ejemplos.json
    for (final data in tiposData) {
      final dataEncf = (data['ENCF'] ?? '') as String;
      final dataNumero = (data['NumeroFacturaInterna'] ?? '') as String;
      if (dataEncf == encf || (numero.isNotEmpty && dataNumero == numero)) {
        record = data;
        break;
      }
    }

    if (record == null) {
      debugPrint(
        '[FakeDataService] No matching record found for invoice ${encf.isNotEmpty ? encf : numero}',
      );
      return [];
    }

    // Extraer los items del registro encontrado
    final List<Map<String, dynamic>> items = [];
    for (int i = 1; i <= 50; i++) {
      final nombreKey = 'NombreItem[$i]';
      final cantidadKey = 'CantidadItem[$i]';
      final precioKey = 'PrecioUnitarioItem[$i]';
      final montoKey = 'MontoItem[$i]';
      final lineaKey = 'NumeroLinea[$i]';

      if (record.containsKey(nombreKey) &&
          record[nombreKey] != null &&
          record[nombreKey] != '#e') {
        items.add({
          'linea': (record[lineaKey] ?? i.toString()).toString(),
          'id': i.toString(),
          'nombre': record[nombreKey],
          'cantidad': record[cantidadKey] ?? '1.00',
          'precio': record[precioKey] ?? '0.00',
          'monto': record[montoKey] ?? '0.00',
          'unidad': record['UnidadMedida[$i]'] ?? '43',
        });
      }
    }

    // Ordenar por número de línea si está disponible
    items.sort((a, b) {
      final aLine = int.tryParse((a['linea'] ?? '0').toString()) ?? 0;
      final bLine = int.tryParse((b['linea'] ?? '0').toString()) ?? 0;
      return aLine.compareTo(bLine);
    });

    debugPrint(
      '[FakeDataService] Extracted ${items.length} items for invoice ${encf.isNotEmpty ? encf : numero}',
    );
    return items;
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
