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
    switch (tipoecf) {
      case '31':
        return 'Factura de Crédito Fiscal';
      case '32':
        return 'Factura de Consumo';
      case '33':
        return 'Nota de Débito';
      case '34':
        return 'Nota de Crédito';
      case '41':
        return 'Compras';
      case '43':
        return 'Gastos Menores';
      case '44':
        return 'Regímenes Especiales';
      case '45':
        return 'Gubernamental';
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
    if (items.length == 1)
      return '1 item: ${items.first.descripcion ?? 'Sin descripción'}';
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
}
