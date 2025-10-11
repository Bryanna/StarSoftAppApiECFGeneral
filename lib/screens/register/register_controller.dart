import 'package:facturacion/routes/app_routes.dart';
import 'package:facturacion/services/firebase_auth_service.dart';
import 'package:facturacion/services/firestore_service.dart';
import 'package:facturacion/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:facturacion/services/logger_service.dart';

class RegisterController extends GetxController {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirestoreService _db = FirestoreService();
  final box = GetStorage();

  // Empresa (DGII)
  final rncCtrl = TextEditingController();
  final razonSocialCtrl = TextEditingController();
  final representanteFiscalCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();
  final correoEmpresaCtrl = TextEditingController();

  // Admin login
  final adminEmailCtrl = TextEditingController();
  final adminPasswordCtrl = TextEditingController();
  final nombreAdminCtrl = TextEditingController();

  bool loading = false;
  String? errorMessage;
  // Errores por campo (inline)
  String? rncError;
  String? razonError;
  String? repError;
  String? dirError;
  String? telError;
  String? correoEmpresaError;
  String? adminEmailError;
  String? adminPassError;
  String? nombreAdminError;

  // Evita llamar update() después de que el controlador fue cerrado
  void _safeUpdate() {
    if (!isClosed) update();
  }

  Future<void> submit() async {
    // Validaciones básicas
    final rnc = rncCtrl.text.trim();
    final razon = razonSocialCtrl.text.trim();
    final rep = representanteFiscalCtrl.text.trim();
    final dir = direccionCtrl.text.trim();
    final tel = telefonoCtrl.text.trim();
    final correoEmpresa = correoEmpresaCtrl.text.trim();
    final adminEmail = adminEmailCtrl.text.trim();
    final adminPass = adminPasswordCtrl.text;
    final nombreAdmin = nombreAdminCtrl.text.trim();

    // Reset de errores
    rncError = null;
    razonError = null;
    repError = null;
    dirError = null;
    telError = null;
    correoEmpresaError = null;
    adminEmailError = null;
    adminPassError = null;
    nombreAdminError = null;

    // Validaciones por campo
    if (rnc.isEmpty) rncError = 'Requerido';
    if (razon.isEmpty) razonError = 'Requerido';
    if (rep.isEmpty) repError = 'Requerido';
    if (dir.isEmpty) dirError = 'Requerido';
    if (tel.isEmpty) telError = 'Requerido';
    if (correoEmpresa.isEmpty) correoEmpresaError = 'Requerido';
    if (!adminEmail.contains('@')) adminEmailError = 'Correo inválido';
    if (adminPass.length < 6) adminPassError = 'Mínimo 6 caracteres';
    if (nombreAdmin.isEmpty) nombreAdminError = 'Requerido';

    final hasErrors = [
      rncError,
      razonError,
      repError,
      dirError,
      telError,
      correoEmpresaError,
      adminEmailError,
      adminPassError,
      nombreAdminError,
    ].any((e) => e != null);

    if (hasErrors) {
      errorMessage = 'Corrige los campos marcados.';
      _safeUpdate();
      return;
    }

    loading = true;
    errorMessage = null;
    _safeUpdate();

    User? createdUser;
    try {
      // Creamos usuario admin en Firebase Auth
      final cred = await _auth.registerWithEmailPassword(
        email: adminEmail,
        password: adminPass,
      );
      createdUser = cred.user;
      final uid = createdUser?.uid;

      // Escrituras atómicas con batch: empresa y perfil de usuario
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      final companyRef = db.doc('companies/$rnc');
      batch.set(companyRef, {
        'rnc': rnc,
        'razonSocial': razon,
        'representanteFiscal': rep,
        'direccion': dir,
        'telefono': tel,
        'correo': correoEmpresa,
        'adminUid': uid,
        'adminEmail': adminEmail,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (uid != null && uid.isNotEmpty) {
        final userRef = db.doc('users/$uid');
        batch.set(userRef, {
          'uid': uid,
          'email': adminEmail,
          'nombre': nombreAdmin, // Guardar el nombre del administrador
          'companyRnc': rnc,
          'companyName': razon,
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();

      // Marcador de sesión para Splash
      box.write('f_nombre_usuario', adminEmail);
      // Guardar el nombre del usuario para usar en PDFs
      await UserService.saveUserNameToStorage();
      LoggerService().info('register.success', {
        'adminEmail': adminEmail,
        'companyRnc': rnc,
      });

      // Navegación a Home (asegura desfocar para evitar uso tras dispose)
      FocusManager.instance.primaryFocus?.unfocus();
      Get.offAllNamed(AppRoutes.HOME);
    } catch (e) {
      // Si falló Firestore tras crear el usuario, intenta eliminar el usuario para evitar "email ya existe".
      try {
        await createdUser?.delete();
      } catch (_) {}
      LoggerService().error('register.error', e, StackTrace.current, {
        'adminEmail': adminEmail,
        'companyRnc': rnc,
      });
      errorMessage = _messageForError(e);
      loading = false;
      _safeUpdate();
    }
  }

  void clearFieldError(String fieldKey) {
    switch (fieldKey) {
      case 'rnc':
        rncError = null;
        break;
      case 'razon':
        razonError = null;
        break;
      case 'rep':
        repError = null;
        break;
      case 'dir':
        dirError = null;
        break;
      case 'tel':
        telError = null;
        break;
      case 'correoEmpresa':
        correoEmpresaError = null;
        break;
      case 'adminEmail':
        adminEmailError = null;
        break;
      case 'adminPass':
        adminPassError = null;
        break;
      case 'nombreAdmin':
        nombreAdminError = null;
        break;
    }
    _safeUpdate();
  }

  String _messageForError(Object e) {
    final msg = e.toString();
    if (msg.contains('email-already-in-use'))
      return 'El correo del administrador ya está en uso.';
    if (msg.contains('invalid-email'))
      return 'Correo de administrador inválido.';
    return 'No se pudo completar el registro. Intenta nuevamente.';
  }

  @override
  void onClose() {
    // Evita que campos todavía con foco sigan notificando tras dispose
    FocusManager.instance.primaryFocus?.unfocus();
    rncCtrl.dispose();
    razonSocialCtrl.dispose();
    representanteFiscalCtrl.dispose();
    direccionCtrl.dispose();
    telefonoCtrl.dispose();
    correoEmpresaCtrl.dispose();
    adminEmailCtrl.dispose();
    adminPasswordCtrl.dispose();
    nombreAdminCtrl.dispose();
    super.onClose();
  }
}
