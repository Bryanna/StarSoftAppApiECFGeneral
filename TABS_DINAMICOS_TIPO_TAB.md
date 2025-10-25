# Tabs Dinámicos por tipo_tab_envio_factura

## Resumen de Cambios

Se ha mejorado el sistema de tabs dinámicos para generar automáticamente tabs basados en el campo `tipo_tab_envio_factura` que viene del endpoint ERP. El sistema divide las palabras por mayúsculas para crear labels legibles.

## ✨ Nueva Funcionalidad

### 1. **Procesamiento Automático**

El sistema ahora procesa el campo `tipo_tab_envio_factura` de cada factura y:

- Extrae tipos únicos
- Divide palabras por mayúsculas
- Genera labels legibles
- Asigna iconos apropiados
- Cuenta facturas por tipo

### 2. **Ejemplos de Transformación**

| Campo Original          | Tab Generado           | Icono | Descripción              |
| ----------------------- | ---------------------- | ----- | ------------------------ |
| `"FacturaArs"`          | "Factura Ars"          | 🏥    | Facturas del sistema ARS |
| `"NotaCredito"`         | "Nota Credito"         | 📉    | Notas de crédito         |
| `"FacturaConsumo"`      | "Factura Consumo"      | 🛒    | Facturas de consumo      |
| `"GastoMenor"`          | "Gasto Menor"          | 💸    | Gastos menores           |
| `"CompraGubernamental"` | "Compra Gubernamental" | 🏛️    | Compras gubernamentales  |
| `"PagoExterior"`        | "Pago Exterior"        | 🌍    | Pagos al exterior        |

### 3. **Prioridad de Tabs**

1. **Tipo Tab** (nuevo) - Basado en `tipo_tab_envio_factura`
2. **Tipo ENCF** (existente) - Solo si no hay tipos de tab
3. **Estados** (existente) - Enviados, Rechazados

## 🔧 Implementación Técnica

### Método de Formateo

```dart
static String _formatTabTypeLabel(String tabType) {
  // Dividir por mayúsculas usando RegExp
  final RegExp regExp = RegExp(r'(?=[A-Z])');
  final parts = tabType.split(regExp).where((part) => part.isNotEmpty).toList();

  // Capitalizar cada parte
  final formattedParts = parts.map((part) {
    return part[0].toUpperCase() + part.substring(1).toLowerCase();
  }).toList();

  return formattedParts.join(' ');
}
```

### Asignación de Iconos

```dart
static String _getTabTypeIcon(String tabType) {
  final lowerType = tabType.toLowerCase();

  if (lowerType.contains('factura')) {
    if (lowerType.contains('ars')) return '🏥';
    if (lowerType.contains('credito')) return '💳';
    if (lowerType.contains('consumo')) return '🛒';
    return '📄';
  }

  if (lowerType.contains('nota')) {
    if (lowerType.contains('credito')) return '📉';
    if (lowerType.contains('debito')) return '📈';
    return '📝';
  }

  // ... más casos
  return '📋';
}
```

### Filtrado de Facturas

```dart
static List<ERPInvoice> filterInvoicesByTab(
  List<ERPInvoice> invoices,
  DynamicTab tab,
) {
  // Prioridad a tipo_tab_envio_factura
  if (tab.tabType != null) {
    return invoices.where((inv) {
      final tabType = _extractTabType(inv);
      return tabType == tab.tabType;
    }).toList();
  }

  // Fallback a tipo ENCF
  if (tab.encfType != null) {
    return invoices.where((inv) {
      final encfType = _extractEncfType(inv);
      return encfType == tab.encfType;
    }).toList();
  }

  return invoices;
}
```

## 📊 Flujo de Datos

```
Endpoint ERP → Facturas con tipo_tab_envio_factura
     ↓
Extracción de tipos únicos
     ↓
Formateo de labels (dividir por mayúsculas)
     ↓
Asignación de iconos
     ↓
Generación de tabs dinámicos
     ↓
Filtrado de facturas por tab seleccionado
```

## 🎯 Casos de Uso

### Ejemplo 1: Sistema ARS

```json
{
  "tipo_tab_envio_factura": "FacturaArs",
  "encf": "E31000000123",
  "razonsocialcomprador": "ARS Salud"
}
```

**Resultado**: Tab "Factura Ars" 🏥

### Ejemplo 2: Nota de Crédito

```json
{
  "tipo_tab_envio_factura": "NotaCredito",
  "encf": "E34000000456",
  "montototal": -1500.0
}
```

**Resultado**: Tab "Nota Credito" 📉

### Ejemplo 3: Múltiples Tipos

Si tienes facturas con:

- 5 × `"FacturaArs"`
- 3 × `"NotaCredito"`
- 2 × `"FacturaConsumo"`

Se generan automáticamente:

- 📋 Todos (10)
- 🏥 Factura Ars (5)
- 🛒 Factura Consumo (2)
- 📉 Nota Credito (3)

## 📁 Archivos Modificados

### Servicio Principal

- `lib/services/dynamic_tabs_service.dart`
  - ✅ Método `_extractTabType()` - Extrae tipo de tab
  - ✅ Método `_formatTabTypeLabel()` - Formatea labels
  - ✅ Método `_getTabTypeIcon()` - Asigna iconos
  - ✅ Método `_mapTabTypeToCategory()` - Mapea categorías
  - ✅ Actualizado `generateTabsFromInvoices()` - Lógica principal
  - ✅ Actualizado `filterInvoicesByTab()` - Filtrado mejorado

### Modelo de Datos

- `DynamicTab` class
  - ✅ Agregado campo `tabType` opcional
  - ✅ Actualizado constructor y métodos

### Ejemplo de Uso

- `example/dynamic_tabs_by_tipo_tab_usage.dart`
  - ✅ Demo completo de la funcionalidad
  - ✅ Casos de prueba
  - ✅ Ejemplos visuales

## 🚀 Beneficios

1. **Automático**: No necesitas configurar tabs manualmente
2. **Flexible**: Se adapta a cualquier valor de `tipo_tab_envio_factura`
3. **Legible**: Convierte `"FacturaArs"` en `"Factura Ars"`
4. **Visual**: Iconos apropiados para cada tipo
5. **Escalable**: Funciona con cualquier cantidad de tipos
6. **Compatible**: Mantiene funcionalidad existente de ENCF

## 🔄 Compatibilidad

- ✅ **Retrocompatible**: Si no hay `tipo_tab_envio_factura`, usa tipos ENCF
- ✅ **Datos existentes**: Funciona con facturas que no tienen el campo
- ✅ **Migración suave**: No requiere cambios en datos existentes
- ✅ **Fallback**: Siempre muestra al menos el tab "Todos"

## 🧪 Pruebas

Usa el archivo `example/dynamic_tabs_by_tipo_tab_usage.dart` para:

- Ver ejemplos de formateo
- Probar diferentes tipos de tab
- Entender la lógica de iconos
- Verificar el conteo de facturas

El sistema está listo para usar con tus endpoints que incluyan el campo `tipo_tab_envio_factura`!
