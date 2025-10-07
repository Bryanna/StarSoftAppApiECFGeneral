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
          backgroundColor: const Color(0xFF22538b),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
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
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF22538b)),
                      ),
                      const SizedBox(height: 24),
                      Text('Datos de la empresa', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: controller.rncCtrl,
                        onChanged: (_) => controller.clearFieldError('rnc'),
                        decoration: _input('RNC', errorText: controller.rncError),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.razonSocialCtrl,
                        onChanged: (_) => controller.clearFieldError('razon'),
                        decoration: _input('Razón social', errorText: controller.razonError),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.representanteFiscalCtrl,
                        onChanged: (_) => controller.clearFieldError('rep'),
                        decoration: _input('Representante fiscal', errorText: controller.repError),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.direccionCtrl,
                        onChanged: (_) => controller.clearFieldError('dir'),
                        decoration: _input('Dirección', errorText: controller.dirError),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.telefonoCtrl,
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => controller.clearFieldError('tel'),
                        decoration: _input('Teléfono empresa', errorText: controller.telError),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.correoEmpresaCtrl,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => controller.clearFieldError('correoEmpresa'),
                        decoration: _input('Correo empresa', errorText: controller.correoEmpresaError),
                      ),
                      const SizedBox(height: 18),
                      Text('Administrador', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.adminEmailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => controller.clearFieldError('adminEmail'),
                        decoration: _input('Correo administrador', errorText: controller.adminEmailError),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.adminPasswordCtrl,
                        obscureText: true,
                        onChanged: (_) => controller.clearFieldError('adminPass'),
                        decoration: _input('Contraseña administrador (mín 6)', errorText: controller.adminPassError),
                        onSubmitted: (_) => controller.submit(),
                      ),
                      const SizedBox(height: 10),
                      ...(controller.errorMessage != null
                          ? [Text(controller.errorMessage!, style: const TextStyle(color: Colors.red))]
                          : const []),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: controller.loading ? null : controller.submit,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: controller.loading ? Colors.grey.shade400 : const Color(0xFF22538b),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    controller.loading ? 'Registrando...' : 'Registrar empresa',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
                                onTap: () => Get.offAllNamed(AppRoutes.LOGIN),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('Volver a Login'),
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

  InputDecoration _input(String label, {String? errorText}) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}
