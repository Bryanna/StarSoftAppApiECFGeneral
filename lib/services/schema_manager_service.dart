import 'package:flutter/foundation.dart';
import '../models/schema_definition.dart';
import '../models/dynamic_invoice.dart';
import 'firestore_service.dart';
import 'firebase_auth_service.dart';

class SchemaManagerService {
  final FirestoreService _db = FirestoreService();
  final FirebaseAuthService _auth = FirebaseAuthService();

  static const String _schemasCollection = 'schemas';
  static const String _userSchemasCollection = 'user_schemas';

  /// Guarda un esquema personalizado
  Future<void> saveSchema(DataSchema schema) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Usuario no autenticado');

      await _db.doc('$_userSchemasCollection/$uid/schemas/${schema.id}').set({
        ...schema.toJson(),
        'userId': uid,
      });

      debugPrint('Esquema guardado: ${schema.name}');
    } catch (e) {
      debugPrint('Error guardando esquema: $e');
      rethrow;
    }
  }

  /// Obtiene todos los esquemas del usuario
  Future<List<DataSchema>> getUserSchemas() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return [];

      final snapshot = await _db
          .collection('$_userSchemasCollection/$uid/schemas')
          .get();

      return snapshot.docs
          .map((doc) => DataSchema.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo esquemas: $e');
      return [];
    }
  }

  /// Obtiene un esquema específico
  Future<DataSchema?> getSchema(String schemaId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _db
          .doc('$_userSchemasCollection/$uid/schemas/$schemaId')
          .get();

      if (doc.exists) {
        return DataSchema.fromJson(doc.data()!);
      }

      // Si no existe en esquemas de usuario, buscar en esquemas predefinidos
      return await _getPredefinedSchema(schemaId);
    } catch (e) {
      debugPrint('Error obteniendo esquema $schemaId: $e');
      return null;
    }
  }

  /// Elimina un esquema
  Future<void> deleteSchema(String schemaId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Usuario no autenticado');

      await _db.doc('$_userSchemasCollection/$uid/schemas/$schemaId').delete();

      debugPrint('Esquema eliminado: $schemaId');
    } catch (e) {
      debugPrint('Error eliminando esquema: $e');
      rethrow;
    }
  }

  /// Obtiene esquemas predefinidos por industria
  Future<List<DataSchema>> getPredefinedSchemas() async {
    try {
      final snapshot = await _db.collection(_schemasCollection).get();
      return snapshot.docs
          .map((doc) => DataSchema.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo esquemas predefinidos: $e');
      return _getBuiltInSchemas();
    }
  }

  /// Crea un esquema desde datos de ejemplo del ERP
  Future<DataSchema> createSchemaFromSample(
    String name,
    String industry,
    Map<String, dynamic> sampleData,
  ) async {
    try {
      final fields = <FieldDefinition>[];

      // Analizar la estructura del JSON de ejemplo si hay datos
      if (sampleData.isNotEmpty) {
        _analyzeJsonStructure(sampleData, fields, '');
      }

      // Si no hay campos analizados, crear campos básicos
      if (fields.isEmpty) {
        fields.addAll(_getBasicFieldsForIndustry(industry));
      }

      final schema = DataSchema(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.isNotEmpty ? name : 'Esquema Personalizado',
        description: sampleData.isNotEmpty
            ? 'Esquema generado automáticamente desde datos de ejemplo'
            : 'Esquema personalizado creado manualmente',
        industry: industry.isNotEmpty ? industry : 'other',
        invoiceFields: fields.where((f) => _isInvoiceField(f.key)).toList(),
        itemFields: fields.where((f) => _isItemField(f.key)).toList(),
        clientFields: fields.where((f) => _isClientField(f.key)).toList(),
        companyFields: fields.where((f) => _isCompanyField(f.key)).toList(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await saveSchema(schema);
      debugPrint('Esquema creado exitosamente: ${schema.id} - ${schema.name}');
      return schema;
    } catch (e) {
      debugPrint('Error en createSchemaFromSample: $e');
      rethrow;
    }
  }

  /// Valida datos externos contra un esquema
  Future<List<ValidationError>> validateExternalData(
    Map<String, dynamic> externalData,
    String schemaId,
  ) async {
    final schema = await getSchema(schemaId);
    if (schema == null) {
      return [
        ValidationError(field: 'schema', message: 'Esquema no encontrado'),
      ];
    }

    final invoice = DynamicInvoice.fromExternalData(externalData, schema);
    return invoice.validate();
  }

  /// Convierte datos externos a formato interno usando esquema
  Future<DynamicInvoice?> mapExternalData(
    Map<String, dynamic> externalData,
    String schemaId,
  ) async {
    final schema = await getSchema(schemaId);
    if (schema == null) return null;

    return DynamicInvoice.fromExternalData(externalData, schema);
  }

  // Métodos privados

  Future<DataSchema?> _getPredefinedSchema(String schemaId) async {
    try {
      final doc = await _db.doc('$_schemasCollection/$schemaId').get();
      if (doc.exists) {
        return DataSchema.fromJson(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error obteniendo esquema predefinido: $e');
    }

    // Fallback a esquemas built-in
    try {
      return _getBuiltInSchemas().firstWhere((schema) => schema.id == schemaId);
    } catch (e) {
      debugPrint('Esquema no encontrado en built-in: $schemaId');
      return null;
    }
  }

  void _analyzeJsonStructure(
    dynamic data,
    List<FieldDefinition> fields,
    String prefix,
  ) {
    if (data is Map<String, dynamic>) {
      data.forEach((key, value) {
        final fullKey = prefix.isEmpty ? key : '${prefix}_$key';

        if (value is Map<String, dynamic>) {
          _analyzeJsonStructure(value, fields, fullKey);
        } else if (value is List) {
          if (value.isNotEmpty && value.first is Map<String, dynamic>) {
            _analyzeJsonStructure(value.first, fields, fullKey);
          }
        } else {
          final fieldType = _inferFieldType(value);
          fields.add(
            FieldDefinition(
              key: fullKey,
              displayName: _generateDisplayName(fullKey),
              type: fieldType,
              required: false,
            ),
          );
        }
      });
    }
  }

  FieldDataType _inferFieldType(dynamic value) {
    if (value == null) return FieldDataType.string;

    if (value is bool) return FieldDataType.boolean;
    if (value is int) return FieldDataType.number;
    if (value is double) return FieldDataType.decimal;

    if (value is String) {
      // Intentar detectar fechas
      if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(value) ||
          RegExp(r'^\d{2}[-/]\d{2}[-/]\d{4}').hasMatch(value)) {
        return FieldDataType.date;
      }

      // Intentar detectar números
      if (double.tryParse(value) != null) {
        return value.contains('.')
            ? FieldDataType.decimal
            : FieldDataType.number;
      }
    }

    return FieldDataType.string;
  }

  String _generateDisplayName(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  bool _isInvoiceField(String key) {
    final invoiceKeywords = [
      'invoice',
      'factura',
      'numero',
      'fecha',
      'total',
      'subtotal',
      'itbis',
      'tax',
      'amount',
      'encf',
      'ncf',
    ];
    return invoiceKeywords.any(
      (keyword) => key.toLowerCase().contains(keyword),
    );
  }

  bool _isItemField(String key) {
    final itemKeywords = [
      'item',
      'product',
      'service',
      'cantidad',
      'precio',
      'descripcion',
      'quantity',
      'price',
      'description',
      'codigo',
      'code',
    ];
    return itemKeywords.any((keyword) => key.toLowerCase().contains(keyword));
  }

  bool _isClientField(String key) {
    final clientKeywords = [
      'client',
      'customer',
      'comprador',
      'paciente',
      'patient',
      'nombre',
      'name',
      'rnc',
      'cedula',
      'direccion',
      'address',
    ];
    return clientKeywords.any((keyword) => key.toLowerCase().contains(keyword));
  }

  bool _isCompanyField(String key) {
    final companyKeywords = [
      'company',
      'empresa',
      'emisor',
      'razon',
      'social',
      'telefono',
      'phone',
      'email',
      'correo',
      'website',
    ];
    return companyKeywords.any(
      (keyword) => key.toLowerCase().contains(keyword),
    );
  }

  /// Esquemas built-in como fallback
  List<DataSchema> _getBuiltInSchemas() {
    return [
      // Esquema médico (actual)
      DataSchema(
        id: 'medical_default',
        name: 'Clínica Médica',
        description: 'Esquema para clínicas y centros médicos',
        industry: 'medical',
        invoiceFields: [
          FieldDefinition(
            key: 'encf',
            displayName: 'Número de Factura',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'fecha_emision',
            displayName: 'Fecha de Emisión',
            type: FieldDataType.date,
            required: true,
          ),
          FieldDefinition(
            key: 'monto_total',
            displayName: 'Monto Total',
            type: FieldDataType.decimal,
            required: true,
          ),
        ],
        itemFields: [
          FieldDefinition(
            key: 'descripcion',
            displayName: 'Descripción del Servicio',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'cantidad',
            displayName: 'Cantidad',
            type: FieldDataType.number,
            required: true,
          ),
          FieldDefinition(
            key: 'precio',
            displayName: 'Precio Unitario',
            type: FieldDataType.decimal,
            required: true,
          ),
        ],
        clientFields: [
          FieldDefinition(
            key: 'nombre_paciente',
            displayName: 'Nombre del Paciente',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'cedula',
            displayName: 'Cédula',
            type: FieldDataType.string,
            required: true,
          ),
        ],
        companyFields: [
          FieldDefinition(
            key: 'razon_social',
            displayName: 'Razón Social',
            type: FieldDataType.string,
            required: true,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // Esquema para ferretería
      DataSchema(
        id: 'retail_hardware',
        name: 'Ferretería',
        description: 'Esquema para ferreterías y tiendas de materiales',
        industry: 'retail',
        invoiceFields: [
          FieldDefinition(
            key: 'numero_factura',
            displayName: 'Número de Factura',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'fecha',
            displayName: 'Fecha',
            type: FieldDataType.date,
            required: true,
          ),
          FieldDefinition(
            key: 'total',
            displayName: 'Total',
            type: FieldDataType.decimal,
            required: true,
          ),
        ],
        itemFields: [
          FieldDefinition(
            key: 'codigo_producto',
            displayName: 'Código de Producto',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'descripcion_producto',
            displayName: 'Descripción',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'categoria',
            displayName: 'Categoría',
            type: FieldDataType.string,
          ),
          FieldDefinition(
            key: 'cantidad',
            displayName: 'Cantidad',
            type: FieldDataType.number,
            required: true,
          ),
          FieldDefinition(
            key: 'precio_unitario',
            displayName: 'Precio Unitario',
            type: FieldDataType.decimal,
            required: true,
          ),
        ],
        clientFields: [
          FieldDefinition(
            key: 'nombre_cliente',
            displayName: 'Nombre del Cliente',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'rnc_cedula',
            displayName: 'RNC/Cédula',
            type: FieldDataType.string,
          ),
        ],
        companyFields: [
          FieldDefinition(
            key: 'nombre_empresa',
            displayName: 'Nombre de la Empresa',
            type: FieldDataType.string,
            required: true,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  /// Obtiene campos básicos según la industria
  List<FieldDefinition> _getBasicFieldsForIndustry(String industry) {
    switch (industry.toLowerCase()) {
      case 'medical':
        return [
          FieldDefinition(
            key: 'numero_factura',
            displayName: 'Número de Factura',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'fecha',
            displayName: 'Fecha',
            type: FieldDataType.date,
            required: true,
          ),
          FieldDefinition(
            key: 'paciente_nombre',
            displayName: 'Nombre del Paciente',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'servicio_descripcion',
            displayName: 'Descripción del Servicio',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'monto_total',
            displayName: 'Monto Total',
            type: FieldDataType.decimal,
            required: true,
          ),
        ];
      case 'retail':
        return [
          FieldDefinition(
            key: 'numero_factura',
            displayName: 'Número de Factura',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'fecha',
            displayName: 'Fecha',
            type: FieldDataType.date,
            required: true,
          ),
          FieldDefinition(
            key: 'cliente_nombre',
            displayName: 'Nombre del Cliente',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'producto_codigo',
            displayName: 'Código de Producto',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'producto_descripcion',
            displayName: 'Descripción del Producto',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'cantidad',
            displayName: 'Cantidad',
            type: FieldDataType.number,
            required: true,
          ),
          FieldDefinition(
            key: 'precio_unitario',
            displayName: 'Precio Unitario',
            type: FieldDataType.decimal,
            required: true,
          ),
          FieldDefinition(
            key: 'total',
            displayName: 'Total',
            type: FieldDataType.decimal,
            required: true,
          ),
        ];
      default:
        return [
          FieldDefinition(
            key: 'numero_documento',
            displayName: 'Número de Documento',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'fecha',
            displayName: 'Fecha',
            type: FieldDataType.date,
            required: true,
          ),
          FieldDefinition(
            key: 'cliente_nombre',
            displayName: 'Nombre del Cliente',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'descripcion',
            displayName: 'Descripción',
            type: FieldDataType.string,
            required: true,
          ),
          FieldDefinition(
            key: 'monto',
            displayName: 'Monto',
            type: FieldDataType.decimal,
            required: true,
          ),
        ];
    }
  }
}
