import 'package:facturacion/screens/splash/splash_binding.dart';
import 'package:facturacion/screens/splash/splash_screen.dart';
import 'package:get/get.dart';

import '../screens/home/home_binding.dart';
import '../screens/home/home_screen.dart';
import '../screens/invoice_preview/invoice_preview_screen.dart';
import '../screens/invoice_preview/portable_preview_screen.dart';
import '../screens/login/login_binding.dart';
import '../screens/login/login_screen.dart';
import '../screens/register/register_binding.dart';
import '../screens/register/register_screen.dart';

import '../screens/profile/profile_screen.dart';
import '../screens/configuracion/configuracion_binding.dart';
import '../screens/configuracion/configuracion_screen.dart';
import '../screens/pdf_maker/pdf_maker_binding.dart';
import '../screens/pdf_maker/pdf_maker_screen.dart';
import '../screens/queue/queue_screen_simple.dart';
import '../screens/setup/unified_setup_screen.dart';
import '../screens/setup/setup_access_screen.dart';
import '../screens/schema_builder/schema_builder_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.INVOICE_PREVIEW,
      page: () => const InvoicePreviewScreen(),
    ),
    GetPage(
      name: AppRoutes.PORTABLE_PREVIEW,
      page: () => const PortablePreviewScreen(),
    ),
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileScreen(),
      // Perfil simple: no binding dedicado, el controlador puede inicializarse en pantalla si se requiere
    ),
    GetPage(
      name: AppRoutes.CONFIGURACION,
      page: () => const ConfiguracionScreen(),
      binding: ConfiguracionBinding(),
    ),
    GetPage(
      name: AppRoutes.PDF_MAKER,
      page: () => const PdfMakerScreen(),
      binding: PdfMakerBinding(),
    ),
    GetPage(name: AppRoutes.QUEUE, page: () => const QueueScreenSimple()),
    GetPage(name: AppRoutes.SETUP, page: () => const UnifiedSetupScreen()),
    GetPage(
      name: AppRoutes.SETUP_ACCESS,
      page: () => const SetupAccessScreen(),
    ),
    GetPage(
      name: AppRoutes.SCHEMA_BUILDER,
      page: () => const SchemaBuilderScreen(),
    ),
  ];
}
