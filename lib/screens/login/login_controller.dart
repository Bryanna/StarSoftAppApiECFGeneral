import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:facturacion/services/firebase_auth_service.dart';
import 'package:facturacion/routes/app_routes.dart';
import 'package:facturacion/services/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final box = GetStorage();

  // Form controllers
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // UI state
  bool loading = false;
  String? errorMessage;
  bool obscurePassword = true;

  void toggleObscure() {
    obscurePassword = !obscurePassword;
    update();
  }

  Future<void> signIn() async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    // Basic validation
    if (email.isEmpty || !email.contains('@')) {
      errorMessage = 'Ingresa un correo válido.';
      update();
      return;
    }
    if (password.isEmpty || password.length < 6) {
      errorMessage = 'La contraseña debe tener al menos 6 caracteres.';
      update();
      return;
    }

    loading = true;
    errorMessage = null;
    update();

  try {
      await _authService.signInWithEmailPassword(email: email, password: password);
      // Persist a marker compatible with SplashController
      box.write('f_nombre_usuario', email);
      LoggerService().info('login.success', {'email': email});
      Get.offAllNamed(AppRoutes.HOME);
  } catch (e) {
      LoggerService().error('login.error', e, StackTrace.current, {'email': email});
      errorMessage = _messageForError(e);
      loading = false;
      update();
  }
  }

  void showRegisterDialog() {
    final regEmailCtrl = TextEditingController(text: emailCtrl.text.trim());
    final regPasswordCtrl = TextEditingController();
    final regConfirmCtrl = TextEditingController();
    String? dialogError;
    bool dialogLoading = false;

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Crear cuenta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: regEmailCtrl,
                    decoration: const InputDecoration(labelText: 'Correo electrónico'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: regPasswordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña (mín 6)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: regConfirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 12),
                    Text(dialogError!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: dialogLoading
                              ? null
                              : () async {
                                  final email = regEmailCtrl.text.trim();
                                  final pass = regPasswordCtrl.text;
                                  final confirm = regConfirmCtrl.text;
                                  if (email.isEmpty || !email.contains('@')) {
                                    setState(() => dialogError = 'Correo inválido.');
                                    return;
                                  }
                                  if (pass.length < 6) {
                                    setState(() => dialogError = 'Contraseña muy corta.');
                                    return;
                                  }
                                  if (pass != confirm) {
                                    setState(() => dialogError = 'Las contraseñas no coinciden.');
                                    return;
                                  }
                                  setState(() {
                                    dialogError = null;
                                    dialogLoading = true;
                                  });
                                  try {
                                    await _authService.registerWithEmailPassword(email: email, password: pass);
                                    box.write('f_nombre_usuario', email);
                                    Get.back(); // close dialog
                                    Get.offAllNamed(AppRoutes.HOME);
                                  } catch (e) {
                                    setState(() {
                                      dialogError = _messageForError(e);
                                      dialogLoading = false;
                                    });
                                  }
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22538b),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              dialogLoading ? 'Creando...' : 'Crear cuenta',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Text('Cancelar'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      barrierDismissible: true,
    );
  }

  void showResetPasswordDialog() {
    final resetEmailCtrl = TextEditingController(text: emailCtrl.text.trim());
    String? dialogError;
    bool dialogLoading = false;
    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recuperar contraseña', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: resetEmailCtrl,
                    decoration: const InputDecoration(labelText: 'Correo electrónico'),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 12),
                    Text(dialogError!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: dialogLoading
                        ? null
                        : () async {
                            final email = resetEmailCtrl.text.trim();
                            if (email.isEmpty || !email.contains('@')) {
                              setState(() => dialogError = 'Ingresa un correo válido.');
                              return;
                            }
                            setState(() {
                              dialogError = null;
                              dialogLoading = true;
                            });
                            try {
                              await _authService.sendPasswordResetEmail(email);
                              Get.back();
                              Get.snackbar('Correo enviado', 'Revisa tu bandeja de entrada para continuar.', snackPosition: SnackPosition.BOTTOM);
                            } catch (e) {
                              setState(() {
                                dialogError = _messageForError(e);
                                dialogLoading = false;
                              });
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22538b),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dialogLoading ? 'Enviando...' : 'Enviar correo de recuperación',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      barrierDismissible: true,
    );
  }

  String _messageForError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuario no encontrado.';
        case 'wrong-password':
          return 'Contraseña incorrecta.';
        case 'invalid-email':
          return 'Correo inválido.';
        case 'email-already-in-use':
          return 'El correo ya está en uso.';
        case 'operation-not-allowed':
          return 'Método de inicio de sesión no habilitado en Firebase.';
        case 'too-many-requests':
          return 'Demasiados intentos. Intenta más tarde.';
        case 'network-request-failed':
          return 'Fallo de red. Verifica tu conexión.';
        case 'user-disabled':
          return 'Usuario deshabilitado.';
      }
    }
    return 'Ocurrió un error. Intenta nuevamente.';
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
