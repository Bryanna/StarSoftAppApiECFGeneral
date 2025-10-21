import 'package:facturacion/screens/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'screens/splash/splash_binding.dart';
import 'services/logger_service.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa GetStorage para usar localStorage/web (persistencia de sesión)
  await GetStorage.init();
  // await GetStorage().erase();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar servicios (singleton se inicializa automáticamente)
  // El procesador se iniciará cuando el usuario se autentique

  // Captura errores de Flutter y los registra
  FlutterError.onError = (FlutterErrorDetails details) {
    LoggerService().error('flutter_error', details.exception, details.stack, {
      'library': details.library,
    });
  };
  // Evita descargas en tiempo de ejecución de fuentes en web para prevenir
  // errores de conexión a fonts.gstatic.com cuando la red está restringida.
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Facturacion',
      theme: themeService.lightTheme,
      darkTheme: themeService.darkTheme,
      themeMode: themeService.themeMode,
      home: const SplashScreen(),
      initialBinding: SplashBinding(),
      getPages: AppPages.pages,
    );
  }
}
