import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/firestore_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/logger_service.dart';

enum InvoiceEnvironment { certificacion, test, produccion }

enum StorageType { local, googleDrive, dropbox, oneDrive }

class ConfiguracionController extends GetxController {
  final FirestoreService _db = FirestoreService();
  final FirebaseAuthService _auth = FirebaseAuthService();

  // Estado de carga
  bool loading = true;
  String? errorMessage;

  // Datos de la empresa
  Map<String, dynamic>? companyData;
  String? companyRnc;

  // Archivos
  String? digitalSignatureUrl;
  String? companyLogoUrl;
  File? selectedSignatureFile;
  File? selectedLogoFile;

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

  // Configuración de endpoint ERP
  String urlERPEndpoint = 'Sin configurar';

  // Controllers para edición
  final storagePathCtrl = TextEditingController();
  final googleDriveFolderCtrl = TextEditingController();
  final googleDriveCredentialsCtrl = TextEditingController();
  final dropboxTokenCtrl = TextEditingController();
  final oneDriveTokenCtrl = TextEditingController();

  // Controller para endpoint
  final baseEndpointCtrl = TextEditingController();
  final urlERPEndpointCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadCompanyData();
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

        // Configuración de endpoint ERP
        urlERPEndpoint = companyData!['urlERPEndpoint'] ?? 'Sin configurar';
        urlERPEndpointCtrl.text = urlERPEndpoint;
      }

      LoggerService().info('configuracion.load_success', {
        'companyRnc': companyRnc,
        'hasSignature': digitalSignatureUrl != null,
        'hasLogo': companyLogoUrl != null,
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
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['p12', 'pfx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        selectedSignatureFile = File(result.files.first.path!);
        update();

        Get.snackbar(
          'Archivo Seleccionado',
          'Firma digital seleccionada: ${result.files.first.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e, st) {
      LoggerService().error('configuracion.pick_signature_error', e, st);
      Get.snackbar(
        'Error',
        'No se pudo seleccionar el archivo de firma digital',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickCompanyLogo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        selectedLogoFile = File(result.files.first.path!);
        update();

        Get.snackbar(
          'Archivo Seleccionado',
          'Logo seleccionado: ${result.files.first.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e, st) {
      LoggerService().error('configuracion.pick_logo_error', e, st);
      Get.snackbar(
        'Error',
        'No se pudo seleccionar el archivo de logo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  Future<String?> _uploadFile(File file, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e, st) {
      LoggerService().error('configuracion.upload_file_error', e, st);
      return null;
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

      // Configuración de endpoint ERP
      updateData['urlERPEndpoint'] = urlERPEndpointCtrl.text.trim().isEmpty
          ? 'Sin configurar'
          : urlERPEndpointCtrl.text.trim();

      // Subir firma digital si se seleccionó una nueva
      if (selectedSignatureFile != null) {
        final signatureUrl = await _uploadFile(
          selectedSignatureFile!,
          'companies/$companyRnc/signature.p12',
        );
        if (signatureUrl != null) {
          updateData['digitalSignatureUrl'] = signatureUrl;
          digitalSignatureUrl = signatureUrl;
        }
      }

      // Subir logo si se seleccionó uno nuevo
      if (selectedLogoFile != null) {
        final logoUrl = await _uploadFile(
          selectedLogoFile!,
          'companies/$companyRnc/logo.png',
        );
        if (logoUrl != null) {
          updateData['logoUrl'] = logoUrl;
          companyLogoUrl = logoUrl;
        }
      }

      // Actualizar en Firestore
      await _db.set('companies/$companyRnc', updateData, merge: true);

      // Limpiar archivos seleccionados
      selectedSignatureFile = null;
      selectedLogoFile = null;
      invoiceStoragePath = storagePathCtrl.text.trim();
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
        return '$base/cert';
      case InvoiceEnvironment.test:
        return '$base/test';
      case InvoiceEnvironment.produccion:
        return '$base/prod';
    }
  }

  @override
  void onClose() {
    storagePathCtrl.dispose();
    googleDriveFolderCtrl.dispose();
    googleDriveCredentialsCtrl.dispose();
    dropboxTokenCtrl.dispose();
    oneDriveTokenCtrl.dispose();
    baseEndpointCtrl.dispose();
    urlERPEndpointCtrl.dispose();
    super.onClose();
  }
}
