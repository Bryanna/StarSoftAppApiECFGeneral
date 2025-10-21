# Pantalla de Detalles de Factura Mejorada

## Descripción General

La nueva `InvoicePreviewScreen` ha sido completamente rediseñada para ofrecer una experiencia de usuario superior al visualizar los detalles completos de una factura. La pantalla ahora está organizada en pestañas y proporciona acceso a toda la información relevante de manera estructurada y visualmente atractiva.

## 🎯 Características Principales

### 📱 **Diseño Moderno y Organizado**

- **Header informativo** con datos principales y estado visual
- **3 pestañas organizadas**: Detalles, PDF, Acciones
- **Floating Action Buttons** para acceso rápido
- **Colores adaptativos** según el tipo de comprobante
- **Diseño responsive** para diferentes tamaños de pantalla

### 📋 **Información Completa**

- **Datos del emisor**: Razón social, RNC, dirección, contacto
- **Datos del comprador**: Información completa del cliente
- **Información médica**: Aseguradora, NSS, médico, autorización (cuando aplica)
- **Desglose tributario**: Subtotal, ITBIS, exento, total
- **Lista de items**: Detalles completos con precios y cantidades
- **Información técnica**: Tipo eCF, versión, fechas, códigos

### 🔧 **Funcionalidades Avanzadas**

- **Vista previa mejorada** integrada
- **Generación automática de PDF**
- **Opciones de descarga y compartir**
- **Impresión directa**
- **Copia de ENCF al portapapeles**
- **Actualización de datos**

## 🗂️ Organización por Pestañas

### 1️⃣ **Pestaña "Detalles"**

Información completa organizada en tarjetas:

#### **📊 Información del Emisor**

- Razón social y nombre comercial
- RNC y datos de contacto
- Dirección completa
- Teléfono, email y website

#### **👤 Información del Comprador**

- Nombre o razón social
- RNC o cédula
- Dirección y contacto

#### **🏥 Información Médica** (cuando aplica)

- Aseguradora (ARS)
- Número de autorización
- NSS del paciente
- Médico tratante y cédula
- Monto de cobertura

#### **💰 Desglose Tributario**

- Monto gravado (subtotal)
- Monto exento
- ITBIS calculado
- Total de la factura

#### **📝 Detalles de Items**

- Lista completa de productos/servicios
- Referencia, descripción, cantidad
- Precio unitario y total por item
- Separación visual entre items

#### **⚙️ Información Técnica**

- Tipo de eCF y versión
- Fechas de emisión y vencimiento
- Código de seguridad
- Estado de envío a DGII

### 2️⃣ **Pestaña "PDF"**

Vista previa del documento generado:

#### **📄 Estado del PDF**

- Indicador visual del estado de generación
- Barra de progreso durante la creación
- Mensajes informativos claros

#### **🔍 Vista Previa Integrada**

- Visualización del PDF dentro de la app
- Zoom y navegación disponibles
- Calidad optimizada para pantalla

#### **🔄 Regeneración**

- Botón de reintento en caso de error
- Actualización automática al cambiar datos
- Manejo de errores con mensajes claros

### 3️⃣ **Pestaña "Acciones"**

Opciones disponibles para la factura:

#### **🎯 Acciones Principales**

- **Vista Previa Mejorada**: Abre el diálogo grande con opciones
- **Descargar PDF**: Acceso al visor completo con descarga
- **Imprimir**: Envío directo a impresora
- **Compartir**: Opciones de compartir por email/redes

#### **ℹ️ Información de Ayuda**

- Descripción de cada acción disponible
- Requisitos y limitaciones
- Tips de uso y mejores prácticas

## 🎨 Header Informativo

### **📊 Información Principal**

- **Tipo de Comprobante**: Badge con color específico
- **Estado**: Indicador visual (Enviado/Pendiente/Rechazado)
- **ENCF**: Número de comprobante fiscal
- **Número Interno**: Referencia interna del sistema
- **Cliente**: Nombre del comprador
- **Total**: Monto destacado con formato de moneda
- **Fecha**: Fecha de emisión formateada

### **🎨 Colores Adaptativos**

Los colores del header y badges se adaptan automáticamente según el tipo de comprobante:

| Tipo                 | Color Principal | Uso                            |
| -------------------- | --------------- | ------------------------------ |
| E31 (Crédito Fiscal) | Azul            | Facturas médicas/profesionales |
| E32 (Consumo)        | Verde           | Facturas de consumo general    |
| E33 (Nota Débito)    | Naranja         | Cargos adicionales             |
| E34 (Nota Crédito)   | Púrpura         | Devoluciones/descuentos        |
| E43 (Gastos Menores) | Rosa            | Gastos pequeños                |

## 🚀 Floating Action Buttons

### **👁️ Vista Previa (Azul)**

- Acceso directo a la vista previa mejorada
- Siempre disponible
- Abre el diálogo grande con opciones completas

### **📥 Descarga (Verde)**

- Disponible solo cuando el PDF está listo
- Abre el visor completo con opciones de descarga
- Se desactiva durante la generación del PDF

## 📱 AppBar Mejorado

### **📋 Información del Título**

- Título principal: "Detalles de Factura"
- Subtítulo: ENCF de la factura
- Diseño limpio y profesional

### **⚙️ Menú de Opciones**

- **Copiar ENCF**: Copia al portapapeles
- **Compartir**: Opciones de compartir
- **Actualizar**: Regenera el PDF y actualiza datos

### **🔍 Acceso Rápido**

- Botón de vista previa mejorada en el AppBar
- Acceso directo sin navegar por pestañas

## 🔧 Funcionalidades Técnicas

### **📄 Generación de PDF**

```dart
// Generación automática al cargar
Future<void> _generatePdf() async {
  setState(() => generatingPdf = true);

  try {
    final bytes = await _buildPdf(PdfPageFormat.a4, invoice);
    setState(() {
      pdfBytes = bytes;
      generatingPdf = false;
    });
  } catch (e) {
    // Manejo de errores
    setState(() => generatingPdf = false);
  }
}
```

### **🎨 Colores Dinámicos**

```dart
// Colores basados en el tipo de comprobante
Color _getStatusColor(ERPInvoice inv) {
  if (inv.linkOriginal?.isNotEmpty == true) return Colors.green;
  if (inv.fAnulada == true) return Colors.red;
  return Colors.orange;
}
```

### **📋 Copia al Portapapeles**

```dart
// Copia del ENCF
void _copyEncf(String encf) {
  Clipboard.setData(ClipboardData(text: encf));
  // Mostrar confirmación
}
```

## 🎯 Casos de Uso

### **1. Factura Médica Completa**

- Muestra información de aseguradora
- Datos del médico tratante
- NSS y número de autorización
- Monto de cobertura
- Detalles de servicios médicos

### **2. Factura de Consumo**

- Información básica del comprador
- Lista de productos comprados
- Desglose de impuestos
- Total de la compra

### **3. Nota de Crédito**

- Referencia a factura original
- Motivo de la devolución
- Montos negativos
- Proceso de reembolso

### **4. Gastos Menores**

- Información simplificada
- Montos pequeños
- Proceso rápido de visualización

## 📊 Comparación: Antes vs Ahora

| Aspecto           | Versión Anterior | Versión Mejorada                |
| ----------------- | ---------------- | ------------------------------- |
| **Organización**  | Una sola vista   | 3 pestañas organizadas          |
| **Información**   | Solo PDF         | Detalles completos + PDF        |
| **Diseño**        | Básico           | Moderno con colores adaptativos |
| **Acciones**      | Limitadas        | Múltiples opciones integradas   |
| **UX**            | Funcional        | Intuitiva y profesional         |
| **Datos Médicos** | No incluidos     | Sección especializada           |
| **Items**         | No detallados    | Lista completa con precios      |
| **Estado**        | No visible       | Indicadores visuales claros     |

## 🚀 Implementación

### **Navegación a la Pantalla**

```dart
// Desde la tabla de facturas
Get.toNamed(AppRoutes.INVOICE_PREVIEW, arguments: invoice);

// O con Navigator tradicional
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const InvoicePreviewScreen(),
    settings: RouteSettings(arguments: invoice),
  ),
);
```

### **Integración con Vista Previa Mejorada**

```dart
// Botón en el AppBar
IconButton(
  onPressed: () => showEnhancedInvoicePreview(
    context: context,
    invoice: invoice,
  ),
  icon: const Icon(Icons.visibility),
)
```

### **Personalización de Colores**

```dart
// En el tema de la app
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Color base
  ),
)
```

## 🔮 Próximas Mejoras

### **Funcionalidades Planificadas**

1. **Edición Inline**: Permitir editar ciertos campos
2. **Historial**: Ver versiones anteriores de la factura
3. **Comentarios**: Agregar notas y observaciones
4. **Adjuntos**: Subir documentos relacionados
5. **Workflow**: Estados de aprobación y revisión

### **Mejoras de UX**

1. **Animaciones**: Transiciones suaves entre pestañas
2. **Gestos**: Navegación por swipe
3. **Búsqueda**: Buscar dentro de los detalles
4. **Filtros**: Filtrar items por categoría
5. **Exportación**: Múltiples formatos de exportación

### **Integración Avanzada**

1. **Sincronización**: Actualización en tiempo real
2. **Colaboración**: Compartir con múltiples usuarios
3. **Analytics**: Métricas de visualización
4. **Notificaciones**: Alertas de cambios importantes

## 📞 Soporte y Mantenimiento

### **Debugging**

```dart
// Logs de debug incluidos
debugPrint('🔍 INVOICE PREVIEW DEBUG:');
debugPrint('🔍 encf: ${invoice.encf}');
debugPrint('🔍 tipoFacturaTitulo: ${invoice.tipoFacturaTitulo}');
```

### **Manejo de Errores**

- Estados de carga claros
- Mensajes de error descriptivos
- Opciones de reintento
- Fallbacks para datos faltantes

### **Performance**

- Carga lazy de pestañas
- Cache de PDF generado
- Optimización de imágenes
- Gestión eficiente de memoria

La nueva pantalla de detalles ofrece una experiencia completa y profesional para visualizar toda la información de una factura, con acceso fácil a todas las funcionalidades necesarias para el usuario final.
