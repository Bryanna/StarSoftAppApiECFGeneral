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

  /// Analiza una lista de facturas y genera tabs dinámicos basados en los tipos de ENCF y tipo_tab_envio_factura
  static List<DynamicTab> generateTabsFromInvoices(List<ERPInvoice> invoices) {
    if (invoices.isEmpty) {
      return _getDefaultTabs();
    }

    // Extraer tipos únicos de ENCF de los datos
    final Set<String> encfTypes = {};
    final Map<String, int> encfTypeCounts = {};

    // Extraer tipos únicos de tipo_tab_envio_factura
    final Set<String> tabTypes = {};
    final Map<String, int> tabTypeCounts = {};

    for (final invoice in invoices) {
      // Procesar tipos ENCF (lógica existente)
      String? encfType = _extractEncfType(invoice);
      if (encfType != null && encfType.isNotEmpty) {
        encfTypes.add(encfType);
        encfTypeCounts[encfType] = (encfTypeCounts[encfType] ?? 0) + 1;
      }

      // Procesar tipo_tab_envio_factura (nueva lógica)
      String? tabType = _extractTabType(invoice);
      if (tabType != null && tabType.isNotEmpty) {
        tabTypes.add(tabType);
        tabTypeCounts[tabType] = (tabTypeCounts[tabType] ?? 0) + 1;
      }
    }

    debugPrint('[DynamicTabsService] Tipos ENCF encontrados: $encfTypes');
    debugPrint('[DynamicTabsService] Conteos ENCF por tipo: $encfTypeCounts');
    debugPrint('[DynamicTabsService] Tipos Tab encontrados: $tabTypes');
    debugPrint('[DynamicTabsService] Conteos Tab por tipo: $tabTypeCounts');

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
        tabType: null,
      ),
    );

    // Agregar tabs por cada tipo de tab_envio_factura encontrado (PRIORIDAD)
    for (final tabType in tabTypes.toList()..sort()) {
      final label = formatTabTypeLabel(tabType);
      final icon = getTabTypeIcon(tabType);
      final count = tabTypeCounts[tabType] ?? 0;

      dynamicTabs.add(
        DynamicTab(
          id: 'tab_$tabType',
          label: label,
          icon: icon,
          category: _mapTabTypeToCategory(tabType),
          count: count,
          encfType: null,
          tabType: tabType,
        ),
      );
    }

    // Agregar tabs por cada tipo de ENCF encontrado (solo si no hay tabs de tipo)
    if (tabTypes.isEmpty) {
      for (final encfType in encfTypes.toList()..sort()) {
        final label = _encfTypeLabels[encfType] ?? 'Tipo $encfType';
        final icon = _encfTypeIcons[encfType] ?? '📄';
        final count = encfTypeCounts[encfType] ?? 0;

        dynamicTabs.add(
          DynamicTab(
            id: 'encf_$encfType',
            label: label,
            icon: icon,
            category: _mapEncfTypeToCategory(encfType),
            count: count,
            encfType: encfType,
            tabType: null,
          ),
        );
      }
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
          tabType: null,
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
          tabType: null,
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

  /// Extrae el tipo de tab de una factura desde tipoTabEnvioFactura
  static String? _extractTabType(ERPInvoice invoice) {
    if (invoice.tipoTabEnvioFactura != null &&
        invoice.tipoTabEnvioFactura!.isNotEmpty) {
      return invoice.tipoTabEnvioFactura!;
    }
    return null;
  }

  /// Convierte un tipo de tab en un label legible dividiendo por mayúsculas
  /// Ejemplo: "FacturaArs" -> "Factura Ars"
  static String formatTabTypeLabel(String tabType) {
    if (tabType.isEmpty) return tabType;

    // Dividir por mayúsculas
    final RegExp regExp = RegExp(r'(?=[A-Z])');
    final parts = tabType
        .split(regExp)
        .where((part) => part.isNotEmpty)
        .toList();

    // Capitalizar la primera letra de cada parte
    final formattedParts = parts.map((part) {
      if (part.isEmpty) return part;
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }).toList();

    return formattedParts.join(' ');
  }

  /// Obtiene un icono apropiado para el tipo de tab
  static String getTabTypeIcon(String tabType) {
    final lowerType = tabType.toLowerCase();

    if (lowerType.contains('factura')) {
      if (lowerType.contains('ars')) return '🏥'; // ARS (salud)
      if (lowerType.contains('credito')) return '💳';
      if (lowerType.contains('consumo')) return '🛒';
      return '📄';
    }

    if (lowerType.contains('nota')) {
      if (lowerType.contains('credito')) return '📉';
      if (lowerType.contains('debito')) return '📈';
      return '📝';
    }

    if (lowerType.contains('compra')) return '🏪';
    if (lowerType.contains('gasto')) return '💸';
    if (lowerType.contains('pago')) return '💰';
    if (lowerType.contains('export')) return '🌍';

    return '📋'; // Icono por defecto
  }

  /// Mapea un tipo de tab a una categoría de factura
  static InvoiceCategory _mapTabTypeToCategory(String tabType) {
    final lowerType = tabType.toLowerCase();

    if (lowerType.contains('factura')) {
      if (lowerType.contains('ars')) return InvoiceCategory.pacientes;
      return InvoiceCategory.todos;
    }

    if (lowerType.contains('nota')) {
      if (lowerType.contains('credito')) return InvoiceCategory.notasCredito;
      if (lowerType.contains('debito')) return InvoiceCategory.notasDebito;
      return InvoiceCategory.todos;
    }

    if (lowerType.contains('gasto')) return InvoiceCategory.gastos;

    return InvoiceCategory.todos;
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
    // Priorizar el estado del endpoint si está disponible
    final code = invoice.estadoCode;
    if (code != null) {
      return code == 3; // 3 = Enviado
    }
    // Fallback a la lógica anterior
    return (invoice.linkOriginal != null && invoice.linkOriginal!.isNotEmpty) ||
        (invoice.fechahorafirma != null && invoice.fechahorafirma!.isNotEmpty);
  }

  /// Determina si una factura está rechazada
  static bool _isRechazado(ERPInvoice invoice) {
    // Priorizar el estado del endpoint si está disponible
    final code = invoice.estadoCode;
    if (code != null) {
      return code == 2; // 2 = Rechazado
    }
    // Fallback a la lógica anterior
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
        // Filtrar por tipo de tab (prioridad)
        if (tab.tabType != null) {
          return invoices.where((inv) {
            final tabType = _extractTabType(inv);
            return tabType == tab.tabType;
          }).toList();
        }

        // Filtrar por tipo de ENCF (fallback)
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
        tabType: null,
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
  final String? tabType; // Nuevo campo para tipo_tab_envio_factura

  const DynamicTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.category,
    required this.count,
    this.encfType,
    this.tabType,
  });

  @override
  String toString() {
    return 'DynamicTab(id: $id, label: $label, count: $count, encfType: $encfType, tabType: $tabType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DynamicTab && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
