import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../models/schema_definition.dart';
import '../../models/dynamic_invoice.dart';
import '../../services/schema_manager_service.dart';

class SchemaBuilderController extends GetxController {
  final SchemaManagerService _schemaService = SchemaManagerService();

  // Estado
  bool _loading = false;
  List<DataSchema> _schemas = [];
  DataSchema? _currentSchema;
  String? _errorMessage;

  // Getters
  bool get loading => _loading;
  List<DataSchema> get schemas => _schemas;
  DataSchema? get currentSchema => _currentSchema;
  String? get errorMessage => _errorMessage;

  @override
  void onInit() {
    super.onInit();
    loadSchemas();
  }

  /// Carga todos los esquemas disponibles
  Future<void> loadSchemas() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Cargar esquemas del usuario y predefinidos
      final userSchemas = await _schemaService.getUserSchemas();
      final predefinedSchemas = await _schemaService.getPredefinedSchemas();

      _schemas = [...userSchemas, ...predefinedSchemas];

      // Seleccionar el primer esquema si no hay uno seleccionado
      if (_currentSchema == null && _schemas.isNotEmpty) {
        _currentSchema = _schemas.first;
      }

      update();
    } catch (e) {
      _errorMessage = 'Error cargando esquemas: $e';
      Get.snackbar(
        'Error',
        _errorMessage!,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Selecciona un esquema específico
  void selectSchema(String schemaId) {
    _currentSchema = _schemas.firstWhere(
      (schema) => schema.id == schemaId,
      orElse: () => throw Exception('Esquema no encontrado: $schemaId'),
    );
    update();
  }

  /// Crea un nuevo esquema
  Future<void> createSchema(
    String name,
    String description,
    String industry,
  ) async {
    try {
      _setLoading(true);

      final schema = DataSchema(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        industry: industry,
        invoiceFields: [],
        itemFields: [],
        clientFields: [],
        companyFields: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _schemaService.saveSchema(schema);

      _schemas.add(schema);
      _currentSchema = schema;

      Get.snackbar(
        'Éxito',
        'Esquema creado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error creando esquema: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Guarda el esquema actual
  Future<void> saveSchema() async {
    if (_currentSchema == null) return;

    try {
      _setLoading(true);

      final updatedSchema = DataSchema(
        id: _currentSchema!.id,
        name: _currentSchema!.name,
        description: _currentSchema!.description,
        industry: _currentSchema!.industry,
        invoiceFields: _currentSchema!.invoiceFields,
        itemFields: _currentSchema!.itemFields,
        clientFields: _currentSchema!.clientFields,
        companyFields: _currentSchema!.companyFields,
        metadata: _currentSchema!.metadata,
        createdAt: _currentSchema!.createdAt,
        updatedAt: DateTime.now(),
      );

      await _schemaService.saveSchema(updatedSchema);
      _currentSchema = updatedSchema;

      Get.snackbar(
        'Éxito',
        'Esquema guardado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error guardando esquema: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Agrega un campo a una categoría específica
  void addField(String category, FieldDefinition field) {
    if (_currentSchema == null) return;

    final updatedFields = _getFieldsForCategory(category).toList();
    updatedFields.add(field);
    _updateFieldsForCategory(category, updatedFields);
    update();
  }

  /// Actualiza un campo existente
  void updateField(String category, String oldKey, FieldDefinition newField) {
    if (_currentSchema == null) return;

    final updatedFields = _getFieldsForCategory(category).toList();
    final index = updatedFields.indexWhere((f) => f.key == oldKey);

    if (index != -1) {
      updatedFields[index] = newField;
      _updateFieldsForCategory(category, updatedFields);
      update();
    }
  }

  /// Elimina un campo
  void removeField(String category, String fieldKey) {
    if (_currentSchema == null) return;

    final updatedFields = _getFieldsForCategory(
      category,
    ).where((f) => f.key != fieldKey).toList();

    _updateFieldsForCategory(category, updatedFields);
    update();
  }

  /// Elimina el esquema actual
  Future<void> deleteCurrentSchema() async {
    if (_currentSchema == null) return;

    try {
      await _schemaService.deleteSchema(_currentSchema!.id);

      _schemas.removeWhere((s) => s.id == _currentSchema!.id);
      _currentSchema = _schemas.isNotEmpty ? _schemas.first : null;

      Get.snackbar(
        'Éxito',
        'Esquema eliminado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error eliminando esquema: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Crea esquema desde datos de ejemplo
  Future<void> createSchemaFromSample(
    String name,
    String industry,
    Map<String, dynamic> sampleData,
  ) async {
    try {
      _setLoading(true);

      final schema = await _schemaService.createSchemaFromSample(
        name,
        industry,
        sampleData,
      );

      _schemas.add(schema);
      _currentSchema = schema;

      Get.snackbar(
        'Éxito',
        'Esquema generado desde datos de ejemplo',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error generando esquema: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Valida datos externos contra el esquema actual
  Future<List<ValidationError>> validateExternalData(
    Map<String, dynamic> externalData,
  ) async {
    if (_currentSchema == null) return [];

    return await _schemaService.validateExternalData(
      externalData,
      _currentSchema!.id,
    );
  }

  // Métodos privados

  void _setLoading(bool loading) {
    _loading = loading;
    update();
  }

  List<FieldDefinition> _getFieldsForCategory(String category) {
    if (_currentSchema == null) return [];

    switch (category) {
      case 'invoice':
        return _currentSchema!.invoiceFields;
      case 'item':
        return _currentSchema!.itemFields;
      case 'client':
        return _currentSchema!.clientFields;
      case 'company':
        return _currentSchema!.companyFields;
      default:
        return [];
    }
  }

  void _updateFieldsForCategory(String category, List<FieldDefinition> fields) {
    if (_currentSchema == null) return;

    switch (category) {
      case 'invoice':
        _currentSchema = DataSchema(
          id: _currentSchema!.id,
          name: _currentSchema!.name,
          description: _currentSchema!.description,
          industry: _currentSchema!.industry,
          invoiceFields: fields,
          itemFields: _currentSchema!.itemFields,
          clientFields: _currentSchema!.clientFields,
          companyFields: _currentSchema!.companyFields,
          metadata: _currentSchema!.metadata,
          createdAt: _currentSchema!.createdAt,
          updatedAt: DateTime.now(),
        );
        break;
      case 'item':
        _currentSchema = DataSchema(
          id: _currentSchema!.id,
          name: _currentSchema!.name,
          description: _currentSchema!.description,
          industry: _currentSchema!.industry,
          invoiceFields: _currentSchema!.invoiceFields,
          itemFields: fields,
          clientFields: _currentSchema!.clientFields,
          companyFields: _currentSchema!.companyFields,
          metadata: _currentSchema!.metadata,
          createdAt: _currentSchema!.createdAt,
          updatedAt: DateTime.now(),
        );
        break;
      case 'client':
        _currentSchema = DataSchema(
          id: _currentSchema!.id,
          name: _currentSchema!.name,
          description: _currentSchema!.description,
          industry: _currentSchema!.industry,
          invoiceFields: _currentSchema!.invoiceFields,
          itemFields: _currentSchema!.itemFields,
          clientFields: fields,
          companyFields: _currentSchema!.companyFields,
          metadata: _currentSchema!.metadata,
          createdAt: _currentSchema!.createdAt,
          updatedAt: DateTime.now(),
        );
        break;
      case 'company':
        _currentSchema = DataSchema(
          id: _currentSchema!.id,
          name: _currentSchema!.name,
          description: _currentSchema!.description,
          industry: _currentSchema!.industry,
          invoiceFields: _currentSchema!.invoiceFields,
          itemFields: _currentSchema!.itemFields,
          clientFields: _currentSchema!.clientFields,
          companyFields: fields,
          metadata: _currentSchema!.metadata,
          createdAt: _currentSchema!.createdAt,
          updatedAt: DateTime.now(),
        );
        break;
    }
  }
}
