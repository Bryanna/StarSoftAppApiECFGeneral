import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../firebase_options.dart';
import '../../services/firestore_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/logger_service.dart';

class ProfileController extends GetxController {
  final FirestoreService _db = FirestoreService();
  final FirebaseAuthService _authDefault = FirebaseAuthService();

  FirebaseAuth? _authSecondary;
  FirebaseApp? _secondaryApp;

  Map<String, dynamic>? userData;
  bool isAdmin = false;
  String? companyRnc;
  String? companyName;

  bool loading = true;
  String? errorMessage;

  // Form to create new user (admin only)
  final newNameCtrl = TextEditingController();
  final newEmailCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  String newRole = 'user';

  Stream<QuerySnapshot<Map<String, dynamic>>>? usersStream;

  // Método alternativo para obtener usuarios si el stream falla
  Future<List<Map<String, dynamic>>> getUsersList() async {
    if (!isAdmin || companyRnc == null || companyRnc!.isEmpty) {
      return [];
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('companyRnc', isEqualTo: companyRnc)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e, st) {
      LoggerService().error('profile.get_users_list_error', e, st);
      return [];
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initSecondaryApp().then((_) => _loadCurrentUser());
  }

  Future<void> _initSecondaryApp() async {
    try {
      // Initialize a secondary Firebase app so creating users won't affect the current session
      final existing = Firebase.apps
          .where((a) => a.name == 'secondary')
          .toList();
      if (existing.isEmpty) {
        _secondaryApp = await Firebase.initializeApp(
          name: 'secondary',
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        _secondaryApp = existing.first;
      }
      _authSecondary = FirebaseAuth.instanceFor(app: _secondaryApp!);
    } catch (e, st) {
      LoggerService().error('profile.secondary_init_error', e, st);
    }
  }

  void _loadCurrentUser() {
    final uid = _authDefault.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      loading = false;
      errorMessage = 'No hay sesión activa.';
      update();
      return;
    }
    usersStream = null; // will set after we know companyRnc
    _db
        .streamDoc('users/$uid')
        .listen(
          (snap) {
            final data = snap.data();
            userData = data;
            final role = data?['role'] as String?;
            isAdmin = role == 'admin';
            companyRnc = data?['companyRnc'] as String?;
            companyName = data?['companyName'] as String?;
            loading = false;
            // Prepare users stream for admin (same company)
            if (isAdmin && companyRnc != null && companyRnc!.isNotEmpty) {
              try {
                // Crear stream simple sin orderBy para evitar problemas de índices
                usersStream = FirebaseFirestore.instance
                    .collection('users')
                    .where('companyRnc', isEqualTo: companyRnc)
                    .snapshots();

                LoggerService().info('profile.users_stream_initialized', {
                  'companyRnc': companyRnc,
                  'isAdmin': isAdmin,
                });
              } catch (e, st) {
                LoggerService().error('profile.users_stream_error', e, st);
                usersStream = null;
              }
            } else {
              usersStream = null;
              LoggerService().info('profile.users_stream_not_initialized', {
                'isAdmin': isAdmin,
                'companyRnc': companyRnc,
              });
            }
            update();
          },
          onError: (e) {
            LoggerService().error('profile.load_error', e);
            errorMessage = 'No se pudo cargar el perfil.';
            loading = false;
            update();
          },
        );
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    if (!isAdmin) return;
    if (_authSecondary == null) {
      errorMessage = 'Auth secundario no inicializado.';
      update();
      return;
    }
    if (companyRnc == null || companyName == null) {
      errorMessage = 'Empresa no determinada.';
      update();
      return;
    }
    loading = true;
    update();
    try {
      final cred = await _authSecondary!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid == null || uid.isEmpty) {
        throw Exception('No se pudo crear el usuario.');
      }
      await _db.set('users/$uid', {
        'uid': uid,
        'email': email.trim(),
        'nombre': name.trim(),
        'companyRnc': companyRnc,
        'companyName': companyName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      LoggerService().info('profile.create_user.success', {
        'email': email,
        'role': role,
        'companyRnc': companyRnc,
      });
      // Clear form
      newNameCtrl.clear();
      newEmailCtrl.clear();
      newPasswordCtrl.clear();
      newRole = 'user';
      Get.snackbar(
        'Éxito',
        'Usuario creado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, st) {
      LoggerService().error('profile.create_user.error', e, st, {
        'email': email,
        'role': role,
      });
      errorMessage = _messageForError(e);
      Get.snackbar(
        'Error',
        errorMessage ?? 'No se pudo crear el usuario',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      loading = false;
      update();
    }
  }

  Future<void> deleteUser(String email) async {
    if (!isAdmin) return;

    loading = true;
    update();

    try {
      // Find user by email in the same company
      final querySnapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .where('companyRnc', isEqualTo: companyRnc)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Usuario no encontrado.');
      }

      final userDoc = querySnapshot.docs.first;
      final userId = userDoc.id;

      // Don't allow deleting yourself
      if (userId == _authDefault.currentUser?.uid) {
        throw Exception('No puedes eliminar tu propia cuenta.');
      }

      // Delete user document from Firestore
      await _db.delete('users/$userId');

      LoggerService().info('profile.delete_user.success', {
        'email': email,
        'userId': userId,
        'companyRnc': companyRnc,
      });

      Get.snackbar(
        'Éxito',
        'Usuario eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e, st) {
      LoggerService().error('profile.delete_user.error', e, st, {
        'email': email,
      });

      String errorMsg = 'No se pudo eliminar el usuario';
      if (e is Exception) {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      }

      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      loading = false;
      update();
    }
  }

  String _messageForError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'El correo ya está en uso.';
        case 'invalid-email':
          return 'Correo inválido.';
        case 'operation-not-allowed':
          return 'Método de registro no habilitado en Firebase.';
        case 'weak-password':
          return 'La contraseña es demasiado débil.';
        case 'network-request-failed':
          return 'Fallo de red. Verifica tu conexión.';
      }
    }
    return 'Ocurrió un error al crear el usuario.';
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    loading = true;
    update();

    try {
      final user = _authDefault.currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado.');
      }

      // Re-autenticar al usuario con su contraseña actual
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Cambiar la contraseña
      await user.updatePassword(newPassword);

      LoggerService().info('profile.change_password.success', {
        'email': user.email,
      });

      Get.snackbar(
        'Éxito',
        'Contraseña actualizada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e, st) {
      LoggerService().error('profile.change_password.error', e, st);

      String errorMsg = 'No se pudo cambiar la contraseña';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            errorMsg = 'La contraseña actual es incorrecta';
            break;
          case 'weak-password':
            errorMsg = 'La nueva contraseña es demasiado débil';
            break;
          case 'requires-recent-login':
            errorMsg = 'Por seguridad, inicia sesión nuevamente';
            break;
          default:
            errorMsg = 'Error: ${e.message}';
        }
      } else if (e is Exception) {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      }

      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      loading = false;
      update();
    }
  }

  @override
  void onClose() {
    newNameCtrl.dispose();
    newEmailCtrl.dispose();
    newPasswordCtrl.dispose();
    super.onClose();
  }
}
