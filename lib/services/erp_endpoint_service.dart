import 'package:flutter/foundation.dart';
import '../models/erp_endpoint.dart';
import 'firestore_service.dart';
import 'firebase_auth_service.dart';

class ERPEndpointService {
  final FirestoreService _db = FirestoreService();
  final FirebaseAuthService _auth = FirebaseAuthService();

  static const String _endpointsCollection = 'erp_endpoints';

  /// Guarda un endpoint
  Future<void> saveEndpoint(String companyRnc, ERPEndpoint endpoint) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Usuario no autenticado');

      await _db
          .doc('companies/$companyRnc/$_endpointsCollection/${endpoint.id}')
          .set(endpoint.toJson());

      debugPrint('Endpoint guardado: ${endpoint.name}');
    } catch (e) {
      debugPrint('Error guardando endpoint: $e');
      rethrow;
    }
  }

  /// Obtiene todos los endpoints de una empresa
  Future<List<ERPEndpoint>> getEndpoints(String companyRnc) async {
    try {
      final snapshot = await _db
          .collection('companies/$companyRnc/$_endpointsCollection')
          .get();

      return snapshot.docs
          .map((doc) => ERPEndpoint.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo endpoints: $e');
      return [];
    }
  }

  /// Obtiene un endpoint específico
  Future<ERPEndpoint?> getEndpoint(String companyRnc, String endpointId) async {
    try {
      final doc = await _db
          .doc('companies/$companyRnc/$_endpointsCollection/$endpointId')
          .get();

      if (doc.exists) {
        return ERPEndpoint.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error obteniendo endpoint $endpointId: $e');
      return null;
    }
  }

  /// Actualiza un endpoint
  Future<void> updateEndpoint(
    String companyRnc,
    ERPEndpoint endpoint,
  ) async {
    try {
      final updatedEndpoint = endpoint.copyWith(updatedAt: DateTime.now());
      await _db
          .doc('companies/$companyRnc/$_endpointsCollection/${endpoint.id}')
          .update(updatedEndpoint.toJson());

      debugPrint('Endpoint actualizado: ${endpoint.name}');
    } catch (e) {
      debugPrint('Error actualizando endpoint: $e');
      rethrow;
    }
  }

  /// Elimina un endpoint
  Future<void> deleteEndpoint(String companyRnc, String endpointId) async {
    try {
      await _db
          .doc('companies/$companyRnc/$_endpointsCollection/$endpointId')
          .delete();

      debugPrint('Endpoint eliminado: $endpointId');
    } catch (e) {
      debugPrint('Error eliminando endpoint: $e');
      rethrow;
    }
  }

  /// Prueba un endpoint
  Future<Map<String, dynamic>> testEndpoint(ERPEndpoint endpoint) async {
    try {
      // Aquí implementarías la llamada HTTP real
      // Por ahora retornamos datos de ejemplo
      debugPrint('Probando endpoint: ${endpoint.url}');

      await Future.delayed(const Duration(seconds: 2));

      // Simular respuesta exitosa
      return {
        'success': true,
        'statusCode': 200,
        'data': {
          'message': 'Conexión exitosa',
          'endpoint': endpoint.name,
          'timestamp': DateTime.now().toIso8601String(),
        },
      };
    } catch (e) {
      debugPrint('Error probando endpoint: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Obtiene endpoints por tipo
  Future<List<ERPEndpoint>> getEndpointsByType(
    String companyRnc,
    EndpointType type,
  ) async {
    try {
      final allEndpoints = await getEndpoints(companyRnc);
      return allEndpoints.where((e) => e.type == type).toList();
    } catch (e) {
      debugPrint('Error obteniendo endpoints por tipo: $e');
      return [];
    }
  }
}
