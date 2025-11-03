import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/erp_endpoint.dart';
import '../../services/erp_endpoint_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/logger_service.dart';

enum InvoiceEnvironment { certificacion, test, produccion }

enum StorageType { local, googleDrive, dropbox, oneDrive }

class ConfiguracionController extends GetxController {
  final FirestoreService _db = FirestoreService();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final ERPEndpointService _endpointService = ERPEndpointService();

  // Estado de carga
  bool loading = true;
  String? errorMessage;

  // Datos de la empresa
  Map<String, dynamic>? companyData;
  String? companyRnc;

  // Archivos
  String? digitalSignatureUrl;
  String? digitalSignaturePassword;
  String? companyLogoUrl;

  // Configuración de facturación
  InvoiceEnvironment selectedEnvironment = InvoiceEnvironment.certificacion;

  // Configuración de almacenamiento
  StorageType selectedStorageType = StorageType.local;
  String invoiceStoragePath = '/facturas';

  // Configuración de Google Drive
  String? googleDriveFolderId;
  String? googleDriveCredentials;

  // Configuración de otros servicios
  String? dropboxAccessToken;
  String? oneDriveAccessToken;

  // Configuración de endpoint electrónico
  String baseEndpointUrl =
      'https://ecfrecepcion.starsoftdominicana.com/ecf/api';

  // Configuración de URL base para endpoints ERP
  String baseERPUrl = 'https://cempsavid.duckdns.org/api';

  // Endpoints específicos configurados
  Map<String, String> erpEndpoints = {
    'ars': '/ars/full',
    'ars_alt': '/ars/full', // Endpoint alternativo
    'invoices': '/invoices/full',
    'clients': '/clients',
    'products': '/products',
  };

  // Configuración de endpoint ERP (DEPRECATED - ahora se usan múltiples endpoints)
  String urlERPEndpoint = 'Sin configurar';

  // Endpoints configurados
  List<ERPEndpoint> _configuredEndpoints = [];
  List<ERPEndpoint> get configuredEndpoints => _configuredEndpoints;

  /// Navega a la configuración inicial de la empresa
  void goToCompanySetup() {
    Get.toNamed('/setup');
  }

  /// Navega al constructor de esquemas
  void goToSchemaBuilder() {
    Get.toNamed('/schema_builder');
  }

  // Configuración de datos de prueba
  bool useFakeData = false;

  // Controllers para edición
  final storagePathCtrl = TextEditingController();
  final googleDriveFolderCtrl = TextEditingController();
  final googleDriveCredentialsCtrl = TextEditingController();
  final dropboxTokenCtrl = TextEditingController();
  final oneDriveTokenCtrl = TextEditingController();

  // Controller para endpoint
  final baseEndpointCtrl = TextEditingController();
  final baseERPUrlCtrl = TextEditingController();
  final urlERPEndpointCtrl = TextEditingController();

  // Controllers para endpoints específicos
  final Map<String, TextEditingController> endpointControllers = {};

  @override
  void onInit() {
    super.onInit();
    _initializeEndpointControllers();
    _loadCompanyData();
  }

  /// Carga los endpoints configurados desde el setup inicial
  Future<void> _loadConfiguredEndpoints() async {
    if (companyRnc == null) return;

    try {
      _configuredEndpoints = await _endpointService.getEndpoints(companyRnc!);
      debugPrint(
        '[ConfigController] Endpoints cargados: ${_configuredEndpoints.length}',
      );

      // Si hay endpoints configurados, actualizar el campo legacy
      if (_configuredEndpoints.isNotEmpty) {
        final primaryEndpoint = _configuredEndpoints.first;
        urlERPEndpoint = primaryEndpoint.url;
        urlERPEndpointCtrl.text =
            'Configurado desde Setup (${_configuredEndpoints.length} endpoints)';
      }
    } catch (e) {
      debugPrint('[ConfigController] Error cargando endpoints: $e');
    }
  }

  /// Navega a la configuración de endpoints
  void goToEndpointConfiguration() {
    Get.toNamed('/setup');
  }

  /// Obtiene un resumen de los endpoints configurados
  String getEndpointsStatus() {
    if (_configuredEndpoints.isEmpty) {
      return 'Sin endpoints configurados';
    }

    final types = _configuredEndpoints.map((e) => e.type.displayName).toSet();
    return '${_configuredEndpoints.length} endpoint(s): ${types.join(', ')}';
  }

  /// Verifica si hay endpoints configurados
  bool get hasConfiguredEndpoints => _configuredEndpoints.isNotEmpty;

  /// Inicializa los controllers para los endpoints
  void _initializeEndpointControllers() {
    // Limpiar controllers existentes
    for (var controller in endpointControllers.values) {
      controller.dispose();
    }
    endpointControllers.clear();

    // Crear controllers para cada endpoint
    for (var entry in erpEndpoints.entries) {
      endpointControllers[entry.key] = TextEditingController(text: entry.value);
    }
  }

  /// Obtiene la URL completa de un endpoint específico
  String getFullEndpointUrl(String endpointKey) {
    final endpoint = erpEndpoints[endpointKey];
    if (endpoint == null) return baseERPUrl;

    final base = baseERPUrl.endsWith('/')
        ? baseERPUrl.substring(0, baseERPUrl.length - 1)
        : baseERPUrl;
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$base$path';
  }

  /// Actualiza un endpoint específico
  void updateEndpoint(String key, String path) {
    erpEndpoints[key] = path;
    update();
    // Guardar automáticamente después de un pequeño delay
    saveEndpointsWithDelay();
  }

  Timer? _saveTimer;

  /// Guarda los endpoints con un delay para evitar múltiples guardados
  void saveEndpointsWithDelay() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1000), () {
      _saveEndpointsToFirebase();
    });
  }

  /// Guarda solo los endpoints en Firebase
  Future<void> _saveEndpointsToFirebase() async {
    if (companyRnc == null) return;

    try {
      Map<String, String> endpointsToSave = {};
      for (var entry in endpointControllers.entries) {
        endpointsToSave[entry.key] = entry.value.text.trim();
      }

      Map<String, dynamic> updateData = {
        'baseERPUrl': baseERPUrlCtrl.text.trim(),
        'erpEndpoints': endpointsToSave,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _db.set('companies/$companyRnc', updateData, merge: true);

      // Actualizar variables locales
      baseERPUrl = baseERPUrlCtrl.text.trim();
      for (var entry in endpointControllers.entries) {
        erpEndpoints[entry.key] = entry.value.text.trim();
      }

      debugPrint('[ConfigController] Endpoints guardados automáticamente');
    } catch (e) {
      debugPrint('[ConfigController] Error guardando endpoints: $e');
    }
  }

  /// Agrega un nuevo endpoint
  void addEndpoint(String key, String path) {
    erpEndpoints[key] = path;
    endpointControllers[key] = TextEditingController(text: path);
    update();
  }

  /// Elimina un endpoint
  void removeEndpoint(String key) {
    erpEndpoints.remove(key);
    endpointControllers[key]?.dispose();
    endpointControllers.remove(key);
    update();
  }

  Future<void> _loadCompanyData() async {
    loading = true;
    update();

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Obtener datos del usuario para conseguir el RNC de la empresa
      final userDoc = await _db.doc('users/$uid').get();
      final userData = userDoc.data();
      companyRnc = userData?['companyRnc'] as String?;

      if (companyRnc == null || companyRnc!.isEmpty) {
        throw Exception('Usuario no tiene empresa asignada');
      }

      // Obtener datos de la empresa
      final companyDoc = await _db.doc('companies/$companyRnc').get();
      companyData = companyDoc.data();

      if (companyData != null) {
        // URLs de archivos
        digitalSignatureUrl = companyData!['digitalSignatureUrl'] as String?;
        digitalSignaturePassword =
            companyData!['digitalSignaturePassword'] as String?;
        companyLogoUrl = companyData!['logoUrl'] as String?;

        // Configuración de facturación
        final envString = companyData!['invoiceEnvironment'] as String?;
        selectedEnvironment = _parseEnvironment(envString);

        // Configuración de almacenamiento
        final storageTypeString = companyData!['storageType'] as String?;
        selectedStorageType = _parseStorageType(storageTypeString);

        invoiceStoragePath = companyData!['invoiceStoragePath'] ?? '/facturas';
        storagePathCtrl.text = invoiceStoragePath;

        // Configuración de Google Drive
        googleDriveFolderId = companyData!['googleDriveFolderId'] as String?;
        googleDriveCredentials =
            companyData!['googleDriveCredentials'] as String?;
        googleDriveFolderCtrl.text = googleDriveFolderId ?? '';
        googleDriveCredentialsCtrl.text = googleDriveCredentials ?? '';

        // Configuración de otros servicios
        dropboxAccessToken = companyData!['dropboxAccessToken'] as String?;
        oneDriveAccessToken = companyData!['oneDriveAccessToken'] as String?;
        dropboxTokenCtrl.text = dropboxAccessToken ?? '';
        oneDriveTokenCtrl.text = oneDriveAccessToken ?? '';

        // Configuración de endpoint
        baseEndpointUrl =
            companyData!['baseEndpointUrl'] ??
            'https://ecfrecepcion.starsoftdominicana.com/ecf/api';
        baseEndpointCtrl.text = baseEndpointUrl;

        // Configuración de URL base ERP
        baseERPUrl =
            companyData!['baseERPUrl'] ?? 'https://cempsavid.duckdns.org/api';
        baseERPUrlCtrl.text = baseERPUrl;

        // Configuración de endpoints ERP específicos
        final savedEndpoints =
            companyData!['erpEndpoints'] as Map<String, dynamic>?;
        if (savedEndpoints != null) {
          erpEndpoints = Map<String, String>.from(savedEndpoints);
        }

        // Inicializar controllers para endpoints
        _initializeEndpointControllers();

        // Configuración de endpoint ERP (legacy)
        urlERPEndpoint = companyData!['urlERPEndpoint'] ?? 'Sin configurar';
        urlERPEndpointCtrl.text = urlERPEndpoint;

        // Configuración de datos de prueba
        useFakeData = companyData!['useFakeData'] ?? false;

        // Cargar endpoints configurados
        await _loadConfiguredEndpoints();
      }

      LoggerService().info('configuracion.load_success', {
        'companyRnc': companyRnc,
        'hasSignature': digitalSignatureUrl != null,
        'hasLogo': companyLogoUrl != null,
        'endpointsCount': _configuredEndpoints.length,
      });
    } catch (e, st) {
      LoggerService().error('configuracion.load_error', e, st);
      errorMessage = e.toString();
    } finally {
      loading = false;
      update();
    }
  }

  InvoiceEnvironment _parseEnvironment(String? envString) {
    switch (envString) {
      case 'test':
        return InvoiceEnvironment.test;
      case 'produccion':
        return InvoiceEnvironment.produccion;
      default:
        return InvoiceEnvironment.certificacion;
    }
  }

  String _environmentToString(InvoiceEnvironment env) {
    switch (env) {
      case InvoiceEnvironment.certificacion:
        return 'certificacion';
      case InvoiceEnvironment.test:
        return 'test';
      case InvoiceEnvironment.produccion:
        return 'produccion';
    }
  }

  StorageType _parseStorageType(String? typeString) {
    switch (typeString) {
      case 'googleDrive':
        return StorageType.googleDrive;
      case 'dropbox':
        return StorageType.dropbox;
      case 'oneDrive':
        return StorageType.oneDrive;
      default:
        return StorageType.local;
    }
  }

  String _storageTypeToString(StorageType type) {
    switch (type) {
      case StorageType.local:
        return 'local';
      case StorageType.googleDrive:
        return 'googleDrive';
      case StorageType.dropbox:
        return 'dropbox';
      case StorageType.oneDrive:
        return 'oneDrive';
    }
  }

  String getEnvironmentDisplayName(InvoiceEnvironment env) {
    switch (env) {
      case InvoiceEnvironment.certificacion:
        return 'Certificación';
      case InvoiceEnvironment.test:
        return 'Pruebas (Test)';
      case InvoiceEnvironment.produccion:
        return 'Producción';
    }
  }

  String getEnvironmentDescription(InvoiceEnvironment env) {
    switch (env) {
      case InvoiceEnvironment.certificacion:
        return 'Ambiente para certificar la implementación con la DGII';
      case InvoiceEnvironment.test:
        return 'Ambiente de pruebas para desarrollo y testing';
      case InvoiceEnvironment.produccion:
        return 'Ambiente productivo para facturación real';
    }
  }

  String getStorageDisplayName(StorageType type) {
    switch (type) {
      case StorageType.local:
        return 'Almacenamiento Local';
      case StorageType.googleDrive:
        return 'Google Drive';
      case StorageType.dropbox:
        return 'Dropbox';
      case StorageType.oneDrive:
        return 'OneDrive';
    }
  }

  String getStorageDescription(StorageType type) {
    switch (type) {
      case StorageType.local:
        return 'Guardar facturas en el servidor local';
      case StorageType.googleDrive:
        return 'Sincronizar facturas con Google Drive';
      case StorageType.dropbox:
        return 'Subir facturas automáticamente a Dropbox';
      case StorageType.oneDrive:
        return 'Almacenar facturas en Microsoft OneDrive';
    }
  }

  IconData getStorageIcon(StorageType type) {
    switch (type) {
      case StorageType.local:
        return Icons.storage_outlined;
      case StorageType.googleDrive:
        return Icons.cloud_outlined;
      case StorageType.dropbox:
        return Icons.cloud_upload_outlined;
      case StorageType.oneDrive:
        return Icons.cloud_sync_outlined;
    }
  }

  Future<void> pickDigitalSignature() async {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Pre-llenar con los valores actuales si existen
    if (digitalSignatureUrl != null && digitalSignatureUrl!.isNotEmpty) {
      urlController.text = digitalSignatureUrl!;
    }
    if (digitalSignaturePassword != null &&
        digitalSignaturePassword!.isNotEmpty) {
      passwordController.text = digitalSignaturePassword!;
    }

    final result = await Get.dialog<Map<String, String>>(
      AlertDialog(
        title: const Text('Configurar Firma Digital'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Introduce la URL y contraseña de tu certificado digital:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL del certificado',
                  hintText: 'https://ejemplo.com/certificado.p12',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña del certificado',
                  hintText: 'Contraseña para abrir el certificado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              Text(
                'Nota: La contraseña se almacena de forma segura en la configuración.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  final url = urlController.text.trim();
                  final password = passwordController.text.trim();

                  if (url.isNotEmpty && Uri.tryParse(url) != null) {
                    Get.back(result: {'url': url, 'password': password});
                  } else {
                    Get.snackbar(
                      'Error',
                      'Por favor introduce una URL válida',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade600,
                      colorText: Colors.white,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005285),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (result != null) {
      digitalSignatureUrl = result['url'];
      digitalSignaturePassword = result['password'];
      update();

      // Mostrar mensaje de guardando
      Get.snackbar(
        'Guardando...',
        'Guardando certificado en Firebase...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      // Guardar inmediatamente en Firebase
      await _saveDigitalSignatureToFirebase();
    }
  }

  Future<void> pickCompanyLogo() async {
    final TextEditingController urlController = TextEditingController();

    // Pre-llenar con la URL actual si existe
    if (companyLogoUrl != null && companyLogoUrl!.isNotEmpty) {
      urlController.text = companyLogoUrl!;
    }

    final result = await Get.dialog<String>(
      AlertDialog(
        title: const Text('URL del Logo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Introduce la URL donde está alojado el logo de tu empresa:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL del logo',
                hintText: 'https://ejemplo.com/logo.png',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  final url = urlController.text.trim();
                  if (url.isNotEmpty && Uri.tryParse(url) != null) {
                    Get.back(result: url);
                  } else {
                    Get.snackbar(
                      'Error',
                      'Por favor introduce una URL válida',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.shade600,
                      colorText: Colors.white,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF005285),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (result != null) {
      companyLogoUrl = result;
      update();

      // Mostrar mensaje de guardando
      Get.snackbar(
        'Guardando...',
        'Guardando logo en Firebase...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      // Guardar inmediatamente en Firebase
      await _saveLogoToFirebase();
    }
  }

  Future<void> saveConfiguration() async {
    if (companyRnc == null) return;

    loading = true;
    update();

    try {
      Map<String, dynamic> updateData = {
        'invoiceEnvironment': _environmentToString(selectedEnvironment),
        'storageType': _storageTypeToString(selectedStorageType),
        'invoiceStoragePath': storagePathCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Agregar configuración específica según el tipo de almacenamiento
      switch (selectedStorageType) {
        case StorageType.googleDrive:
          updateData['googleDriveFolderId'] = googleDriveFolderCtrl.text.trim();
          updateData['googleDriveCredentials'] = googleDriveCredentialsCtrl.text
              .trim();
          break;
        case StorageType.dropbox:
          updateData['dropboxAccessToken'] = dropboxTokenCtrl.text.trim();
          break;
        case StorageType.oneDrive:
          updateData['oneDriveAccessToken'] = oneDriveTokenCtrl.text.trim();
          break;
        case StorageType.local:
          // No configuración adicional necesaria
          break;
      }

      // Configuración de endpoint
      updateData['baseEndpointUrl'] = baseEndpointCtrl.text.trim();

      // Configuración de URL base ERP
      updateData['baseERPUrl'] = baseERPUrlCtrl.text.trim();

      // Configuración de endpoints ERP específicos
      Map<String, String> endpointsToSave = {};
      for (var entry in endpointControllers.entries) {
        endpointsToSave[entry.key] = entry.value.text.trim();
      }
      updateData['erpEndpoints'] = endpointsToSave;

      // Configuración de endpoint ERP (DEPRECATED - no sobrescribir si hay endpoints configurados)
      if (_configuredEndpoints.isEmpty) {
        updateData['urlERPEndpoint'] = urlERPEndpointCtrl.text.trim().isEmpty
            ? 'Sin configurar'
            : urlERPEndpointCtrl.text.trim();
      }

      // Configuración de datos de prueba
      updateData['useFakeData'] = useFakeData;

      // Nota: Los archivos (logo y certificado) ya se guardan inmediatamente
      // cuando se configuran, no es necesario guardarlos aquí nuevamente

      debugPrint(
        '[ConfigController] Datos a guardar: ${updateData.keys.toList()}',
      );

      // Actualizar en Firestore
      await _db.set('companies/$companyRnc', updateData, merge: true);

      // Actualizar variables locales
      invoiceStoragePath = storagePathCtrl.text.trim();
      baseERPUrl = baseERPUrlCtrl.text.trim();

      // Actualizar endpoints desde controllers
      for (var entry in endpointControllers.entries) {
        erpEndpoints[entry.key] = entry.value.text.trim();
      }

      urlERPEndpoint = urlERPEndpointCtrl.text.trim().isEmpty
          ? 'Sin configurar'
          : urlERPEndpointCtrl.text.trim();

      LoggerService().info('configuracion.save_success', {
        'companyRnc': companyRnc,
        'environment': _environmentToString(selectedEnvironment),
      });

      Get.snackbar(
        'Éxito',
        'Configuración guardada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e, st) {
      LoggerService().error('configuracion.save_error', e, st);
      Get.snackbar(
        'Error',
        'No se pudo guardar la configuración',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      loading = false;
      update();
    }
  }

  void setEnvironment(InvoiceEnvironment env) {
    selectedEnvironment = env;
    update();
  }

  void setStorageType(StorageType type) {
    selectedStorageType = type;
    update();
  }

  String getCurrentEndpoint() {
    final base = baseEndpointCtrl.text.trim();
    if (base.isEmpty) return baseEndpointUrl;

    switch (selectedEnvironment) {
      case InvoiceEnvironment.certificacion:
        return base; // No agregar /cert para certificación
      case InvoiceEnvironment.test:
        return '$base/test';
      case InvoiceEnvironment.produccion:
        return '$base/prod';
    }
  }

  // Métodos para guardar inmediatamente en Firebase
  Future<void> _saveDigitalSignatureToFirebase() async {
    if (companyRnc == null) return;

    try {
      loading = true;
      update();

      Map<String, dynamic> updateData = {};

      if (digitalSignatureUrl != null && digitalSignatureUrl!.isNotEmpty) {
        updateData['digitalSignatureUrl'] = digitalSignatureUrl;
      }

      if (digitalSignaturePassword != null &&
          digitalSignaturePassword!.isNotEmpty) {
        updateData['digitalSignaturePassword'] = digitalSignaturePassword;
      }

      if (updateData.isNotEmpty) {
        updateData['updatedAt'] = FieldValue.serverTimestamp();
        await _db.set('companies/$companyRnc', updateData, merge: true);

        Get.snackbar(
          'Certificado Guardado',
          'Certificado digital guardado en Firebase correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e, st) {
      LoggerService().error('configuracion.save_signature_error', e, st);
      Get.snackbar(
        'Error',
        'No se pudo guardar el certificado: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      loading = false;
      update();
    }
  }

  Future<void> _saveLogoToFirebase() async {
    if (companyRnc == null) return;

    try {
      loading = true;
      update();

      Map<String, dynamic> updateData = {};

      if (companyLogoUrl != null && companyLogoUrl!.isNotEmpty) {
        updateData['logoUrl'] = companyLogoUrl;
        updateData['updatedAt'] = FieldValue.serverTimestamp();

        await _db.set('companies/$companyRnc', updateData, merge: true);

        Get.snackbar(
          'Logo Guardado',
          'Logo guardado en Firebase correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e, st) {
      LoggerService().error('configuracion.save_logo_error', e, st);
      Get.snackbar(
        'Error',
        'No se pudo guardar el logo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      loading = false;
      update();
    }
  }

  // Método temporal de debug
  void debugConfiguration() {
    final config = {
      'digitalSignatureUrl': digitalSignatureUrl,
      'digitalSignaturePassword': digitalSignaturePassword != null
          ? '[CONFIGURADA]'
          : null,
      'companyLogoUrl': companyLogoUrl,
      'urlERPEndpoint': urlERPEndpoint,
      'baseEndpointUrl': baseEndpointUrl,
      'companyRnc': companyRnc,
    };

    debugPrint('[ConfigController] Configuración actual: $config');

    Get.snackbar(
      'Debug Configuración',
      'Logo: ${companyLogoUrl ?? 'No configurado'}\nCertificado: ${digitalSignatureUrl ?? 'No configurado'}\nERP: $urlERPEndpoint',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 8),
    );
  }

  // Método para alternar datos fake
  void toggleFakeData(bool value) {
    useFakeData = value;
    update();
  }

  @override
  void onClose() {
    _saveTimer?.cancel();

    storagePathCtrl.dispose();
    googleDriveFolderCtrl.dispose();
    googleDriveCredentialsCtrl.dispose();
    dropboxTokenCtrl.dispose();
    oneDriveTokenCtrl.dispose();
    baseEndpointCtrl.dispose();
    baseERPUrlCtrl.dispose();
    urlERPEndpointCtrl.dispose();

    // Dispose endpoint controllers
    for (var controller in endpointControllers.values) {
      controller.dispose();
    }
    endpointControllers.clear();

    /// Configura automáticamente el endpoint de ARS
    void setupARSEndpoint() {
      // Configurar URL base si no está configurada
      if (baseERPUrl.isEmpty || baseERPUrl == 'Sin configurar') {
        baseERPUrl = 'https://cempsavid.duckdns.org/api';
        baseERPUrlCtrl.text = baseERPUrl;
      }

      // Agregar endpoint de ARS si no existe
      if (!erpEndpoints.containsKey('ars')) {
        addEndpoint('ars', '/ars/full');
      }

      // Agregar endpoint alternativo de ARS si no existe
      if (!erpEndpoints.containsKey('ars_alt')) {
        addEndpoint('ars_alt', '/ars/full');
      }

      update();

      debugPrint('[ConfigController] ARS endpoints configured:');
      debugPrint('  - ars: ${getFullEndpointUrl('ars')}');
      debugPrint('  - ars_alt: ${getFullEndpointUrl('ars_alt')}');
    }

    /// Obtiene la URL del endpoint de ARS configurado
    String getARSEndpointUrl() {
      if (erpEndpoints.containsKey('ars')) {
        return getFullEndpointUrl('ars');
      }

      // Fallback a URL base + /ars/full
      final base = baseERPUrl.endsWith('/')
          ? baseERPUrl.substring(0, baseERPUrl.length - 1)
          : baseERPUrl;
      return '$base/ars/full';
    }

    super.onClose();
  }
}
