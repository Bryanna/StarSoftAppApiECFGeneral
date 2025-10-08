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
        // Si no hay usuario autenticado, usar configuración por defecto con datos fake
        LoggerService().info('company_config.no_user_using_fake_data', {});
        return {
          'useFakeData': true,
          'razonSocial': 'CENTRO MEDICO PREVENTIVO SALUD Y VIDA SRL',
          'logoUrl':
              'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png',
        };
      }

      // Obtener datos del usuario para conseguir el RNC de la empresa
      final userDoc = await _db.doc('users/$uid').get();
      final userData = userDoc.data();
      final companyRnc = userData?['companyRnc'] as String?;

      if (companyRnc == null || companyRnc.isEmpty) {
        // Si no hay empresa asignada, usar datos fake
        LoggerService().info('company_config.no_company_using_fake_data', {});
        return {
          'useFakeData': true,
          'razonSocial': 'CENTRO MEDICO PREVENTIVO SALUD Y VIDA SRL',
          'logoUrl':
              'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png',
        };
      }

      // Obtener datos de la empresa
      final companyDoc = await _db.doc('companies/$companyRnc').get();
      final companyData = companyDoc.data();

      if (companyData == null) {
        // Si no hay datos de la empresa, usar datos fake
        LoggerService().info('company_config.no_company_data_using_fake_data', {
          'companyRnc': companyRnc,
        });
        return {
          'useFakeData': true,
          'razonSocial': 'CENTRO MEDICO PREVENTIVO SALUD Y VIDA SRL',
          'logoUrl':
              'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png',
        };
      }

      // Si no tiene URL del ERP configurada, habilitar datos fake
      final erpUrl = companyData['urlERPEndpoint'] as String?;
      if (erpUrl == null || erpUrl.isEmpty || erpUrl == 'Sin configurar') {
        companyData['useFakeData'] = true;
      }

      LoggerService().info('company_config.get_success', {
        'companyRnc': companyRnc,
        'hasConfig': true,
        'useFakeData': companyData['useFakeData'] ?? false,
      });

      return companyData;
    } catch (e, st) {
      LoggerService().error('company_config.get_error', e, st);
      // En caso de error, usar datos fake como fallback
      return {
        'useFakeData': true,
        'razonSocial': 'CENTRO MEDICO PREVENTIVO SALUD Y VIDA SRL',
        'logoUrl':
            'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png',
      };
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
