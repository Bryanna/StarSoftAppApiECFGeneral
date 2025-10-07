import 'package:facturacion/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'firebase_options.dart';
import 'services/logger_service.dart';

import 'routes/app_pages.dart';
import 'screens/home/home_binding.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa GetStorage para usar localStorage/web (persistencia de sesión)
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Facturacion',
      theme: ThemeData(
        useMaterial3: true,
        // Usa Inter como familia tipográfica principal. Si no está instalada,
        // Flutter usará la fuente del sistema como fallback.
        fontFamily: 'Inter',
      ),
      home: const SplashScreen(),
      initialBinding: SplashBinding(),
      getPages: AppPages.pages,
    );
  }
}
