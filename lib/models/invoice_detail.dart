import 'dart:convert';

/// Modelo para los detalles de una factura del ERP
class InvoiceDetail {
  final int? ars;
  final double? costo;
  final double? itbis;
  final double? total;
  final double? precio;
  final double? cantidad;
  final double? cobertura;
  final int? idMedico;
  final String? referencia;
  final String? descripcion;
  final int? clasificacion;

  const InvoiceDetail({
    this.ars,
    this.costo,
    this.itbis,
    this.total,
    this.precio,
    this.cantidad,
    this.cobertura,
    this.idMedico,
    this.referencia,
    this.descripcion,
    this.clasificacion,
  });

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) {
    return InvoiceDetail(
      ars: json['ars'] as int?,
      costo: _parseDouble(json['costo']),
      itbis: _parseDouble(json['itbis']),
      total: _parseDouble(json['total']),
      precio: _parseDouble(json['precio']),
      cantidad: _parseDouble(json['cantidad']),
      cobertura: _parseDouble(json['cobertura']),
      idMedico: json['id_medico'] as int?,
      referencia: json['referencia'] as String?,
      descripcion: json['descripcion'] as String?,
      clasificacion: json['clasificacion'] as int?,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'ars': ars,
      'costo': costo,
      'itbis': itbis,
      'total': total,
      'precio': precio,
      'cantidad': cantidad,
      'cobertura': cobertura,
      'id_medico': idMedico,
      'referencia': referencia,
      'descripcion': descripcion,
      'clasificacion': clasificacion,
    };
  }

  @override
  String toString() {
    return 'InvoiceDetail(referencia: $referencia, descripcion: $descripcion, cantidad: $cantidad, precio: $precio, total: $total, cobertura: $cobertura)';
  }
}

/// Utilidad para parsear el JSON string de detalle_factura
class InvoiceDetailParser {
  /// Parsea el JSON string de detalle_factura y retorna una lista de InvoiceDetail
  static List<InvoiceDetail> parseDetalleFactura(String? detalleFacturaJson) {
    if (detalleFacturaJson == null || detalleFacturaJson.isEmpty) {
      return [];
    }

    try {
      // El JSON viene como string, necesitamos parsearlo
      final List<dynamic> jsonList = json.decode(detalleFacturaJson);

      return jsonList
          .map((item) => InvoiceDetail.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Si hay error en el parsing, retornamos lista vacía
      print('Error parsing detalle_factura: $e');
      return [];
    }
  }

  /// Convierte una lista de InvoiceDetail de vuelta a JSON string
  static String encodeDetalleFactura(List<InvoiceDetail> details) {
    try {
      final List<Map<String, dynamic>> jsonList = details
          .map((detail) => detail.toJson())
          .toList();
      return json.encode(jsonList);
    } catch (e) {
      print('Error encoding detalle_factura: $e');
      return '[]';
    }
  }
}
