# Módulo Portable de PDFs

Este módulo contiene generadores de PDF desacoplados del resto del proyecto para que puedas copiarlos a otro repositorio sin dependencias internas.

## Contenido

- `enhanced_invoice_pdf.dart`: Generador de factura desde `Map<String, dynamic>` con encabezado, datos compactos, tabla de ítems y totales.
- `custom_pdf_service.dart`: Generador basado en plantilla visual con elementos posicionados (`PdfElement`).
- `pdf_element.dart`: Modelo mínimo para elementos de plantilla (`text`, `logo`, `line`, `rect`).

## Dependencias requeridas (pubspec.yaml)

- `pdf: ^3.10.8` (o la versión que uses)
- `printing: ^5.14.2`
- `intl: ^0.19.0`

## Uso Rápido

### Factura mejorada (datos en Map)

```dart
import 'package:pdf/pdf.dart';
import 'lib/pdf_portable/enhanced_invoice_pdf.dart';

final invoice = {
  'ENCF': 'E310000000000',
  'NumeroFacturaInterna': 'F-001',
  'FechaEmision': '2025-11-06',
  'RazonSocialComprador': 'Juan Pérez',
  'RNCComprador': '00123456789',
  'detalle_factura': [
    {'descripcion': 'Consulta', 'cantidad': 1, 'precio': 1000.0, 'monto': 1000.0},
  ],
  'TotalITBIS': 180.0,
  'MontoTotal': 1180.0,
};

final company = {
  'razonSocial': 'Mi Empresa SRL',
  'rnc': '131243932',
  'direccion': 'Calle Real 138, Santiago',
  'telefono': '809-555-1234',
  'logoUrl': 'https://mi-servidor/logo.png',
};

final bytes = await EnhancedInvoicePdf.buildPdf(
  PdfPageFormat.a4,
  invoice,
  companyConfig: company,
  userDisplayName: 'Operador',
);
```

### Plantillas personalizadas

```dart
import 'package:pdf/pdf.dart';
import 'lib/pdf_portable/custom_pdf_service.dart';
import 'lib/pdf_portable/pdf_element.dart';

final template = [
  PdfElement(
    type: PdfElementType.logo,
    x: 24,
    y: 24,
    width: 100,
    height: 50,
  ),
  PdfElement(
    type: PdfElementType.text,
    x: 24,
    y: 90,
    width: 300,
    height: 20,
    text: 'Factura Nº {NumeroFacturaInterna}',
    fontSize: 14,
    bold: true,
    color: '#005285',
  ),
];

final data = {
  'NumeroFacturaInterna': 'F-001',
};

final bytes = await CustomPdfServicePortable.generate(
  template: template,
  data: data,
  format: PdfPageFormat.a4,
  companyConfig: company,
);
```

## Integración en otro proyecto

1. Copia la carpeta `lib/pdf_portable/` al proyecto destino.
2. Asegura las dependencias en `pubspec.yaml` (`pdf`, `printing`, `intl`).
3. Llama a los servicios desde tu UI y usa `printing` para vista previa/impresión:
   - `await Printing.layoutPdf(onLayout: (_) async => bytes);`
   - o usa tu propio visor/preview.

## Notas

- Ambos servicios aceptan `logoUrl` o `logoBytes` para el logo.
- Los campos del `invoice` son flexibles, con compatibilidad para claves comunes (`DetalleFactura`, `detalle_factura`, `items`, etc.).
- No dependen de `GetX` ni servicios internos, por lo que puedes usarlos en cualquier Flutter/Dart app.