import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:facturacion/services/logger_service.dart';

import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final box = GetStorage();
  var isLoading = false;

  @override
  void onInit() async {
    super.onInit();
    // box.erase(); // Clear storage for testing purposes
    loadHome();
  }

  loadHome() {
    final userName = box.read('f_nombre_usuario');
    if (userName != null) {
      LoggerService().info('splash.hasSession', {'user': userName});
      Timer(const Duration(seconds: 5), () {
        Get.offNamed(AppRoutes.HOME);
      });
    } else {
      LoggerService().info('splash.noSession');
      Timer(const Duration(seconds: 5), () {
        Get.offNamed(AppRoutes.LOGIN);
      });
    }
  }
}
