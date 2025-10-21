# Sistema de Tabs Dinámicos - Implementación

## Descripción General

El sistema de tabs dinámicos genera automáticamente pestañas basadas en los tipos de ENCF (Comprobantes Fiscales Electrónicos) encontrados en los datos de facturas. Esto reemplaza el sistema estático anterior y proporciona una experiencia más flexible y adaptable.

## Características Principales

### 1. Generación Automática de Tabs

- Los tabs se crean dinámicamente según los tipos de ENCF presentes en los datos
- Cada tab muestra un contador actualizado en tiempo real
- Se incluyen iconos específicos para cada tipo de comprobante

### 2. Tipos de ENCF Soportados

| Código | Descripción                      | Icono | Categoría     |
| ------ | -------------------------------- | ----- | ------------- |
| E31    | Crédito Fiscal Electrónico       | 💰    | Pacientes     |
| E32    | Consumo Electrónico              | 🛒    | Pacientes     |
| E33    | Nota de Débito Electrónica       | 📈    | Notas Débito  |
| E34    | Nota de Crédito Electrónica      | 📉    | Notas Crédito |
| E41    | Compras Electrónico              | 🏪    | Todos         |
| E43    | Gastos Menores Electrónico       | 💸    | Gastos        |
| E44    | Regímenes Especiales Electrónico | ⚖️    | Todos         |
| E45    | Gubernamental Electrónico        | 🏛️    | Todos         |

### 3. Tabs de Estado

- **Enviados** ✅: Facturas que tienen `linkOriginal` o `fechahorafirma`
- **Rechazados** ❌: Facturas marcadas como anuladas

## Archivos Implementados

### 1. `lib/services/dynamic_tabs_service.dart`

Servicio principal que contiene la lógica para:

- Analizar facturas y extraer tipos de ENCF
- Generar tabs dinámicos con contadores
- Filtrar facturas por tab seleccionado
- Mapear tipos de ENCF a categorías

### 2. `lib/controllers/dynamic_home_controller.dart`

Controlador que maneja:

- Carga de datos y generación de tabs
- Estado de selección y filtros
- Búsqueda y filtros de fecha
- Integración con GetX para reactividad

### 3. `lib/widgets/dynamic_tabs_bar.dart`

Widget que renderiza:

- Tabs dinámicos con iconos y contadores
- Estilos adaptativos según el tipo
- Interacción táctil y estados visuales

### 4. `lib/widgets/dynamic_data_table.dart`

Tabla de datos que:

- Muestra facturas filtradas por tab actual
- Maneja estados de error y carga
- Integra acciones de ver, enviar y previsualizar

## Integración en HomeScreen

### Cambios Realizados

1. **Reemplazo de \_TabsBar por \_DynamicTabsBar**

```dart
// Antes (estático)
_TabsBar(isWide: isWide),

// Después (dinámico)
_DynamicTabsBar(isWide: isWide),
```

2. **Lógica de Generación de Tabs**

```dart
List<_DynamicTab> _generateDynamicTabs(List<ERPInvoice> invoices) {
  // Analiza facturas y genera tabs automáticamente
  // Cuenta tipos de ENCF
  // Crea tabs con iconos y contadores
}
```

3. **Extracción de Tipo ENCF**

```dart
String? _extractEncfType(ERPInvoice invoice) {
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

  return invoice.tipoComprobante;
}
```

## Ventajas del Sistema Dinámico

### 1. Adaptabilidad

- Se ajusta automáticamente a los datos disponibles
- No requiere configuración manual de tabs
- Funciona con cualquier combinación de tipos de ENCF

### 2. Mantenibilidad

- Código más limpio y modular
- Fácil agregar nuevos tipos de comprobante
- Separación clara de responsabilidades

### 3. Experiencia de Usuario

- Interfaz más intuitiva y contextual
- Contadores en tiempo real
- Iconos visuales para identificación rápida

### 4. Escalabilidad

- Soporta fácilmente nuevos tipos de ENCF
- Extensible para filtros adicionales
- Compatible con futuras funcionalidades

## Uso del Sistema

### Implementación Básica

```dart
class MyHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<DynamicHomeController>(
      init: DynamicHomeController(),
      builder: (controller) {
        return Column(
          children: [
            // Tabs dinámicos
            DynamicTabsBar(isWide: true),

            // Tabla de datos
            Expanded(
              child: DynamicDataTable(
                onView: (invoice) => _viewInvoice(invoice),
                onSend: (invoice) => _sendInvoice(invoice),
                onPreview: (invoice) => _previewInvoice(invoice),
              ),
            ),
          ],
        );
      },
    );
  }
}
```

### Personalización de Tipos

Para agregar un nuevo tipo de ENCF, actualizar en `DynamicTabsService`:

```dart
static const Map<String, String> _encfTypeLabels = {
  // Tipos existentes...
  '46': 'Nuevo Tipo de Comprobante', // Agregar aquí
};

static const Map<String, String> _encfTypeIcons = {
  // Iconos existentes...
  '46': '🆕', // Agregar icono aquí
};
```

## Migración desde Sistema Estático

### Pasos de Migración

1. **Reemplazar imports**

```dart
// Remover
import 'home_controller.dart';

// Agregar
import '../../controllers/dynamic_home_controller.dart';
import '../../widgets/dynamic_tabs_bar.dart';
```

2. **Actualizar controlador**

```dart
// Cambiar de HomeController a DynamicHomeController
GetBuilder<DynamicHomeController>(
  init: DynamicHomeController(),
  // ...
)
```

3. **Reemplazar widgets de tabs**

```dart
// Cambiar _TabsBar por DynamicTabsBar
DynamicTabsBar(isWide: isWide)
```

### Compatibilidad

- El sistema es compatible con el modelo `ERPInvoice` existente
- No requiere cambios en la base de datos
- Mantiene todas las funcionalidades anteriores

## Ejemplo de Uso Completo

Ver `example/dynamic_tabs_usage.dart` para ejemplos detallados de:

- Implementación básica
- Integración completa con búsqueda y filtros
- Manejo de eventos y acciones
- Personalización de estilos

## Consideraciones Técnicas

### Performance

- Los tabs se generan una sola vez al cargar los datos
- Filtrado eficiente usando índices y mapas
- Actualización reactiva solo cuando cambian los datos

### Memoria

- Uso mínimo de memoria adicional
- Reutilización de widgets existentes
- Limpieza automática de recursos

### Compatibilidad

- Compatible con Flutter 3.0+
- Funciona en todas las plataformas (iOS, Android, Web, Desktop)
- Responsive design para diferentes tamaños de pantalla

## Próximas Mejoras

1. **Persistencia de Tab Seleccionado**

   - Recordar último tab seleccionado
   - Restaurar estado al reiniciar la app

2. **Filtros Avanzados**

   - Filtros por rango de montos
   - Filtros por cliente o empresa
   - Combinación de múltiples filtros

3. **Personalización de Usuario**

   - Permitir ocultar/mostrar tabs específicos
   - Reordenar tabs según preferencias
   - Temas personalizados por tipo de comprobante

4. **Analytics y Métricas**
   - Tracking de uso de tabs
   - Métricas de performance
   - Reportes de tipos de comprobante más utilizados
