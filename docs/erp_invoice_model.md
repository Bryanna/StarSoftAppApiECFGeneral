# ERPInvoice Model Documentation

## Overview

The `ERPInvoice` model is a comprehensive data structure designed to handle invoice data directly from the Dominican Republic ERP system. It accepts all fields as they come from the API without transformation, ensuring maximum compatibility and data integrity.

## Key Features

### 1. Complete Field Coverage
- **180+ fields** mapped directly from the ERP API
- All fields are optional (`String?`) to handle missing data gracefully
- Supports both PascalCase (API format) and camelCase (legacy format) field names

### 2. Flexible JSON Parsing
```dart
// Handles both formats automatically
ERPInvoice.fromJson({
  'ENCF': 'E310000000002',           // API format
  'encf': 'E310000000002',           // Legacy format
  'FechaEmision': '01-04-2020',      // API format
  'fechaemision': '01-04-2020',      // Legacy format
});
```

### 3. Backward Compatibility
- Provides getters that match the old Invoice model interface
- `fDocumento`, `fTotal`, `fSubtotal`, `fItbis` etc.
- Seamless migration from legacy code

### 4. Smart Data Parsing
- **Date parsing**: Handles DD-MM-YYYY, DD/MM/YYYY, and ISO formats
- **Amount parsing**: Removes commas and spaces, converts to double
- **Null safety**: All operations handle null values gracefully

## Core Properties

### Essential Invoice Data
```dart
String get numeroFactura        // ENCF or internal number
String get clienteNombre        // Customer name
String get clienteRnc          // Customer tax ID
String get empresaNombre       // Company name
String get empresaRnc          // Company tax ID
```

### Financial Information
```dart
double get totalAmount         // Total amount as double
double get subtotalAmount      // Subtotal amount as double
double get itbisAmount         // Tax amount as double
double get exentoAmount        // Exempt amount as double
```

### Date Handling
```dart
DateTime? get fechaemisionDateTime      // Emission date
DateTime? get fechaVencimientoDateTime  // Due date
DateTime? get fechaHoraFirma           // Signature date/time
```

## Extensions (ERPInvoiceExtensions)

### Validation
```dart
bool get isValid              // Has required fields
bool get hasClient           // Has customer data
bool get hasAmount          // Has valid amount
```

### Formatting
```dart
String get formattedTotal           // "RD$ 1,234.56"
String get formattedSubtotal        // "RD$ 1,000.00"
String get formattedFechaEmision    // "01/04/2020"
```

### Display Helpers
```dart
String get displayTitle             // "E310000000002 - Client Name"
String get displaySubtitle          // "01/04/2020 • RD$ 1,234.56"
String get tipoComprobanteDisplay   // "Factura de Crédito Fiscal"
String get estadoDetallado          // "Procesada", "Vencida", etc.
```

### Search & Filtering
```dart
bool matchesSearch(String query)                    // Text search
bool isInDateRange(DateTime? start, DateTime? end)  // Date filtering
int compareByDate(ERPInvoice other)                // Date sorting
int compareByAmount(ERPInvoice other)              // Amount sorting
int compareByClient(ERPInvoice other)              // Client sorting
```

## Usage Examples

### Basic Creation
```dart
// From API response
final invoice = ERPInvoice.fromJson(apiResponse);

// Manual creation
final invoice = ERPInvoice(
  encf: 'E310000000002',
  fechaemision: '01-04-2020',
  razonsocialcomprador: 'Client Name',
  montototal: '1234.56',
);
```

### Display in UI
```dart
// List tile
ListTile(
  title: Text(invoice.displayTitle),
  subtitle: Text(invoice.displaySubtitle),
  trailing: Text(invoice.formattedTotal),
)

// Detailed view
Column(
  children: [
    Text('Número: ${invoice.numeroFactura}'),
    Text('Cliente: ${invoice.clienteNombre}'),
    Text('Fecha: ${invoice.formattedFechaEmision}'),
    Text('Total: ${invoice.formattedTotal}'),
    Text('Tipo: ${invoice.tipoComprobanteDisplay}'),
    Text('Estado: ${invoice.estadoDetallado}'),
  ],
)
```

### Filtering & Search
```dart
// Filter by search term
final filtered = invoices.where((invoice) =>
  invoice.matchesSearch(searchQuery)
).toList();

// Filter by date range
final inRange = invoices.where((invoice) =>
  invoice.isInDateRange(startDate, endDate)
).toList();

// Sort by date (newest first)
invoices.sort((a, b) => a.compareByDate(b));
```

## Field Mapping

### Key ERP Fields → Model Properties
| ERP Field | Model Property | Description |
|-----------|----------------|-------------|
| `ENCF` | `encf` | Electronic invoice number |
| `FechaEmision` | `fechaemision` | Emission date |
| `RNCEmisor` | `rncemisor` | Company tax ID |
| `RazonSocialEmisor` | `razonsocialemisor` | Company name |
| `RNCComprador` | `rnccomprador` | Customer tax ID |
| `RazonSocialComprador` | `razonsocialcomprador` | Customer name |
| `MontoTotal` | `montototal` | Total amount |
| `MontoGravadoTotal` | `montogravadototal` | Taxable amount |
| `TotalITBIS` | `totalitbis` | Tax amount |
| `TipoeCF` | `tipoecf` | Document type |

## Document Types (TipoeCF)
- `31`: Factura de Crédito Fiscal
- `32`: Factura de Consumo
- `33`: Nota de Débito
- `34`: Nota de Crédito
- `41`: Compras
- `43`: Gastos Menores
- `44`: Regímenes Especiales
- `45`: Gubernamental

## Testing

Comprehensive test suite covers:
- JSON parsing (API and legacy formats)
- Date parsing (multiple formats)
- Amount parsing (with commas, spaces)
- Null safety
- Search functionality
- Date range filtering
- Currency formatting
- Document type display

Run tests:
```bash
flutter test test/models/erp_invoice_test.dart
```

## Migration from Legacy Invoice Model

The ERPInvoice model provides full backward compatibility:

```dart
// Old code still works
final documento = invoice.fDocumento;  // ✅ Works
final total = invoice.fTotal;          // ✅ Works
final subtotal = invoice.fSubtotal;    // ✅ Works

// New code is more explicit
final documento = invoice.numeroFactura;  // ✅ Better
final total = invoice.formattedTotal;     // ✅ Better
final subtotal = invoice.formattedSubtotal; // ✅ Better
```

## Performance Considerations

- **Lazy parsing**: Dates and amounts are parsed on-demand
- **Null safety**: No exceptions for missing fields
- **Memory efficient**: Optional fields don't consume memory when null
- **Fast search**: String operations optimized for common use cases

## Future Enhancements

Potential improvements:
1. **Caching**: Cache parsed dates/amounts for repeated access
2. **Validation**: Add business rule validation
3. **Serialization**: Add `toJson()` method for API updates
4. **Localization**: Support multiple currencies and date formats
5. **Indexing**: Add search indexing for large datasets
