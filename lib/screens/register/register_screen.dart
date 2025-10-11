import 'package:facturacion/screens/register/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:facturacion/routes/app_routes.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterController>(
      init: RegisterController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(
                        Theme.of(context).brightness == Brightness.dark
                            ? 0.35
                            : 0.15,
                      ),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 28,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Image.asset('assets/logo2.png', height: 64)],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Registro de Empresa (Admin)',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Datos de la empresa',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: controller.rncCtrl,
                        onChanged: (_) => controller.clearFieldError('rnc'),
                        decoration: _input(
                          context,
                          'RNC',
                          errorText: controller.rncError,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.razonSocialCtrl,
                        onChanged: (_) => controller.clearFieldError('razon'),
                        decoration: _input(
                          context,
                          'Razón social',
                          errorText: controller.razonError,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.representanteFiscalCtrl,
                        onChanged: (_) => controller.clearFieldError('rep'),
                        decoration: _input(
                          context,
                          'Representante fiscal',
                          errorText: controller.repError,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.nombreAdminCtrl,
                        onChanged: (_) =>
                            controller.clearFieldError('nombreAdmin'),
                        decoration: _input(
                          context,
                          'Nombre del administrador',
                          errorText: controller.nombreAdminError,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.direccionCtrl,
                        onChanged: (_) => controller.clearFieldError('dir'),
                        decoration: _input(
                          context,
                          'Dirección',
                          errorText: controller.dirError,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => controller.clearFieldError('tel'),
                        decoration: _input(
                          context,
                          'Teléfono empresa',
                          errorText: controller.telError,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.correoEmpresaCtrl,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) =>
                            controller.clearFieldError('correoEmpresa'),
                        decoration: _input(
                          context,
                          'Correo empresa',
                          errorText: controller.correoEmpresaError,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Administrador',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.adminEmailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) =>
                            controller.clearFieldError('adminEmail'),
                        decoration: _input(
                          context,
                          'Correo administrador',
                          errorText: controller.adminEmailError,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.adminPasswordCtrl,
                        obscureText: true,
                        onChanged: (_) =>
                            controller.clearFieldError('adminPass'),
                        decoration: _input(
                          context,
                          'Contraseña administrador (mín 6)',
                          errorText: controller.adminPassError,
                        ),
                        onSubmitted: (_) => controller.submit(),
                      ),
                      const SizedBox(height: 10),
                      ...(controller.errorMessage != null
                          ? [
                              Text(
                                controller.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ]
                          : const []),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: controller.loading
                                    ? null
                                    : controller.submit,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: controller.loading
                                        ? Theme.of(context).disabledColor
                                        : Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    controller.loading
                                        ? 'Registrando...'
                                        : 'Registrar empresa',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  Get.offAllNamed(AppRoutes.LOGIN);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Volver a Login',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _input(
    BuildContext context,
    String label, {
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.35),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
