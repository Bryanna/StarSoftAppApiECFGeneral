# Configuración de Endpoints ERP

## Resumen de Cambios

Se ha mejorado la configuración del sistema para permitir una gestión más flexible de los endpoints del ERP. Ahora puedes configurar una URL base y múltiples endpoints específicos.

## Nuevas Características

### 1. URL Base del ERP

- Campo para configurar la URL base de tu sistema ERP
- Ejemplo: `https://cempsavid.duckdns.org/api`
- Se combina automáticamente with los endpoints específicos

### 2. Endpoints Específicos

- Configuración de múltiples endpoints por nombre
- Cada endpoint tiene su propia ruta
- URLs completas generadas automáticamente

### 3. Gestión Dinámica

- Agregar nuevos endpoints desde la interfaz
- Editar rutas de endpoints existentes
- Eliminar endpoints no necesarios
- Vista previa de URLs completas

## Configuración por Defecto

El sistema viene preconfigurado con estos endpoints:

```json
{
  "baseERPUrl": "https://cempsavid.duckdns.org/api",
  "erpEndpoints": {
    "ars": "/ars/full",
    "ars_alt": "/ars/full",
    "invoices": "/invoices",
    "clients": "/clients",
    "products": "/products"
  }
}
```

## URLs Generadas

Con la configuración por defecto, se generan estas URLs:

- **ARS**: `https://cempsavid.duckdns.org/api/ars/full`
- **ARS Alt**: `https://cempsavid.duckdns.org/api/ars/full`
- **Invoices**: `https://cempsavid.duckdns.org/api/invoices`
- **Clients**: `https://cempsavid.duckdns.org/api/clients`
- **Products**: `https://cempsavid.duckdns.org/api/products`

## Cómo Usar

### 1. Configurar URL Base

1. Ve a **Configuración del Sistema**
2. En la sección **Configuración API**
3. Introduce tu URL base en **URL Base del ERP**

### 2. Agregar Endpoints

1. En la sección **Endpoints del ERP**
2. Haz clic en **Agregar**
3. Introduce el nombre y la ruta del endpoint
4. La URL completa se genera automáticamente

### 3. Editar Endpoints

1. Encuentra el endpoint en la lista
2. Modifica la ruta directamente en el campo de texto
3. La URL completa se actualiza en tiempo real

### 4. Eliminar Endpoints

1. Haz clic en el ícono de eliminar (🗑️) junto al endpoint
2. El endpoint se elimina inmediatamente

## Ejemplo de Código

```dart
// Obtener la URL completa de un endpoint
final controller = Get.find<ConfiguracionController>();
final arsUrl = controller.getFullEndpointUrl('ars');
// Resultado: https://cempsavid.duckdns.org/api/ars/full

// Agregar un nuevo endpoint
controller.addEndpoint('payments', '/payments/list');

// Actualizar un endpoint existente
controller.updateEndpoint('ars', '/ars/updated');

// Eliminar un endpoint
controller.removeEndpoint('ars_alt');
```

## Almacenamiento

La configuración se guarda automáticamente en Firebase Firestore:

```json
{
  "companies/{companyRnc}": {
    "baseERPUrl": "https://cempsavid.duckdns.org/api",
    "erpEndpoints": {
      "ars": "/ars/full",
      "ars_alt": "/ars/full",
      "invoices": "/invoices",
      "clients": "/clients",
      "products": "/products"
    }
  }
}
```

## Compatibilidad

- ✅ Compatible con la configuración existente
- ✅ Los endpoints legacy siguen funcionando
- ✅ Migración automática de configuraciones anteriores
- ✅ No requiere cambios en el código existente

## Archivos Modificados

### Controlador

- `lib/screens/configuracion/configuracion_controller.dart`
  - Agregado `baseERPUrl` y `erpEndpoints`
  - Nuevos métodos para gestión de endpoints
  - Controllers para edición de endpoints
  - Persistencia en Firebase

### Pantalla

- `lib/screens/configuracion/configuracion_screen.dart`
  - Nueva sección `_ERPEndpointsConfigSection`
  - Interfaz para agregar/editar/eliminar endpoints
  - Vista previa de URLs completas
  - Validación de entrada

### Ejemplo

- `example/erp_endpoints_usage.dart`
  - Ejemplo completo de uso
  - Casos de prueba
  - Demostración de funcionalidades

## Beneficios

1. **Flexibilidad**: Configura múltiples endpoints fácilmente
2. **Mantenibilidad**: Cambiar la URL base actualiza todos los endpoints
3. **Escalabilidad**: Agregar nuevos endpoints sin modificar código
4. **Visibilidad**: Ver las URLs completas antes de usar
5. **Validación**: Verificar configuración antes de guardar

## Próximos Pasos

1. Probar la configuración con tu ERP
2. Agregar endpoints específicos según tus necesidades
3. Validar que las URLs generadas sean correctas
4. Implementar llamadas HTTP usando las URLs configuradas

## 🔧 Solución a Problemas Reportados

### ❌ Problema Original:

- Los TextField no permitían escribir
- No había guardado automático de endpoints
- Falta de feedback visual al usuario

### ✅ Solución Implementada:

#### 1. **Guardado Automático**

```dart
// Timer que guarda después de 1 segundo de inactividad
void _saveEndpointsWithDelay() {
  _saveTimer?.cancel();
  _saveTimer = Timer(const Duration(milliseconds: 1000), () {
    _saveEndpointsToFirebase();
  });
}
```

#### 2. **TextField Funcionales**

```dart
// GetBuilder para actualizar la UI correctamente
GetBuilder<ConfiguracionController>(
  builder: (c) {
    return TextField(
      controller: c.endpointControllers[entry.key],
      onChanged: (value) {
        c.updateEndpoint(entry.key, value); // Guarda automáticamente
      },
    );
  },
)
```

#### 3. **Indicadores Visuales**

- ✅ Icono de guardado en cada TextField
- ✅ Notificación "Los cambios se guardan automáticamente"
- ✅ Snackbars de confirmación al agregar endpoints
- ✅ Validación de nombres duplicados

#### 4. **Flujo de Guardado**

1. Usuario escribe en TextField
2. Se llama `updateEndpoint()`
3. Se inicia timer de 1 segundo
4. Si no hay más cambios, se guarda en Firebase
5. Variables locales se actualizan

## 📱 Cómo Usar Ahora

### Agregar Endpoint:

1. Clic en "Agregar"
2. Escribe nombre y ruta
3. Clic "Agregar" → Se guarda automáticamente

### Editar Endpoint:

1. Escribe directamente en el TextField
2. Espera 1 segundo → Se guarda automáticamente
3. Ver confirmación visual (icono verde)

### URL Base:

1. Modifica el campo "URL Base del ERP"
2. Se combina automáticamente con endpoints
3. URLs completas se actualizan en tiempo real

## 🎯 Resultado Final

- ✅ TextField completamente funcionales
- ✅ Guardado automático sin intervención del usuario
- ✅ Feedback visual claro
- ✅ Validación de datos
- ✅ URLs generadas en tiempo real
- ✅ Compatible con configuración existente
