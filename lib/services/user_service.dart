import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';

class UserService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GetStorage _storage = GetStorage();

  /// Obtiene el nombre del usuario logueado desde Firestore
  static Future<String?> getCurrentUserName() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _db.doc('users/${user.uid}').get();
      if (doc.exists) {
        final data = doc.data();
        return data?['nombre'] as String?;
      }
    } catch (e) {
      print('Error obteniendo nombre del usuario: $e');
    }
    return null;
  }

  /// Guarda el nombre del usuario en localStorage para acceso rápido
  static Future<void> saveUserNameToStorage() async {
    final nombre = await getCurrentUserName();
    if (nombre != null) {
      _storage.write('user_name', nombre);
    }
  }

  /// Obtiene el nombre del usuario desde localStorage (más rápido)
  static String? getUserNameFromStorage() {
    return _storage.read('user_name');
  }

  /// Obtiene el nombre del usuario, primero desde storage, luego desde Firestore
  static Future<String> getUserDisplayName() async {
    // Intentar desde storage primero
    String? nombre = getUserNameFromStorage();
    if (nombre != null && nombre.isNotEmpty) {
      return nombre;
    }

    // Si no está en storage, obtener desde Firestore
    nombre = await getCurrentUserName();
    if (nombre != null && nombre.isNotEmpty) {
      // Guardar en storage para próximas veces
      _storage.write('user_name', nombre);
      return nombre;
    }

    // Fallback al email del usuario
    final user = _auth.currentUser;
    if (user?.email != null) {
      return user!.email!;
    }

    return 'Usuario';
  }

  /// Limpia los datos del usuario del storage (para logout)
  static void clearUserData() {
    _storage.remove('user_name');
    _storage.remove('f_nombre_usuario');
  }
}
