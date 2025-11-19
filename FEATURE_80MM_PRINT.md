# 🖨️ Funcionalidad de Impresión 80mm

## ✅ Implementación Completada

Se ha agregado la funcionalidad de impresión para impresoras térmicas de 80mm (recibos) al sistema de facturación.

## 📋 Archivos Creados/Modificados

### Nuevos Archivos:

1. **`lib/services/receipt_80mm_pdf_service.dart`**
   - Servicio para generar PDFs optimizados para impresoras térmicas de 80mm
   - Formato de recibo compacto con toda la información esencial
   - Incluye QR code para verificación
   - Diseño optimizado para papel térmico

### Archivos Modificados:

1. **`lib/widgets/invoice_table.dart`**

   - Agregado callback `onPrint80mm`
   - Nuevo botón "Imprimir 80mm" con icono de recibo
   - Color naranja distintivo (#FF6F00)

2. **`lib/screens/home/home_controller.dart`**

   - Nuevo método `print80mmReceipt()`
   - Import del servicio de recibos 80mm y CompanyConfigService
   - Obtención automática de configuración de empresa desde Firestore
   - Conversión de ERPInvoice a Map para el servicio
   - Logs detallados de configuración de empresa

3. **`lib/screens/home/home_screen.dart`**
   - Conectado el callback `onPrint80mm` al InvoiceTable

## 🎯 Características del Recibo 80mm

### Información Incluida:

- ✅ Logo de la empresa (si está disponible)
- ✅ Información de la empresa (RNC, dirección)
- ✅ Número de factura y eCF
- ✅ Fecha de emisión y vencimiento
- ✅ Información del cliente (nombre, RNC/Cédula)
- ✅ Información de ARS (aseguradora, NSS, No. Autorización)
- ✅ Tipo de comprobante (título dinámico)
- ✅ Detalles individuales de cada ítem con:
  - Descripción del servicio/producto
  - Cantidad y precio unitario
  - Cobertura (si aplica)
  - Valor total del ítem
- ✅ Subtotal, ITBIS y Total
- ✅ QR Code para verificación
- ✅ Código de seguridad
- ✅ Fecha de firma
- ✅ Mensaje de políticas

### Formato Optimizado:

- Ancho: 80mm (formato estándar de impresoras térmicas)
- Fuente: 9-10pt (legible en papel térmico)
- Espaciado: Optimizado para reducir uso de papel
- Márgenes: 12px horizontal, 48px vertical

## 🚀 Uso

### Desde la Interfaz:

1. En el grid de facturas, busca el botón naranja con icono de recibo
2. Haz clic en "Imprimir 80mm"
3. Se generará el PDF optimizado para 80mm
4. Puedes ver la vista previa e imprimir directamente

### Desde el Código:

```dart
// En el HomeController
await controller.print80mmReceipt(invoice);

// El método automáticamente:
// 1. Obtiene la configuración de la empresa desde Firestore
// 2. Incluye logo, RNC, razón social y dirección
// 3. Parsea los detalles individuales de la factura
// 4. Genera el PDF optimizado para 80mm
```

## 🎨 Diseño del Botón

- **Icono:** `FontAwesomeIcons.receipt`
- **Color:** Naranja (#FF6F00)
- **Texto:** "Imprimir 80mm"
- **Posición:** Después del botón "Vista previa"

## 📊 Mapeo de Tipos de Comprobante

El recibo muestra automáticamente el tipo correcto según el código eCF:

- **E31:** CRÉDITO FISCAL ELECTRÓNICO
- **E32:** CONSUMO ELECTRÓNICO
- **E33:** NOTA DE DÉBITO ELECTRÓNICA
- **E34:** NOTA DE CRÉDITO ELECTRÓNICA
- **E41:** COMPRAS ELECTRÓNICO
- **E43:** GASTOS MENORES ELECTRÓNICO
- **B01-B04:** Comprobantes fiscales tradicionales
- Y más...

## 🔧 Configuración de Impresora

### Impresoras Compatibles:

- Impresoras térmicas de 80mm
- Impresoras POS estándar
- Cualquier impresora que soporte formato de 80mm

### Configuración Recomendada:

- Papel: Térmico 80mm
- Orientación: Vertical (Portrait)
- Márgenes: Mínimos
- Calidad: Alta (para QR code legible)

## 🐛 Solución de Problemas

### El QR no se escanea:

- Asegúrate de que la factura tenga `linkOriginal` configurado
- Verifica que la calidad de impresión sea alta
- El QR debe ser de al menos 100x100 puntos

### El texto se corta:

- Verifica que la impresora esté configurada para 80mm
- Ajusta los márgenes de la impresora
- Algunos textos largos se truncan automáticamente

### No se muestra el logo:

- Verifica que la empresa tenga `logoUrl` configurado en Firestore
- El sistema obtiene automáticamente la configuración de `CompanyConfigService`
- Revisa los logs en consola para ver qué configuración se está obteniendo
- El logo es opcional, el recibo funciona sin él

### No se muestran los datos de la empresa:

- Verifica que el usuario tenga una empresa asociada en Firestore
- Revisa la colección `companies/{rnc}` en Firestore
- El sistema usa `CompanyConfigService.getCompanyConfig()` automáticamente
- Si no hay configuración, usa valores por defecto

## 📝 Notas Técnicas

- El servicio usa `PdfPageFormat.roll80` para formato de rollo
- Los espacios en blanco al inicio/fin ayudan con el corte del papel
- El QR code es de 100x100 para balance entre tamaño y legibilidad
- Los montos se formatean automáticamente con "RD$" y separador de miles (ej: RD$ 2,000.50)
- Todos los valores monetarios (cobertura, subtotales, ITBIS, total) usan el mismo formato

## 🎉 Resultado

Ahora tienes un botón adicional en cada fila del grid de facturas que permite generar e imprimir recibos optimizados para impresoras térmicas de 80mm, perfectos para puntos de venta y entrega de comprobantes físicos a clientes.

---

**Fecha de Implementación:** $(date)
**Versión:** 1.0.0
