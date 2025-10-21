import 'package:flutter/material.dart';

import 'erp_invoice.dart';
import 'invoice_detail.dart';

/// Extensiones adicionales para ERPInvoice para funcionalidades específicas
extension ERPInvoiceExtensions on ERPInvoice {
  // Validaciones
  bool get isValid => encf != null && encf!.isNotEmpty;
  bool get hasClient => rnccomprador != null && rnccomprador!.isNotEmpty;
  bool get hasAmount => montototal != null && totalAmount > 0;

  // Formateo de montos
  String get formattedTotal => _formatCurrency(totalAmount);
  String get formattedSubtotal => _formatCurrency(subtotalAmount);
  String get formattedItbis => _formatCurrency(itbisAmount);
  String get formattedExento => _formatCurrency(exentoAmount);

  // Formateo de fechas
  String get formattedFechaEmision => _formatDate(fechaemisionDateTime);
  String get formattedFechaVencimiento => _formatDate(fechaVencimientoDateTime);

  // Información resumida para mostrar en listas
  String get displayTitle => '$numeroFactura - $clienteNombre';
  String get displaySubtitle => '$formattedFechaEmision • $formattedTotal';

  // Tipo de comprobante legible
  String get tipoComprobanteDisplay {
    // Obtener el tipo de comprobante desde tipoecf o extraerlo del encf
    final tipo = _getTipoComprobante();

    switch (tipo) {
      // --- e-CF (Comprobantes Electrónicos) ---
      case '31':
      case 'E31':
        return 'Crédito Fiscal Electrónico';
      case '32':
      case 'E32':
        return 'Consumo Electrónico';
      case '33':
      case 'E33':
        return 'Nota de Débito Electrónica';
      case '34':
      case 'E34':
        return 'Nota de Crédito Electrónica';
      case '41':
      case 'E41':
        return 'Compras Electrónico';
      case '43':
      case 'E43':
        return 'Gastos Menores Electrónico';
      case '44':
      case 'E44':
        return 'Regímenes Especiales Electrónico';
      case '45':
      case 'E45':
        return 'Gubernamental Electrónico';

      // --- Comprobantes Fiscales tradicionales (NCF tipo B / P / C / E) ---
      case 'B01':
      case 'C01':
      case 'P01':
        return 'Factura con Crédito Fiscal';
      case 'B02':
      case 'C02':
      case 'P02':
        return 'Factura de Consumo';
      case 'B03':
      case 'C03':
      case 'P03':
        return 'Nota de Débito';
      case 'B04':
      case 'C04':
      case 'P04':
        return 'Nota de Crédito';
      case 'B11':
      case 'C11':
      case 'P11':
        return 'Factura de Compras';
      case 'B13':
      case 'C13':
      case 'P13':
        return 'Gastos Menores';
      case 'B14':
      case 'C14':
      case 'P14':
        return 'Regímenes Especiales';
      case 'B15':
      case 'C15':
      case 'P15':
        return 'Factura Gubernamental';

      // --- Comprobantes Provisionales o Especiales ---
      case 'B16':
        return 'Comprobante para Exportaciones';
      case 'B17':
        return 'Comprobante de Zona Franca';
      case 'B18':
        return 'Comprobante de Ventas Omnipresentes (OM)';
      case 'B19':
        return 'Comprobante de Ventas Turísticas';
      case 'B20':
        return 'Comprobante Provisional para Transacciones Electrónicas';
      case 'B21':
        return 'Comprobante de Donaciones';
      case 'B22':
        return 'Comprobante de Retención (Rentas)';
      case 'B23':
        return 'Comprobante de Retención (ITBIS)';

      // --- Por defecto ---
      default:
        return 'Comprobante Fiscal';
    }
  }

  // Estado basado en fechas y datos
  String get estadoDetallado {
    final now = DateTime.now();
    final fechaVenc = fechaVencimientoDateTime;

    if (fechaVenc != null && fechaVenc.isBefore(now)) {
      return 'Vencida';
    }

    if (valorpagar != null && _parseAmount(valorpagar) > 0) {
      return 'Pendiente de Pago';
    }

    return 'Procesada';
  }

  // Información de impuestos
  Map<String, double> get desgloseTributario {
    return {
      'Gravado': subtotalAmount,
      'ITBIS': itbisAmount,
      'Exento': exentoAmount,
      'Total': totalAmount,
    };
  }

  // Detalles de la factura parseados
  List<InvoiceDetail> get detalles {
    return InvoiceDetailParser.parseDetalleFactura(detalleFactura);
  }

  // Información resumida de los detalles
  int get cantidadItems => detalles.length;

  String get resumenDetalles {
    final items = detalles;
    if (items.isEmpty) return 'Sin detalles';
    if (items.length == 1) {
      return '1 item: ${items.first.descripcion ?? 'Sin descripción'}';
    }
    return '${items.length} items';
  }

  // Obtener todas las descripciones de los items
  List<String> get descripcionesItems {
    return detalles
        .map((detail) => detail.descripcion ?? 'Sin descripción')
        .toList();
  }

  // Total calculado desde los detalles (para verificación)
  double get totalFromDetails {
    return detalles.fold(0.0, (sum, detail) => sum + (detail.total ?? 0.0));
  }

  // Métodos de utilidad privados
  String _formatCurrency(double amount) {
    if (amount == 0) return 'RD\$ 0.00';
    return 'RD\$ ${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  double _parseAmount(String? amountStr) {
    if (amountStr == null || amountStr.isEmpty) return 0.0;
    try {
      final cleanAmount = amountStr.replaceAll(',', '').replaceAll(' ', '');
      return double.tryParse(cleanAmount) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Método para búsqueda y filtrado
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;

    final searchLower = query.toLowerCase();

    // Búsqueda en campos principales
    if (numeroFactura.toLowerCase().contains(searchLower) ||
        clienteNombre.toLowerCase().contains(searchLower) ||
        clienteRnc.toLowerCase().contains(searchLower) ||
        empresaNombre.toLowerCase().contains(searchLower) ||
        (fechaemision?.toLowerCase().contains(searchLower) ?? false) ||
        (numerofacturainterna?.toLowerCase().contains(searchLower) ?? false)) {
      return true;
    }

    // Búsqueda en detalles de la factura
    for (final detail in detalles) {
      if ((detail.descripcion?.toLowerCase().contains(searchLower) ?? false) ||
          (detail.referencia?.toLowerCase().contains(searchLower) ?? false)) {
        return true;
      }
    }

    return false;
  }

  // Filtro por rango de fechas
  bool isInDateRange(DateTime? startDate, DateTime? endDate) {
    final fechaEmision = fechaemisionDateTime;
    if (fechaEmision == null) return false;

    if (startDate != null && fechaEmision.isBefore(startDate)) {
      return false;
    }

    if (endDate != null && fechaEmision.isAfter(endDate)) {
      return false;
    }

    return true;
  }

  // Comparación para ordenamiento
  int compareByDate(ERPInvoice other) {
    final thisDate = fechaemisionDateTime;
    final otherDate = other.fechaemisionDateTime;

    if (thisDate == null && otherDate == null) return 0;
    if (thisDate == null) return 1;
    if (otherDate == null) return -1;

    return otherDate.compareTo(thisDate); // Más recientes primero
  }

  int compareByAmount(ERPInvoice other) {
    return other.totalAmount.compareTo(totalAmount); // Mayores primero
  }

  int compareByClient(ERPInvoice other) {
    return clienteNombre.compareTo(other.clienteNombre);
  }

  // Colores para tipos de comprobante
  ComprobanteTypeColors get tipoComprobanteColors {
    // Obtener el tipo de comprobante desde tipoecf o extraerlo del encf
    final tipo = _getTipoComprobante();

    switch (tipo) {
      // --- e-CF (Comprobantes Electrónicos) - Tonos azules/verdes ---
      case '31':
      case 'E31':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFE3F2FD), // Azul claro
          textColor: const Color(0xFF1565C0), // Azul oscuro
          borderColor: const Color(0xFF42A5F5), // Azul medio
        );
      case '32':
      case 'E32':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFE8F5E8), // Verde claro
          textColor: const Color(0xFF2E7D32), // Verde oscuro
          borderColor: const Color(0xFF66BB6A), // Verde medio
        );
      case '33':
      case 'E33':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFFFF3E0), // Naranja claro
          textColor: const Color(0xFFE65100), // Naranja oscuro
          borderColor: const Color(0xFFFF9800), // Naranja medio
        );
      case '34':
      case 'E34':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFF3E5F5), // Púrpura claro
          textColor: const Color(0xFF6A1B9A), // Púrpura oscuro
          borderColor: const Color(0xFF9C27B0), // Púrpura medio
        );
      case '41':
      case 'E41':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFE0F2F1), // Teal claro
          textColor: const Color(0xFF00695C), // Teal oscuro
          borderColor: const Color(0xFF26A69A), // Teal medio
        );
      case '43':
      case 'E43':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFFCE4EC), // Rosa claro
          textColor: const Color(0xFFC2185B), // Rosa oscuro
          borderColor: const Color(0xFFE91E63), // Rosa medio
        );
      case '44':
      case 'E44':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFEDE7F6), // Índigo claro
          textColor: const Color(0xFF512DA8), // Índigo oscuro
          borderColor: const Color(0xFF673AB7), // Índigo medio
        );
      case '45':
      case 'E45':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFE8EAF6), // Azul índigo claro
          textColor: const Color(0xFF303F9F), // Azul índigo oscuro
          borderColor: const Color(0xFF3F51B5), // Azul índigo medio
        );

      // --- Comprobantes Fiscales tradicionales - Tonos grises/marrones ---
      case 'B01':
      case 'C01':
      case 'P01':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFF5F5F5), // Gris claro
          textColor: const Color(0xFF424242), // Gris oscuro
          borderColor: const Color(0xFF757575), // Gris medio
        );
      case 'B02':
      case 'C02':
      case 'P02':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFEFEBE9), // Marrón claro
          textColor: const Color(0xFF5D4037), // Marrón oscuro
          borderColor: const Color(0xFF8D6E63), // Marrón medio
        );
      case 'B03':
      case 'C03':
      case 'P03':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFFFEBEE), // Rojo claro
          textColor: const Color(0xFFC62828), // Rojo oscuro
          borderColor: const Color(0xFFE53935), // Rojo medio
        );
      case 'B04':
      case 'C04':
      case 'P04':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFE1F5FE), // Cian claro
          textColor: const Color(0xFF0277BD), // Cian oscuro
          borderColor: const Color(0xFF03A9F4), // Cian medio
        );
      case 'B11':
      case 'C11':
      case 'P11':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFF1F8E9), // Verde lima claro
          textColor: const Color(0xFF558B2F), // Verde lima oscuro
          borderColor: const Color(0xFF8BC34A), // Verde lima medio
        );
      case 'B13':
      case 'C13':
      case 'P13':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFFFF8E1), // Ámbar claro
          textColor: const Color(0xFFFF8F00), // Ámbar oscuro
          borderColor: const Color(0xFFFFC107), // Ámbar medio
        );
      case 'B14':
      case 'C14':
      case 'P14':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFE4E7EA), // Azul gris claro
          textColor: const Color(0xFF37474F), // Azul gris oscuro
          borderColor: const Color(0xFF607D8B), // Azul gris medio
        );
      case 'B15':
      case 'C15':
      case 'P15':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFE8F5E8), // Verde gobierno claro
          textColor: const Color(0xFF1B5E20), // Verde gobierno oscuro
          borderColor: const Color(0xFF4CAF50), // Verde gobierno medio
        );

      // --- Comprobantes Especiales - Colores únicos ---
      case 'B16':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFE0F7FA), // Cian exportación
          textColor: const Color(0xFF006064),
          borderColor: const Color(0xFF00BCD4),
        );
      case 'B17':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFF9FBE7), // Lima zona franca
          textColor: const Color(0xFF33691E),
          borderColor: const Color(0xFF689F38),
        );
      case 'B18':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFFFF3C4), // Amarillo omnipresente
          textColor: const Color(0xFFE65100),
          borderColor: const Color(0xFFFF9800),
        );
      case 'B19':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFE8EAF6), // Azul turismo
          textColor: const Color(0xFF283593),
          borderColor: const Color(0xFF3F51B5),
        );
      case 'B20':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFF3E5F5), // Púrpura provisional
          textColor: const Color(0xFF7B1FA2),
          borderColor: const Color(0xFF9C27B0),
        );
      case 'B21':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFE8F5E8), // Verde donaciones
          textColor: const Color(0xFF2E7D32),
          borderColor: const Color(0xFF4CAF50),
        );
      case 'B22':
      case 'B23':
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFFFECB3), // Amarillo retenciones
          textColor: const Color(0xFFE65100),
          borderColor: const Color(0xFFFF9800),
        );

      // --- Por defecto ---
      default:
        return ComprobanteTypeColors(
          backgroundColor: const Color(0xFFF5F5F5), // Gris neutro
          textColor: const Color(0xFF616161),
          borderColor: const Color(0xFF9E9E9E),
        );
    }
  }

  /// Obtiene el tipo de comprobante desde encf (más confiable) o tipoecf como fallback
  String _getTipoComprobante() {
    // PRIORIDAD 1: Extraer los primeros 3 caracteres del encf (más confiable)
    if (encf != null && encf!.length >= 3) {
      final extracted = encf!.substring(0, 3).toUpperCase();
      debugPrint('[ERPInvoice] Tipo extraído de ENCF "$encf": $extracted');
      return extracted;
    }

    // PRIORIDAD 2: Si no hay encf, usar tipoecf como fallback
    if (tipoecf != null && tipoecf!.isNotEmpty) {
      debugPrint('[ERPInvoice] Usando tipoecf como fallback: $tipoecf');
      return tipoecf!;
    }

    // FALLBACK: Si no hay ninguno, retornar un valor por defecto
    debugPrint(
      '[ERPInvoice] No se pudo determinar tipo, usando B02 por defecto',
    );
    return 'B02'; // Factura de consumo por defecto
  }

  /// Información de debug sobre el tipo de comprobante
  String get tipoComprobanteDebugInfo {
    final tipo = _getTipoComprobante();
    return 'ENCF: "$encf" | TipoeCF: "$tipoecf" | Tipo usado: "$tipo"';
  }
}

/// Clase para definir los colores de un tipo de comprobante
class ComprobanteTypeColors {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const ComprobanteTypeColors({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}
