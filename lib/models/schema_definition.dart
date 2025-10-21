/// Tipos de datos soportados
enum FieldDataType { string, number, decimal, date, boolean, array, object }

/// Definición de un campo en el esquema
class FieldDefinition {
  final String key; // Clave en el JSON (ej: "patient_name")
  final String displayName; // Nombre para mostrar (ej: "Nombre del Paciente")
  final FieldDataType type; // Tipo de dato
  final bool required; // Si es obligatorio
  final String? defaultValue; // Valor por defecto
  final List<String>? allowedValues; // Valores permitidos (para enums)
  final String? format; // Formato específico (ej: "dd/MM/yyyy" para fechas)
  final String? description; // Descripción del campo
  final Map<String, dynamic>? validation; // Reglas de validación

  const FieldDefinition({
    required this.key,
    required this.displayName,
    required this.type,
    this.required = false,
    this.defaultValue,
    this.allowedValues,
    this.format,
    this.description,
    this.validation,
  });

  factory FieldDefinition.fromJson(Map<String, dynamic> json) {
    return FieldDefinition(
      key: json['key'],
      displayName: json['displayName'],
      type: FieldDataType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FieldDataType.string,
      ),
      required: json['required'] ?? false,
      defaultValue: json['defaultValue'],
      allowedValues: json['allowedValues']?.cast<String>(),
      format: json['format'],
      description: json['description'],
      validation: json['validation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'displayName': displayName,
      'type': type.name,
      'required': required,
      'defaultValue': defaultValue,
      'allowedValues': allowedValues,
      'format': format,
      'description': description,
      'validation': validation,
    };
  }
}

/// Esquema completo de datos para una industria/negocio
class DataSchema {
  final String id;
  final String name;
  final String description;
  final String industry; // "medical", "retail", "manufacturing", etc.
  final List<FieldDefinition> invoiceFields;
  final List<FieldDefinition> itemFields;
  final List<FieldDefinition> clientFields;
  final List<FieldDefinition> companyFields;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DataSchema({
    required this.id,
    required this.name,
    required this.description,
    required this.industry,
    required this.invoiceFields,
    required this.itemFields,
    required this.clientFields,
    required this.companyFields,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory DataSchema.fromJson(Map<String, dynamic> json) {
    return DataSchema(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      industry: json['industry'],
      invoiceFields: (json['invoiceFields'] as List)
          .map((e) => FieldDefinition.fromJson(e))
          .toList(),
      itemFields: (json['itemFields'] as List)
          .map((e) => FieldDefinition.fromJson(e))
          .toList(),
      clientFields: (json['clientFields'] as List)
          .map((e) => FieldDefinition.fromJson(e))
          .toList(),
      companyFields: (json['companyFields'] as List)
          .map((e) => FieldDefinition.fromJson(e))
          .toList(),
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'industry': industry,
      'invoiceFields': invoiceFields.map((e) => e.toJson()).toList(),
      'itemFields': itemFields.map((e) => e.toJson()).toList(),
      'clientFields': clientFields.map((e) => e.toJson()).toList(),
      'companyFields': companyFields.map((e) => e.toJson()).toList(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Obtiene todos los campos como una lista plana
  List<FieldDefinition> get allFields {
    return [...invoiceFields, ...itemFields, ...clientFields, ...companyFields];
  }

  /// Busca un campo por su clave
  FieldDefinition? getField(String key) {
    return allFields.firstWhere(
      (field) => field.key == key,
      orElse: () => throw Exception('Campo no encontrado: $key'),
    );
  }
}
