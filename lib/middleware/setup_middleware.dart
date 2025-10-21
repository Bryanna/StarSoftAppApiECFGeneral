import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/company_config_service.dart';

/// Middleware que verifica si la empresa necesita configuración inicial
class SetupMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Solo verificar en rutas principales, no en setup o auth
    if (route == null ||
        route.startsWith('/setup') ||
        route.startsWith('/login') ||
        route.startsWith('/register')) {
      return null;
    }

    return null; // La verificación se hace de forma asíncrona en GetMaterialApp
  }

  /// Verifica si necesita configuración inicial
  static Future<bool> needsSetup() async {
    try {
      final companyService = CompanyConfigService();
      return await companyService.needsInitialSetup();
    } catch (e) {
      debugPrint('Error verificando setup: $e');
      return true; // En caso de error, asumir que necesita setup
    }
  }

  /// Redirige a setup si es necesario
  static Future<void> checkAndRedirectToSetup() async {
    final needsSetup = await SetupMiddleware.needsSetup();

    if (needsSetup) {
      // Redirigir a configuración inicial
      Get.offAllNamed('/setup');
    }
  }
}
