import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/company_model.dart';
import '../../models/schema_definition.dart';
import '../../services/company_config_service.dart';
import '../../services/schema_manager_service.dart';
import '../../routes/app_routes.dart';

class CompanySetupController extends GetxController {
  final CompanyConfigService _companyService = CompanyConfigService();
  final SchemaManagerService _schemaService = SchemaManagerService();

  // Controladores de formulario
  final basicInfoFormKey = GlobalKey<FormState>();
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
  String _currentView = 'basic'; // 'basic', 'schema', 'erp'

  List<DataSchema> _availableSchemas = [];
  String? _selectedSchemaId;
  bool _useFakeData = true;
  CompanyModel? _currentCompany;

  // Getters
  bool get loading => _loading;
  String get currentView => _currentView;
  List<DataSchema> get availableSchemas => _availableSchemas;
  String? get selectedSchemaId => _selectedSchemaId;
  bool get useFakeData => _useFakeData;

  bool get canGoBack => _currentView != 'basic';
  bool get canGoNext {
    final canProceed = _canProceedToNext();
    debugPrint('🔍 canGoNext: $canProceed, view: $_currentView');
    return canProceed;
  }

  bool get isLastStep => _currentView == 'erp';

  @override
  void onInit() {
    super.onInit();
    _setupTextControllerListeners();
    _initializeSetup();
  }

  /// Configura listeners para los controladores de texto
  void _setupTextControllerListeners() {
    // Agregar listeners para actualizar la UI cuando cambien los valores
    rncController.addListener(() => update());
    razonSocialController.addListener(() => update());
    direccionController.addListener(() => update());
    telefonoController.addListener(() => update());
    emailController.addListener(() => update());
    nombreComercialController.addListener(() => update());
    websiteController.addListener(() => update());
    erpUrlController.addListener(() => update());
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

  /// Inicializa la configuración
  Future<void> _initializeSetup() async {
    try {
      _setLoading(true);

      // Verificar si ya existe una empresa
      _currentCompany = await _companyService.getCurrentCompany();

      if (_currentCompany != null) {
        // Cargar datos existentes
        _loadExistingCompanyData();

        // Determinar qué vista mostrar basado en qué falta
        if (_currentCompany!.razonSocial.isEmpty ||
            _currentCompany!.direccion == null ||
            _currentCompany!.telefono == null) {
          _currentView = 'basic';
        } else if (_currentCompany!.activeSchemaId == null ||
            _currentCompany!.activeSchemaId!.isEmpty) {
          _currentView = 'schema';
        } else if (!_currentCompany!.useFakeData &&
            (_currentCompany!.urlERPEndpoint == null ||
                _currentCompany!.urlERPEndpoint!.isEmpty)) {
          _currentView = 'erp';
        } else {
          _currentView = 'basic'; // Por defecto para editar
        }

        debugPrint('🔍 INIT - Empresa encontrada: ${_currentCompany!.rnc}');
        debugPrint(
          '🔍 INIT - activeSchemaId: ${_currentCompany!.activeSchemaId}',
        );
        debugPrint('🔍 INIT - useFakeData: ${_currentCompany!.useFakeData}');
        debugPrint('🔍 INIT - Vista actual: $_currentView');
      } else {
        debugPrint('🔍 INIT - No hay empresa, empezando desde básico');
        _currentView = 'basic';
      }

      // Cargar esquemas disponibles
      await _loadAvailableSchemas();

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

  /// Avanza al siguiente paso
  Future<void> goNext() async {
    if (!_canProceedToNext()) return;

    try {
      _setLoading(true);

      switch (_currentView) {
        case 'basic':
          await _saveBasicInfo();
          _currentView = 'schema'; // Ir a esquema
          break;
        case 'schema':
          await _saveDataSchema();
          _currentView = 'erp'; // Ir a ERP
          break;
        case 'erp':
          await _saveERPConnection();
          await completeSetup(); // Completar configuración
          return;
      }

      // Actualizar empresa desde Firebase
      _currentCompany = await _companyService.getCurrentCompany();
      if (_currentCompany != null) {
        debugPrint('');
        debugPrint('🔍 ===== DESPUÉS DE GUARDAR =====');
        debugPrint('🔍 RNC: ${_currentCompany!.rnc}');
        debugPrint('🔍 activeSchemaId: ${_currentCompany!.activeSchemaId}');
        debugPrint('🔍 useFakeData: ${_currentCompany!.useFakeData}');
        debugPrint('🔍 Vista actual: $_currentView');
        debugPrint('🔍 ===============================');
        debugPrint('');
      }

      update();
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

  /// Retrocede al paso anterior
  void goBack() {
    if (!canGoBack) return;

    switch (_currentView) {
      case 'schema':
        _currentView = 'basic';
        break;
      case 'erp':
        _currentView = 'schema';
        break;
    }
    debugPrint('🔍 Retrocediendo a vista: $_currentView');
    update();
  }

  /// Selecciona un esquema
  void selectSchema(String schemaId) {
    _selectedSchemaId = schemaId;
    update();
  }

  /// Establece el uso de datos fake
  void setUseFakeData(bool useFake) {
    _useFakeData = useFake;
    update();
  }

  /// Crea un esquema personalizado
  Future<void> createCustomSchema() async {
    // Navegar al schema builder
    final result = await Get.toNamed('/schema-builder');
    if (result != null && result is String) {
      _selectedSchemaId = result;
      await _loadAvailableSchemas();
      update();
    }
  }

  /// Genera esquema desde datos de ejemplo
  Future<void> generateSchemaFromSample() async {
    // Mostrar diálogo para subir archivo JSON de ejemplo
    // Por ahora, usar datos de ejemplo predefinidos
    try {
      _setLoading(true);

      final sampleData = {
        'numero_factura': 'F-001',
        'fecha': '2024-01-15',
        'cliente_nombre': 'Juan Pérez',
        'total': 1500.00,
        'items': [
          {
            'codigo': 'PROD001',
            'descripcion': 'Producto de ejemplo',
            'cantidad': 2,
            'precio': 750.00,
          },
        ],
      };

      final schema = await _schemaService.createSchemaFromSample(
        'Esquema Generado',
        'other',
        sampleData,
      );

      _selectedSchemaId = schema.id;
      await _loadAvailableSchemas();

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

  /// Prueba la conexión ERP
  Future<void> testERPConnection() async {
    if (erpUrlController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Ingresa la URL del ERP primero',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      _setLoading(true);

      // Aquí implementarías la lógica de prueba de conexión
      // Por ahora, simular una prueba exitosa
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Éxito',
        'Conexión ERP exitosa',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error probando conexión: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Método de debug para forzar el avance a la siguiente vista
  void debugForceNextStep() {
    switch (_currentView) {
      case 'basic':
        _currentView = 'schema';
        break;
      case 'schema':
        _currentView = 'erp';
        break;
      case 'erp':
        // Ya está en la última vista
        break;
    }
    debugPrint('🔧 DEBUG: Forzado a vista $_currentView');
    update();
  }

  /// Completa la configuración
  Future<void> completeSetup() async {
    try {
      _setLoading(true);

      debugPrint('🔍 ===== COMPLETANDO CONFIGURACIÓN =====');
      debugPrint('🔍 Marcando empresa como configurada...');

      if (_currentCompany != null) {
        await _companyService.markAsConfigured(_currentCompany!.rnc);
        debugPrint(
          '🔍 Empresa marcada como configurada: ${_currentCompany!.rnc}',
        );
      }

      debugPrint('🔍 Navegando al home...');
      // Navegar al home
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      debugPrint('🔍 ERROR completando configuración: $e');
      Get.snackbar(
        'Error',
        'Error completando configuración: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _setLoading(false);
    }
  }

  // Métodos privados

  void _setLoading(bool loading) {
    _loading = loading;
    update();
  }

  bool _canProceedToNext() {
    switch (_currentView) {
      case 'basic': // Información básica
        return rncController.text.isNotEmpty &&
            razonSocialController.text.isNotEmpty &&
            direccionController.text.isNotEmpty &&
            telefonoController.text.isNotEmpty;
      case 'schema': // Esquema de datos
        return _selectedSchemaId != null;
      case 'erp': // Configuración ERP
        return _useFakeData || erpUrlController.text.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _saveBasicInfo() async {
    // Validar el formulario antes de guardar
    if (!basicInfoFormKey.currentState!.validate()) {
      Get.snackbar(
        'Error',
        'Por favor completa todos los campos requeridos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    debugPrint('🔍 ===== GUARDANDO PASO 1 =====');
    debugPrint('🔍 RNC: ${rncController.text}');
    debugPrint('🔍 Razón Social: ${razonSocialController.text}');
    debugPrint('🔍 Dirección: ${direccionController.text}');
    debugPrint('🔍 Teléfono: ${telefonoController.text}');

    if (_currentCompany == null) {
      // Crear nueva empresa
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
  }

  Future<void> _saveDataSchema() async {
    if (_selectedSchemaId == null || _currentCompany == null) {
      Get.snackbar(
        'Error',
        'Por favor selecciona un esquema de datos',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    debugPrint('🔍 Guardando esquema: $_selectedSchemaId');

    _currentCompany = await _companyService.updateCompany(
      _currentCompany!.copyWith(activeSchemaId: _selectedSchemaId),
    );

    debugPrint(
      '🔍 Esquema guardado en empresa: ${_currentCompany!.activeSchemaId}',
    );
  }

  Future<void> _saveERPConnection() async {
    if (_currentCompany == null) return;

    _currentCompany = await _companyService.updateCompany(
      _currentCompany!.copyWith(
        useFakeData: _useFakeData,
        urlERPEndpoint: _useFakeData ? null : erpUrlController.text,
      ),
    );
  }
}
