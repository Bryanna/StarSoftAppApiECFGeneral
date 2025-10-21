import 'package:flutter/foundation.dart';
import '../models/erp_invoice.dart';
import '../models/ui_types.dart';

/// Servicio para generar tabs dinámicos basados en los tipos de ENCF encontrados en los datos
class DynamicTabsService {
  static const Map<String, String> _encfTypeLabels = {
    '31': 'Factura Crédito Fiscal',
    '32': 'Factura Consumo',
    '33': 'Nota Débito',
    '34': 'Nota Crédito',
    '41': 'Compras',
    '43': 'Gastos Menores',
    '44': 'Regímenes Especiales',
    '45': 'Gubernamental',
    '46': 'Exportaciones',
    '47': 'Pagos al Exterior',
  };

  static const Map<String, String> _encfTypeIcons = {
    '31': '💰',
    '32': '🛒',
    '33': '📈',
    '34': '📉',
    '41': '🏪',
    '43': '💸',
    '44': '⚖️',
    '45': '🏛️',
    '46': '🌍',
    '47': '💳',
  };

  /// Analiza una lista de facturas y genera tabs dinámicos basados en los tipos de ENCF encontrados
  static List<DynamicTab> generateTabsFromInvoices(List<ERPInvoice> invoices) {
    if (invoices.isEmpty) {
      return _getDefaultTabs();
    }

    // Extraer tipos únicos de ENCF de los datos
    final Set<String> encfTypes = {};
    final Map<String, int> typeCounts = {};

    for (final invoice in invoices) {
      String? encfType = _extractEncfType(invoice);
      if (encfType != null && encfType.isNotEmpty) {
        encfTypes.add(encfType);
        typeCounts[encfType] = (typeCounts[encfType] ?? 0) + 1;
      }
    }

    debugPrint('[DynamicTabsService] Tipos ENCF encontrados: $encfTypes');
    debugPrint('[DynamicTabsService] Conteos por tipo: $typeCounts');

    // Generar tabs dinámicos
    final List<DynamicTab> dynamicTabs = [];

    // Siempre agregar "Todos" primero
    dynamicTabs.add(
      DynamicTab(
        id: 'todos',
        label: 'Todos',
        icon: '📋',
        category: InvoiceCategory.todos,
        count: invoices.length,
        encfType: null,
      ),
    );

    // Agregar tabs por cada tipo de ENCF encontrado
    for (final encfType in encfTypes.toList()..sort()) {
      final label = _encfTypeLabels[encfType] ?? 'Tipo $encfType';
      final icon = _encfTypeIcons[encfType] ?? '📄';
      final count = typeCounts[encfType] ?? 0;

      dynamicTabs.add(
        DynamicTab(
          id: 'encf_$encfType',
          label: label,
          icon: icon,
          category: _mapEncfTypeToCategory(encfType),
          count: count,
          encfType: encfType,
        ),
      );
    }

    // Agregar tabs de estado si hay facturas con estados específicos
    final enviados = invoices.where((inv) => _isEnviado(inv)).length;
    final rechazados = invoices.where((inv) => _isRechazado(inv)).length;

    if (enviados > 0) {
      dynamicTabs.add(
        DynamicTab(
          id: 'enviados',
          label: 'Enviados',
          icon: '✅',
          category: InvoiceCategory.enviados,
          count: enviados,
          encfType: null,
        ),
      );
    }

    if (rechazados > 0) {
      dynamicTabs.add(
        DynamicTab(
          id: 'rechazados',
          label: 'Rechazados',
          icon: '❌',
          category: InvoiceCategory.rechazados,
          count: rechazados,
          encfType: null,
        ),
      );
    }

    return dynamicTabs;
  }

  /// Extrae el tipo de ENCF de una factura
  static String? _extractEncfType(ERPInvoice invoice) {
    // Prioridad: tipoecf > extraer de encf > tipoComprobante
    if (invoice.tipoecf != null && invoice.tipoecf!.isNotEmpty) {
      return invoice.tipoecf!;
    }

    if (invoice.encf != null && invoice.encf!.isNotEmpty) {
      // Extraer tipo del ENCF (ej: E320000000123 -> 32)
      final encf = invoice.encf!;
      if (encf.length >= 3 && encf.startsWith('E')) {
        return encf.substring(1, 3);
      }
    }

    if (invoice.tipoComprobante != null &&
        invoice.tipoComprobante!.isNotEmpty) {
      return invoice.tipoComprobante!;
    }

    return null;
  }

  /// Mapea un tipo de ENCF a una categoría de factura
  static InvoiceCategory _mapEncfTypeToCategory(String encfType) {
    switch (encfType) {
      case '31':
        return InvoiceCategory.pacientes; // Crédito Fiscal -> Pacientes
      case '32':
        return InvoiceCategory.pacientes; // Consumo -> Pacientes
      case '33':
        return InvoiceCategory.notasDebito;
      case '34':
        return InvoiceCategory.notasCredito;
      case '43':
        return InvoiceCategory.gastos;
      default:
        return InvoiceCategory.todos;
    }
  }

  /// Determina si una factura está enviada
  static bool _isEnviado(ERPInvoice invoice) {
    return (invoice.linkOriginal != null && invoice.linkOriginal!.isNotEmpty) ||
        (invoice.fechahorafirma != null && invoice.fechahorafirma!.isNotEmpty);
  }

  /// Determina si una factura está rechazada
  static bool _isRechazado(ERPInvoice invoice) {
    return invoice.fAnulada == true;
  }

  /// Filtra facturas por tab dinámico
  static List<ERPInvoice> filterInvoicesByTab(
    List<ERPInvoice> invoices,
    DynamicTab tab,
  ) {
    switch (tab.id) {
      case 'todos':
        return invoices;
      case 'enviados':
        return invoices.where((inv) => _isEnviado(inv)).toList();
      case 'rechazados':
        return invoices.where((inv) => _isRechazado(inv)).toList();
      default:
        // Filtrar por tipo de ENCF
        if (tab.encfType != null) {
          return invoices.where((inv) {
            final encfType = _extractEncfType(inv);
            return encfType == tab.encfType;
          }).toList();
        }
        return invoices;
    }
  }

  /// Tabs por defecto cuando no hay datos
  static List<DynamicTab> _getDefaultTabs() {
    return [
      DynamicTab(
        id: 'todos',
        label: 'Todos',
        icon: '📋',
        category: InvoiceCategory.todos,
        count: 0,
        encfType: null,
      ),
    ];
  }
}

/// Modelo para un tab dinámico
class DynamicTab {
  final String id;
  final String label;
  final String icon;
  final InvoiceCategory category;
  final int count;
  final String? encfType;

  const DynamicTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.category,
    required this.count,
    this.encfType,
  });

  @override
  String toString() {
    return 'DynamicTab(id: $id, label: $label, count: $count, encfType: $encfType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DynamicTab && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
