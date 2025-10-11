import 'package:intl/intl.dart';
import 'invoice.dart';

/// Extensiones para el modelo Invoice para compatibilidad con código legacy
extension DatumExtensions on Datum {
  // Campos legacy que ya no existen en el nuevo modelo
  String? get fDocumento => encf;
  bool? get fAnulada => null; // No existe en el nuevo modelo
  bool? get fPagada => null; // No existe en el nuevo modelo
  String? get fSubtotal => montogravadototal;
  String? get fItbis => totalitbis;
  String? get fTotal => montototal;
  String? get codigoSeguridad => codigoseguridad?.toString();
  DateTime? get fechaHoraFirma => _parseDateTime(fechahorafirma);
  String? get fRncEmisor => rncemisor;
  String? get fRncReceptor => rnccomprador;
  String? get fReceptorNombre =>
      razonsocialcomprador?.name.replaceAll('_', ' ');
  String? get fDireccionReceptor => direccioncomprador;
  String? get fArsNombre => null; // No existe en el nuevo modelo

  // Conversión de fechaemision enum a DateTime
  DateTime? get fechaemisionDateTime {
    if (fechaemision == null) return null;
    return _parseFechaEmision(fechaemision!);
  }

  // Conversión de fechavencimientosecuencia enum a DateTime
  DateTime? get fechavencimientosecuenciaDateTime {
    if (fechavencimientosecuencia == null) return null;
    return _parseFechaVencimiento(fechavencimientosecuencia!);
  }

  // Helper para parsear fechas del formato del enum
  DateTime? _parseFechaEmision(Fechaemision fecha) {
    try {
      final dateStr = fechaemisionValues.reverse[fecha];
      if (dateStr == null) return null;

      // Formato: "1/12/2018" o "2/4/2020"
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  DateTime? _parseFechaVencimiento(Fechavencimientosecuencia fecha) {
    try {
      final dateStr = fechavencimientosecuenciaValues.reverse[fecha];
      if (dateStr == null) return null;

      // Formato: "31/12/2025"
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
