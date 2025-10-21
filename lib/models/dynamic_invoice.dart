import 'schema_definition.dart';

/// Factura con estructura dinámica basada en esquema
class DynamicInvoice {
  final Map<String, dynamic> _data;
  final DataSchema _schema;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  DynamicInvoice({
    required DataSchema schema,
    Map<String, dynamic>? data,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : _schema = schema,
       _data = data ?? {},
       id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Obtiene el esquema asociado
  DataSchema get schema => _schema;

  /// Obtiene todos los datos como mapa
  Map<String, dynamic> get data => Map.unmodifiable(_data);

  /// Obtiene un campo específico con tipo seguro
  T? getField<T>(String key) {
    final value = _data[key];
    if (value == null) return null;

    try {
      return value as T;
    } catch (e) {
      // Intentar conversión automática
      return _convertValue<T>(value, key);
    }
  }

  /// Establece un campo con validación
  void setField(String key, dynamic value) {
    final fieldDef = _schema.allFields.firstWhere(
      (field) => field.key == key,
      orElse: () => throw Exception('Campo no definido en esquema: $key'),
    );

    // Validar el valor
    final validatedValue = _validateAndConvert(value, fieldDef);
    _data[key] = validatedValue;
  }

  /// Establece múltiples campos
  void setFields(Map<String, dynamic> fields) {
    fields.forEach((key, value) {
      setField(key, value);
    });
  }

  /// Valida toda la factura según el esquema
  List<ValidationError> validate() {
    final errors = <ValidationError>[];

    for (final field in _schema.allFields) {
      final value = _data[field.key];

      // Verificar campos requeridos
      if (field.required && (value == null || value.toString().isEmpty)) {
        errors.add(
          ValidationError(
            field: field.key,
            message: '${field.displayName} es requerido',
          ),
        );
        continue;
      }

      // Validar tipo y formato si hay valor
      if (value != null) {
        final fieldErrors = _validateFieldValue(value, field);
        errors.addAll(fieldErrors);
      }
    }

    return errors;
  }

  /// Convierte a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schemaId': _schema.id,
      'data': _data,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crea desde JSON
  static DynamicInvoice fromJson(Map<String, dynamic> json, DataSchema schema) {
    return DynamicInvoice(
      schema: schema,
      data: json['data'],
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Crea desde datos externos (ERP)
  static DynamicInvoice fromExternalData(
    Map<String, dynamic> externalData,
    DataSchema schema,
  ) {
    final invoice = DynamicInvoice(schema: schema);

    // Mapear campos externos a campos del esquema
    for (final field in schema.allFields) {
      final externalValue = _findExternalValue(externalData, field.key);
      if (externalValue != null) {
        try {
          invoice.setField(field.key, externalValue);
        } catch (e) {
          // Log error pero continúa con otros campos
          print('Error mapeando campo ${field.key}: $e');
        }
      }
    }

    return invoice;
  }

  // Métodos de conveniencia para campos comunes
  String get invoiceNumber => getField<String>('invoice_number') ?? '';
  String get clientName => getField<String>('client_name') ?? '';
  double get totalAmount => getField<double>('total_amount') ?? 0.0;
  DateTime? get invoiceDate {
    final dateStr = getField<String>('invoice_date');
    if (dateStr != null) {
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Métodos privados de validación y conversión
  T? _convertValue<T>(dynamic value, String key) {
    final fieldDef = _schema.allFields.firstWhere(
      (field) => field.key == key,
      orElse: () => throw Exception('Campo no encontrado: $key'),
    );

    switch (fieldDef.type) {
      case FieldDataType.string:
        return value.toString() as T;
      case FieldDataType.number:
        return int.tryParse(value.toString()) as T?;
      case FieldDataType.decimal:
        return double.tryParse(value.toString()) as T?;
      case FieldDataType.boolean:
        if (value is bool) return value as T;
        return (value.toString().toLowerCase() == 'true') as T;
      case FieldDataType.date:
        if (value is DateTime) return value as T;
        return DateTime.tryParse(value.toString()) as T?;
      default:
        return value as T?;
    }
  }

  dynamic _validateAndConvert(dynamic value, FieldDefinition field) {
    // Aplicar valor por defecto si es null
    if (value == null && field.defaultValue != null) {
      value = field.defaultValue;
    }

    // Validar valores permitidos
    if (field.allowedValues != null &&
        !field.allowedValues!.contains(value.toString())) {
      throw ValidationException(
        'Valor no permitido para ${field.displayName}: $value',
      );
    }

    // Convertir según tipo
    switch (field.type) {
      case FieldDataType.string:
        return value.toString();
      case FieldDataType.number:
        final parsed = int.tryParse(value.toString());
        if (parsed == null) {
          throw ValidationException(
            '${field.displayName} debe ser un número entero',
          );
        }
        return parsed;
      case FieldDataType.decimal:
        final parsed = double.tryParse(value.toString());
        if (parsed == null) {
          throw ValidationException(
            '${field.displayName} debe ser un número decimal',
          );
        }
        return parsed;
      case FieldDataType.boolean:
        if (value is bool) return value;
        return value.toString().toLowerCase() == 'true';
      case FieldDataType.date:
        if (value is DateTime) return value.toIso8601String();
        final parsed = DateTime.tryParse(value.toString());
        if (parsed == null) {
          throw ValidationException(
            '${field.displayName} debe ser una fecha válida',
          );
        }
        return parsed.toIso8601String();
      default:
        return value;
    }
  }

  List<ValidationError> _validateFieldValue(
    dynamic value,
    FieldDefinition field,
  ) {
    final errors = <ValidationError>[];

    // Validaciones personalizadas
    if (field.validation != null) {
      final validation = field.validation!;

      // Longitud mínima/máxima para strings
      if (field.type == FieldDataType.string) {
        final str = value.toString();
        if (validation['minLength'] != null &&
            str.length < validation['minLength']) {
          errors.add(
            ValidationError(
              field: field.key,
              message:
                  '${field.displayName} debe tener al menos ${validation['minLength']} caracteres',
            ),
          );
        }
        if (validation['maxLength'] != null &&
            str.length > validation['maxLength']) {
          errors.add(
            ValidationError(
              field: field.key,
              message:
                  '${field.displayName} no puede tener más de ${validation['maxLength']} caracteres',
            ),
          );
        }
      }

      // Rango para números
      if (field.type == FieldDataType.number ||
          field.type == FieldDataType.decimal) {
        final num = double.tryParse(value.toString());
        if (num != null) {
          if (validation['min'] != null && num < validation['min']) {
            errors.add(
              ValidationError(
                field: field.key,
                message:
                    '${field.displayName} debe ser mayor o igual a ${validation['min']}',
              ),
            );
          }
          if (validation['max'] != null && num > validation['max']) {
            errors.add(
              ValidationError(
                field: field.key,
                message:
                    '${field.displayName} debe ser menor o igual a ${validation['max']}',
              ),
            );
          }
        }
      }
    }

    return errors;
  }

  static dynamic _findExternalValue(Map<String, dynamic> data, String key) {
    // Buscar el valor en diferentes formatos de clave
    final variations = [
      key,
      key.toLowerCase(),
      key.toUpperCase(),
      _camelToSnake(key),
      _snakeToCamel(key),
    ];

    for (final variation in variations) {
      if (data.containsKey(variation)) {
        return data[variation];
      }
    }

    return null;
  }

  static String _camelToSnake(String camel) {
    return camel.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }

  static String _snakeToCamel(String snake) {
    return snake.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (match) => match.group(1)!.toUpperCase(),
    );
  }
}

/// Error de validación
class ValidationError {
  final String field;
  final String message;

  const ValidationError({required this.field, required this.message});

  @override
  String toString() => '$field: $message';
}

/// Excepción de validación
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
