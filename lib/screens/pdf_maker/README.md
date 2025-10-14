# PDF Maker - Editor Visual de Plantillas de Factura

## 🎨 Descripción

El **PDF Maker** es un editor visual completo que permite a los usuarios crear plantillas personalizadas para sus facturas PDF. Con una interfaz intuitiva de arrastrar y soltar, los usuarios pueden diseñar facturas únicas que reflejen la identidad de su empresa.

## ✨ Características Principales

### 🛠️ **Panel de Herramientas**
- **Elementos Básicos**: Texto, Logo, Líneas, Rectángulos
- **Datos de Factura**: Número, Fecha, Cliente, Total
- **Datos de Empresa**: Razón Social, RNC, Dirección, Teléfono
- **Tablas**: Productos y Totales

### 🎯 **Editor Visual**
- Canvas A4 con vista previa en tiempo real
- Arrastrar y soltar elementos
- Selección y edición visual
- Indicadores de posición y tamaño

### ⚙️ **Panel de Propiedades**
- **Posición**: Coordenadas X, Y precisas
- **Tamaño**: Ancho y alto personalizables
- **Contenido**: Edición de texto en tiempo real
- **Estilo**: Fuente, tamaño, negrita
- **Color**: Texto, fondo y bordes
- **Alineación**: Herramientas de alineación automática

## 🚀 Funcionalidades

### 📝 **Elementos Disponibles**

#### Elementos Básicos
- **Texto**: Texto libre personalizable
- **Logo**: Imagen de la empresa (automática desde configuración)
- **Línea**: Separadores visuales
- **Rectángulo**: Cajas y fondos

#### Datos Dinámicos
- **{invoice_number}**: Número de factura automático
- **{date}**: Fecha de emisión
- **{client_name}**: Nombre del cliente
- **{total}**: Monto total
- **{company_name}**: Razón social
- **{company_rnc}**: RNC de la empresa
- **{company_address}**: Dirección
- **{company_phone}**: Teléfono

#### Tablas Especiales
- **Tabla de Productos**: Lista automática de items
- **Tabla de Totales**: Subtotal, ITBIS, Total

### 💾 **Gestión de Plantillas**
- **Guardar**: Almacenamiento local y en la nube
- **Cargar**: Recuperar plantillas guardadas
- **Vista Previa**: Generación de PDF en tiempo real
- **Plantilla por Defecto**: Diseño inicial profesional

### 🎨 **Personalización Avanzada**
- **Colores**: Paleta completa de colores
- **Tipografía**: Tamaños y estilos de fuente
- **Posicionamiento**: Control pixel-perfect
- **Alineación**: Herramientas de alineación automática

## 📱 Interfaz Responsiva

### 💻 **Vista Desktop (>1200px)**
- Panel de herramientas (izquierda)
- Editor visual (centro)
- Panel de propiedades (derecha)

### 📱 **Vista Móvil/Tablet**
- Interfaz con pestañas
- Navegación optimizada para touch
- Todos los controles accesibles

## 🔧 Uso del Sistema

### 1. **Acceso**
- Ir al menú principal → "PDF Maker"
- Se carga automáticamente la última plantilla guardada

### 2. **Agregar Elementos**
- Seleccionar elemento del panel de herramientas
- Hacer clic para agregarlo al canvas
- Arrastrar para posicionar

### 3. **Editar Propiedades**
- Seleccionar elemento en el canvas
- Usar panel de propiedades para personalizar
- Cambios se reflejan en tiempo real

### 4. **Guardar y Previsualizar**
- **Guardar**: Icono de guardar en la barra superior
- **Vista Previa**: Icono de preview para generar PDF

## 🔄 Integración con el Sistema

### 📊 **Datos Automáticos**
- Se conecta con la configuración de empresa
- Obtiene datos del usuario logueado
- Integra con el sistema de facturas existente

### 🎯 **Variables Dinámicas**
Todas las variables se reemplazan automáticamente:
```
{invoice_number} → F-001
{date} → 15/12/2024
{client_name} → Juan Pérez
{total} → $1,500.00
{company_name} → Mi Empresa S.A.
```

### 💾 **Almacenamiento**
- **Local**: GetStorage para acceso rápido
- **Nube**: Firestore para sincronización
- **Backup**: Automático al guardar

## 🎨 Casos de Uso

### 🏢 **Empresa Corporativa**
- Logo prominente en la esquina superior
- Colores corporativos
- Información completa de contacto
- Tabla detallada de productos

### 🏥 **Clínica Médica**
- Diseño limpio y profesional
- Información del paciente destacada
- Detalles de servicios médicos
- Totales claros y visibles

### 🛍️ **Comercio Retail**
- Diseño colorido y atractivo
- Lista de productos con imágenes
- Promociones y descuentos
- Información de garantía

## 🔮 Funcionalidades Futuras

- **Plantillas Prediseñadas**: Biblioteca de diseños profesionales
- **Importar/Exportar**: Compartir plantillas entre usuarios
- **Elementos Avanzados**: Gráficos, códigos QR, firmas digitales
- **Colaboración**: Edición en equipo
- **Versionado**: Historial de cambios
- **Temas**: Modo oscuro y claro

## 🛡️ Seguridad y Privacidad

- **Datos Locales**: Plantillas guardadas localmente
- **Sincronización Segura**: Encriptación en tránsito
- **Acceso Controlado**: Solo usuarios autenticados
- **Backup Automático**: Prevención de pérdida de datos

---

**PDF Maker** transforma la creación de facturas de un proceso técnico a una experiencia visual e intuitiva, permitiendo que cada empresa tenga facturas únicas que reflejen su identidad profesional.
