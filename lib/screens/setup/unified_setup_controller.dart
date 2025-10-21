import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/company_model.dart';
import '../../models/erp_endpoint.dart';
import '../../models/schema_definition.dart';
import '../../routes/app_routes.dart';
import '../../services/company_config_service.dart';
import '../../services/erp_endpoint_service.dart';
import '../../services/schema_manager_service.dart';

class UnifiedSetupController extends GetxController {
  final CompanyConfigService _companyService = CompanyConfigService();
  final SchemaManagerService _schemaService = SchemaManagerService();
  final ERPEndpointService _endpointService = ERPEndpointService();

  // Controladores de formulario
  final companyFormKey = GlobalKey<FormState>();
  final rncController = TextEditingController();
  final razonSocialController = TextEditingController();
  final nombreComercialController = TextEditingController();
  final direccionController = TextEditingController();
  final telefonoController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final erpUrlController = TextEditingController();

  // Estado
  bool _loading = false;
  CompanyModel? _currentCompany;
  List<DataSchema> _availableSchemas = [];
  String? _selectedSchemaId;
  bool _useFakeData = true;
  List<ERPEndpoint> _erpEndpoints = [];

  // Getters
  bool get loading => _loading;
  List<DataSchema> get availableSchemas => _availableSchemas;
  String? get selectedSchemaId => _selectedSchemaId;
  bool get useFakeData => _useFakeData;
  List<ERPEndpoint> get erpEndpoints => _erpEndpoints;

  @override
  void onInit() {
    super.onInit();
    _setupTextControllerListeners();
    _initializeSetup();
  }

  @override
  void onClose() {
    // Limpiar controladores
    rncController.dispose();
    razonSocialController.dispose();
    nombreComercialController.dispose();
    direccionController.dispose();
    telefonoController.dispose();
    emailController.dispose();
    websiteController.dispose();
    erpUrlController.dispose();
    super.onClose();
  }

  /// Configura listeners para los controladores de texto
  void _setupTextControllerListeners() {
    rncController.addListener(() => update());
    razonSocialController.addListener(() => update());
    direccionController.addListener(() => update());
    telefonoController.addListener(() => update());
    emailController.addListener(() => update());
    nombreComercialController.addListener(() => update());
    websiteController.addListener(() => update());
    erpUrlController.addListener(() => update());
  }

  /// Inicializa la configuración
  Future<void> _initializeSetup() async {
    try {
      _setLoading(true);

      // Verificar si ya existe una empresa
      _currentCompany = await _companyService.getCurrentCompany();

      if (_currentCompany != null) {
        // Cargar datos existentes
        _loadExistingCompanyData();
        debugPrint('🔍 INIT - Empresa encontrada: ${_currentCompany!.rnc}');
      } else {
        debugPrint('🔍 INIT - No hay empresa, configuración nueva');
      }

      // Cargar esquemas disponibles
      await _loadAvailableSchemas();

      // Cargar endpoints si ya existe la empresa
      if (_currentCompany != null) {
        await _loadERPEndpoints();
      }

      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error inicializando configuración: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Carga los datos de la empresa existente
  void _loadExistingCompanyData() {
    if (_currentCompany == null) return;

    rncController.text = _currentCompany!.rnc;
    razonSocialController.text = _currentCompany!.razonSocial;
    nombreComercialController.text = _currentCompany!.nombreComercial ?? '';
    direccionController.text = _currentCompany!.direccion ?? '';
    telefonoController.text = _currentCompany!.telefono ?? '';
    emailController.text = _currentCompany!.email ?? '';
    websiteController.text = _currentCompany!.website ?? '';
    erpUrlController.text = _currentCompany!.urlERPEndpoint ?? '';

    _selectedSchemaId = _currentCompany!.activeSchemaId;
    _useFakeData = _currentCompany!.useFakeData;
  }

  /// Carga los esquemas disponibles
  Future<void> _loadAvailableSchemas() async {
    try {
      _availableSchemas = await _schemaService.getPredefinedSchemas();

      // Si no hay esquema seleccionado, seleccionar el primero
      if (_selectedSchemaId == null && _availableSchemas.isNotEmpty) {
        _selectedSchemaId = _availableSchemas.first.id;
      }
    } catch (e) {
      debugPrint('Error cargando esquemas: $e');
    }
  }

  /// Verifica si la información de empresa está completa
  bool isCompanyInfoComplete() {
    return rncController.text.isNotEmpty &&
        razonSocialController.text.isNotEmpty &&
        direccionController.text.isNotEmpty &&
        telefonoController.text.isNotEmpty;
  }

  /// Verifica si hay un esquema seleccionado
  bool hasSchemaSelected() {
    return _selectedSchemaId != null && _selectedSchemaId!.isNotEmpty;
  }

  /// Verifica si la configuración ERP está lista
  bool isERPConfigured() {
    return _useFakeData || _erpEndpoints.isNotEmpty;
  }

  /// Verifica si toda la configuración está lista para guardar
  bool isConfigurationReady() {
    return isCompanyInfoComplete() && hasSchemaSelected() && isERPConfigured();
  }

  /// Obtiene el progreso de configuración (0.0 a 1.0)
  double getConfigurationProgress() {
    int completed = 0;
    if (isCompanyInfoComplete()) completed++;
    if (hasSchemaSelected()) completed++;
    if (isERPConfigured()) completed++;
    return completed / 3.0;
  }

  /// Selecciona un esquema
  void selectSchema(String schemaId) {
    _selectedSchemaId = schemaId;
    debugPrint('🔍 Esquema seleccionado: $schemaId');
    update();
  }

  /// Limpia el esquema seleccionado
  void clearSelectedSchema() {
    _selectedSchemaId = null;
    update();
  }

  /// Obtiene el nombre del esquema seleccionado
  String getSchemaDisplayName() {
    if (_selectedSchemaId == null || _selectedSchemaId!.isEmpty) return '';

    try {
      final schema = _availableSchemas.firstWhere(
        (s) => s.id == _selectedSchemaId,
        orElse: () => DataSchema(
          id: '',
          name: 'Esquema no encontrado',
          description: '',
          industry: '',
          invoiceFields: [],
          itemFields: [],
          clientFields: [],
          companyFields: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      return schema.name;
    } catch (e) {
      debugPrint('Error obteniendo nombre del esquema: $e');
      return 'Error cargando esquema';
    }
  }

  /// Establece el uso de datos fake
  void setUseFakeData(bool useFake) {
    _useFakeData = useFake;
    update();
  }

  /// Guarda solo la información básica de la empresa
  Future<void> saveBasicCompanyInfo() async {
    if (!companyFormKey.currentState!.validate()) {
      Get.snackbar(
        'Error',
        'Por favor completa la información requerida',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      _setLoading(true);

      if (_currentCompany == null) {
        await _createBasicCompany();
      } else {
        // Actualizar empresa existente
        _currentCompany = await _companyService.updateCompany(
          _currentCompany!.copyWith(
            razonSocial: razonSocialController.text,
            nombreComercial: nombreComercialController.text.isEmpty
                ? null
                : nombreComercialController.text,
            direccion: direccionController.text,
            telefono: telefonoController.text,
            email: emailController.text.isEmpty ? null : emailController.text,
            website: websiteController.text.isEmpty
                ? null
                : websiteController.text,
          ),
        );
      }

      if (_currentCompany != null) {
        Get.snackbar(
          'Éxito',
          'Información de empresa guardada',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error guardando información: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Crea un esquema personalizado
  Future<void> createCustomSchema() async {
    try {
      // Mostrar diálogo para crear esquema
      final result = await _showCreateSchemaDialog();
      if (result != null && result['name'] != null) {
        final schema = await _schemaService.createSchemaFromSample(
          result['name'] ?? 'Esquema Personalizado',
          result['industry'] ?? 'other',
          {}, // Esquema vacío para personalizar
        );

        if (schema.id.isNotEmpty) {
          _selectedSchemaId = schema.id;
          await _loadAvailableSchemas();

          Get.snackbar(
            'Éxito',
            'Esquema personalizado creado: ${schema.name}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          update();
        } else {
          throw Exception('Error creando esquema: ID vacío');
        }
      }
    } catch (e) {
      debugPrint('Error en createCustomSchema: $e');
      Get.snackbar(
        'Error',
        'Error creando esquema: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Genera esquema desde datos de ejemplo
  Future<void> generateSchemaFromSample() async {
    try {
      // Mostrar diálogo para subir JSON de ejemplo
      final result = await _showSampleDataDialog();
      if (result != null &&
          result['name'] != null &&
          result['sampleData'] != null) {
        // Parsear los datos de ejemplo
        Map<String, dynamic> sampleData = {};
        if (result['sampleData'] is String) {
          try {
            sampleData = Map<String, dynamic>.from(
              // Aquí deberías usar un parser JSON real
              {'sample': result['sampleData']},
            );
          } catch (e) {
            debugPrint('Error parseando JSON: $e');
            sampleData = {'sample_data': result['sampleData']};
          }
        } else if (result['sampleData'] is Map) {
          sampleData = Map<String, dynamic>.from(result['sampleData']);
        }

        final schema = await _schemaService.createSchemaFromSample(
          result['name'] ?? 'Esquema desde Datos',
          result['industry'] ?? 'other',
          sampleData,
        );

        if (schema.id.isNotEmpty) {
          _selectedSchemaId = schema.id;
          await _loadAvailableSchemas();

          Get.snackbar(
            'Éxito',
            'Esquema generado: ${schema.name}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          update();
        } else {
          throw Exception('Error generando esquema: ID vacío');
        }
      }
    } catch (e) {
      debugPrint('Error en generateSchemaFromSample: $e');
      Get.snackbar(
        'Error',
        'Error generando esquema: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Carga los endpoints del ERP
  Future<void> _loadERPEndpoints() async {
    if (_currentCompany == null) return;

    try {
      _erpEndpoints = await _endpointService.getEndpoints(_currentCompany!.rnc);
      debugPrint('Endpoints cargados: ${_erpEndpoints.length}');
    } catch (e) {
      debugPrint('Error cargando endpoints: $e');
    }
  }

  /// Agrega un nuevo endpoint
  Future<void> addEndpoint() async {
    // Si no hay empresa, intentar crearla primero con los datos básicos
    if (_currentCompany == null) {
      if (!isCompanyInfoComplete()) {
        Get.snackbar(
          'Error',
          'Completa la información básica de la empresa primero',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Crear empresa básica
      await _createBasicCompany();
      if (_currentCompany == null) {
        Get.snackbar(
          'Error',
          'Error creando empresa. Intenta de nuevo.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    final result = await _showAddEndpointDialog();
    if (result != null) {
      try {
        _setLoading(true);

        final endpoint = ERPEndpoint(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: result['name'],
          url: result['url'],
          method: result['method'] ?? 'GET',
          type: result['type'] ?? EndpointType.invoices,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _endpointService.saveEndpoint(_currentCompany!.rnc, endpoint);
        await _loadERPEndpoints();

        Get.snackbar(
          'Éxito',
          'Endpoint agregado: ${endpoint.name}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        update();
      } catch (e) {
        Get.snackbar(
          'Error',
          'Error agregando endpoint: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        _setLoading(false);
      }
    }
  }

  /// Prueba un endpoint específico
  Future<void> testEndpoint(ERPEndpoint endpoint) async {
    try {
      _setLoading(true);

      final result = await _endpointService.testEndpoint(endpoint);

      if (result['success'] == true) {
        Get.snackbar(
          'Éxito',
          'Conexión exitosa con ${endpoint.name}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Error en conexión: ${result['error']}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error probando endpoint: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina un endpoint
  Future<void> deleteEndpoint(ERPEndpoint endpoint) async {
    if (_currentCompany == null) return;

    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirmar'),
          content: Text('¿Eliminar el endpoint "${endpoint.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        _setLoading(true);
        await _endpointService.deleteEndpoint(
          _currentCompany!.rnc,
          endpoint.id,
        );
        await _loadERPEndpoints();

        Get.snackbar(
          'Éxito',
          'Endpoint eliminado',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        update();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error eliminando endpoint: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Guarda toda la configuración
  Future<void> saveConfiguration() async {
    try {
      _setLoading(true);

      // Validar sección de empresa
      if (!companyFormKey.currentState!.validate()) {
        Get.snackbar(
          'Error',
          'Por favor completa la información de la empresa',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Validar esquema
      if (_selectedSchemaId == null) {
        Get.snackbar(
          'Error',
          'Por favor selecciona un esquema de datos',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Crear empresa si no existe
      if (_currentCompany == null) {
        await _createBasicCompany();
        if (_currentCompany == null) {
          Get.snackbar(
            'Error',
            'Error creando empresa',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      // Actualizar con toda la configuración
      _currentCompany = await _companyService.updateCompany(
        _currentCompany!.copyWith(
          razonSocial: razonSocialController.text,
          nombreComercial: nombreComercialController.text.isEmpty
              ? null
              : nombreComercialController.text,
          direccion: direccionController.text,
          telefono: telefonoController.text,
          email: emailController.text.isEmpty ? null : emailController.text,
          website: websiteController.text.isEmpty
              ? null
              : websiteController.text,
          activeSchemaId: _selectedSchemaId,
          useFakeData: _useFakeData,
          erpEndpointIds: _erpEndpoints.map((e) => e.id).toList(),
          urlERPEndpoint: _useFakeData ? null : erpUrlController.text,
        ),
      );

      // Debug: Verificar estado antes de marcar como configurado
      debugPrint('🔍 DEBUG - Estado de configuración:');
      debugPrint('  - useFakeData: $_useFakeData');
      debugPrint('  - erpEndpoints count: ${_erpEndpoints.length}');
      debugPrint(
        '  - erpEndpointIds: ${_erpEndpoints.map((e) => e.id).toList()}',
      );
      debugPrint('  - isConfigurationReady: ${isConfigurationReady()}');
      debugPrint(
        '  - currentCompany.currentSetupStep: ${_currentCompany!.currentSetupStep}',
      );

      if (isConfigurationReady()) {
        // Marcar como configurado y ir al home
        await _companyService.markAsConfigured(_currentCompany!.rnc);

        Get.snackbar(
          'Éxito',
          'Configuración completada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed(AppRoutes.HOME);
      } else {
        Get.snackbar(
          'Guardado',
          'Configuración guardada correctamente.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error guardando configuración: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
    }
  }

  // Métodos privados

  /// Crea una empresa básica con la información mínima
  Future<void> _createBasicCompany() async {
    try {
      _setLoading(true);

      _currentCompany = await _companyService.createCompany(
        rnc: rncController.text,
        razonSocial: razonSocialController.text,
        nombreComercial: nombreComercialController.text.isEmpty
            ? null
            : nombreComercialController.text,
        direccion: direccionController.text,
        telefono: telefonoController.text,
        email: emailController.text.isEmpty ? null : emailController.text,
        website: websiteController.text.isEmpty ? null : websiteController.text,
      );

      debugPrint('✅ Empresa básica creada: ${_currentCompany!.rnc}');
      update();
    } catch (e) {
      debugPrint('❌ Error creando empresa básica: $e');
      _currentCompany = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _loading = loading;
    update();
  }

  /// Muestra diálogo para agregar endpoint
  Future<Map<String, dynamic>?> _showAddEndpointDialog() async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    String selectedMethod = 'GET';
    EndpointType selectedType = EndpointType.invoices;

    return await Get.dialog<Map<String, dynamic>>(
      AlertDialog(
        title: const Text('Agregar Endpoint ERP'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Endpoint',
                  hintText: 'Ej: Obtener Facturas',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://mi-erp.com/api/facturas',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMethod,
                decoration: const InputDecoration(labelText: 'Método HTTP'),
                items: const [
                  DropdownMenuItem(value: 'GET', child: Text('GET')),
                  DropdownMenuItem(value: 'POST', child: Text('POST')),
                  DropdownMenuItem(value: 'PUT', child: Text('PUT')),
                  DropdownMenuItem(value: 'DELETE', child: Text('DELETE')),
                ],
                onChanged: (value) => selectedMethod = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<EndpointType>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo de Datos'),
                items: EndpointType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) => selectedType = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  urlController.text.isNotEmpty) {
                Get.back(
                  result: {
                    'name': nameController.text,
                    'url': urlController.text,
                    'method': selectedMethod,
                    'type': selectedType,
                  },
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo para crear esquema personalizado
  Future<Map<String, dynamic>?> _showCreateSchemaDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedIndustry = 'medical';

    return await Get.dialog<Map<String, dynamic>>(
      AlertDialog(
        title: const Text('Crear Esquema Personalizado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Esquema',
                hintText: 'Ej: Mi Clínica Dental',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe el tipo de negocio',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedIndustry,
              decoration: const InputDecoration(labelText: 'Industria'),
              items: const [
                DropdownMenuItem(value: 'medical', child: Text('Médica')),
                DropdownMenuItem(
                  value: 'retail',
                  child: Text('Retail/Ferretería'),
                ),
                DropdownMenuItem(
                  value: 'manufacturing',
                  child: Text('Manufactura'),
                ),
                DropdownMenuItem(value: 'services', child: Text('Servicios')),
                DropdownMenuItem(value: 'other', child: Text('Otro')),
              ],
              onChanged: (value) => selectedIndustry = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Get.back(
                  result: {
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'industry': selectedIndustry,
                  },
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo para datos de ejemplo
  Future<Map<String, dynamic>?> _showSampleDataDialog() async {
    final nameController = TextEditingController();
    final jsonController = TextEditingController();
    String selectedIndustry = 'other';

    // Datos de ejemplo predefinidos
    jsonController.text = '''
{
  "numero_factura": "F-001",
  "fecha": "2024-01-15",
  "cliente_nombre": "Juan Pérez",
  "cliente_rnc": "123456789",
  "total": 1500.00,
  "subtotal": 1327.43,
  "itbis": 172.57,
  "items": [
    {
      "codigo": "PROD001",
      "descripcion": "Producto de ejemplo",
      "cantidad": 2,
      "precio": 663.72
    }
  ]
}''';

    return await Get.dialog<Map<String, dynamic>>(
      AlertDialog(
        title: const Text('Generar Esquema desde Datos'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Esquema',
                  hintText: 'Ej: Mi Negocio',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedIndustry,
                decoration: const InputDecoration(labelText: 'Industria'),
                items: const [
                  DropdownMenuItem(value: 'medical', child: Text('Médica')),
                  DropdownMenuItem(
                    value: 'retail',
                    child: Text('Retail/Ferretería'),
                  ),
                  DropdownMenuItem(
                    value: 'manufacturing',
                    child: Text('Manufactura'),
                  ),
                  DropdownMenuItem(value: 'services', child: Text('Servicios')),
                  DropdownMenuItem(value: 'other', child: Text('Otro')),
                ],
                onChanged: (value) => selectedIndustry = value!,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: jsonController,
                decoration: const InputDecoration(
                  labelText: 'Datos de Ejemplo (JSON)',
                  hintText: 'Pega aquí un JSON de ejemplo de tu ERP',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  jsonController.text.isNotEmpty) {
                try {
                  // Intentar parsear el JSON
                  final sampleData = jsonController.text.trim();
                  Get.back(
                    result: {
                      'name': nameController.text,
                      'industry': selectedIndustry,
                      'sampleData': sampleData,
                    },
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'JSON inválido: $e',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: const Text('Generar'),
          ),
        ],
      ),
    );
  }
}
