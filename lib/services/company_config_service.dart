import '../services/firestore_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/logger_service.dart';
import '../models/company_model.dart';

class CompanyConfigService {
  final FirestoreService _db = FirestoreService();
  final FirebaseAuthService _auth = FirebaseAuthService();

  /// Obtiene la empresa del usuario actual
  Future<CompanyModel?> getCurrentCompany() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      // Obtener datos del usuario para conseguir el RNC de la empresa
      final userDoc = await _db.doc('users/$uid').get();
      final userData = userDoc.data();
      final companyRnc = userData?['companyRnc'] as String?;

      if (companyRnc == null || companyRnc.isEmpty) {
        return null;
      }

      // Obtener datos de la empresa
      final companyDoc = await _db.doc('companies/$companyRnc').get();
      final companyData = companyDoc.data();

      if (companyData == null) {
        return null;
      }

      return CompanyModel.fromJson(companyData);
    } catch (e, st) {
      LoggerService().error('company_config.get_current_company_error', e, st);
      return null;
    }
  }

  /// Crea una nueva empresa para el usuario
  Future<CompanyModel> createCompany({
    required String rnc,
    required String razonSocial,
    String? nombreComercial,
    String? direccion,
    String? telefono,
    String? email,
    String? website,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('Usuario no autenticado');

      final company = CompanyModel(
        rnc: rnc,
        razonSocial: razonSocial,
        nombreComercial: nombreComercial,
        direccion: direccion,
        telefono: telefono,
        email: email,
        website: website,
        isConfigured: false, // NUNCA marcar como configurado hasta el final
        useFakeData: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: uid,
      );

      // Guardar empresa
      await _db.doc('companies/$rnc').set(company.toJson());

      // Asociar usuario con la empresa
      await _db.doc('users/$uid').update({
        'companyRnc': rnc,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      LoggerService().info('company_config.create_success', {
        'companyRnc': rnc,
        'userId': uid,
      });

      return company;
    } catch (e, st) {
      LoggerService().error('company_config.create_error', e, st);
      rethrow;
    }
  }

  /// Actualiza la configuración de la empresa
  Future<CompanyModel> updateCompany(CompanyModel company) async {
    try {
      final updatedCompany = company.copyWith(updatedAt: DateTime.now());

      await _db.doc('companies/${company.rnc}').update(updatedCompany.toJson());

      LoggerService().info('company_config.update_success', {
        'companyRnc': company.rnc,
      });

      return updatedCompany;
    } catch (e, st) {
      LoggerService().error('company_config.update_error', e, st);
      rethrow;
    }
  }

  /// Marca la empresa como configurada
  Future<CompanyModel> markAsConfigured(String rnc) async {
    try {
      final company = await getCompanyByRnc(rnc);
      if (company == null) throw Exception('Empresa no encontrada');

      final updatedCompany = company.copyWith(
        isConfigured: true,
        updatedAt: DateTime.now(),
      );

      await _db.doc('companies/$rnc').update(updatedCompany.toJson());

      LoggerService().info('company_config.mark_configured_success', {
        'companyRnc': rnc,
      });

      return updatedCompany;
    } catch (e, st) {
      LoggerService().error('company_config.mark_configured_error', e, st);
      rethrow;
    }
  }

  /// Obtiene una empresa por RNC
  Future<CompanyModel?> getCompanyByRnc(String rnc) async {
    try {
      final companyDoc = await _db.doc('companies/$rnc').get();
      final companyData = companyDoc.data();

      if (companyData == null) return null;

      return CompanyModel.fromJson(companyData);
    } catch (e, st) {
      LoggerService().error('company_config.get_by_rnc_error', e, st);
      return null;
    }
  }

  /// Verifica si el usuario necesita configuración inicial
  Future<bool> needsInitialSetup() async {
    try {
      final company = await getCurrentCompany();
      return company?.needsSetup ?? true;
    } catch (e, st) {
      LoggerService().error('company_config.needs_setup_error', e, st);
      return true;
    }
  }

  /// Obtiene el paso actual de configuración
  Future<int> getCurrentSetupStep() async {
    try {
      final company = await getCurrentCompany();
      return company?.currentSetupStep ?? 1;
    } catch (e, st) {
      LoggerService().error('company_config.get_step_error', e, st);
      return 1;
    }
  }

  /// Verifica si la configuración está completa
  Future<bool> isSetupComplete() async {
    try {
      final company = await getCurrentCompany();

      // Si no hay empresa, necesita setup
      if (company == null) return false;

      // Verificar directamente el campo isConfigured
      return company.isConfigured;
    } catch (e, st) {
      LoggerService().error('company_config.is_complete_error', e, st);
      return false;
    }
  }

  /// Obtiene la configuración de la empresa (método legacy para compatibilidad)
  Future<Map<String, dynamic>?> getCompanyConfig() async {
    try {
      final company = await getCurrentCompany();
      if (company == null) {
        // Fallback para compatibilidad
        return {
          'useFakeData': true,
          'razonSocial': 'CENTRO MEDICO PREVENTIVO SALUD Y VIDA SRL',
          'logoUrl':
              'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png',
        };
      }

      return company.toJson();
    } catch (e, st) {
      LoggerService().error('company_config.get_config_error', e, st);
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
