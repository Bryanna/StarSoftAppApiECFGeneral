import '../services/firestore_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/logger_service.dart';

class CompanyConfigService {
  final FirestoreService _db = FirestoreService();
  final FirebaseAuthService _auth = FirebaseAuthService();

  /// Obtiene la configuración de la empresa del usuario actual
  Future<Map<String, dynamic>?> getCompanyConfig() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Obtener datos del usuario para conseguir el RNC de la empresa
      final userDoc = await _db.doc('users/$uid').get();
      final userData = userDoc.data();
      final companyRnc = userData?['companyRnc'] as String?;

      if (companyRnc == null || companyRnc.isEmpty) {
        throw Exception('Usuario no tiene empresa asignada');
      }

      // Obtener datos de la empresa
      final companyDoc = await _db.doc('companies/$companyRnc').get();
      final companyData = companyDoc.data();

      LoggerService().info('company_config.get_success', {
        'companyRnc': companyRnc,
        'hasConfig': companyData != null,
      });

      return companyData;
    } catch (e, st) {
      LoggerService().error('company_config.get_error', e, st);
      return null;
    }
  }

  /// Obtiene específicamente el URL del endpoint ERP
  Future<String?> getERPEndpointUrl() async {
    try {
      final config = await getCompanyConfig();
      return config?['urlERPEndpoint'] as String?;
    } catch (e, st) {
      LoggerService().error('company_config.get_erp_url_error', e, st);
      return null;
    }
  }

  /// Verifica si el ERP está configurado correctamente
  Future<bool> isERPConfigured() async {
    try {
      final erpUrl = await getERPEndpointUrl();
      return erpUrl != null &&
          erpUrl.isNotEmpty &&
          erpUrl != 'Sin configurar' &&
          Uri.tryParse(erpUrl) != null;
    } catch (e, st) {
      LoggerService().error('company_config.is_erp_configured_error', e, st);
      return false;
    }
  }
}
