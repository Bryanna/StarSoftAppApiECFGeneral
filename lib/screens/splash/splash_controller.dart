import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:facturacion/services/logger_service.dart';
import '../../services/company_config_service.dart';
import '../../services/firebase_auth_service.dart';

import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final box = GetStorage();
  final CompanyConfigService _companyService = CompanyConfigService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  var isLoading = false;

  @override
  void onInit() async {
    super.onInit();
    // box.erase(); // Clear storage for testing purposes
    await _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      isLoading = true;
      update();

      // Esperar un poco para mostrar el splash
      await Future.delayed(const Duration(seconds: 3));

      // Verificar si hay sesión guardada
      final userName = box.read('f_nombre_usuario');

      if (userName != null) {
        LoggerService().info('splash.hasSession', {'user': userName});

        // Verificar si el usuario está autenticado en Firebase
        final currentUser = _authService.currentUser;

        if (currentUser != null) {
          // Usuario autenticado, verificar configuración de empresa
          await _checkCompanySetup();
        } else {
          // Sesión local pero no en Firebase, ir a login
          LoggerService().info('splash.sessionExpired');
          Get.offNamed(AppRoutes.LOGIN);
        }
      } else {
        // No hay sesión, ir a login
        LoggerService().info('splash.noSession');
        Get.offNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      LoggerService().error('splash.initError', e, null);
      // En caso de error, ir a login
      Get.offNamed(AppRoutes.LOGIN);
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> _checkCompanySetup() async {
    try {
      // Verificar si la configuración está completa
      final isComplete = await _companyService.isSetupComplete();

      LoggerService().info('splash.checkingSetup', {'isComplete': isComplete});

      if (isComplete) {
        LoggerService().info('splash.setupComplete');
        // Configuración completa, ir al home
        Get.offNamed(AppRoutes.HOME);
      } else {
        final currentStep = await _companyService.getCurrentSetupStep();
        LoggerService().info('splash.needsSetup', {'currentStep': currentStep});
        // Redirigir a configuración inicial (continuará desde donde se quedó)
        Get.offNamed(AppRoutes.SETUP);
      }
    } catch (e) {
      LoggerService().error('splash.setupCheckError', e, null);
      // En caso de error, asumir que necesita setup
      Get.offNamed(AppRoutes.SETUP);
    }
  }
}
