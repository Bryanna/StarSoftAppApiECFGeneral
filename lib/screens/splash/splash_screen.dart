import 'package:animate_do/animate_do.dart';
import 'package:facturacion/screens/splash/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) => Scaffold(
        backgroundColor: Color(0xFF22538b),
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeIn(
                duration: const Duration(seconds: 5),
                child: Image.asset('assets/logo.png', height: 400),
              ),
              FadeInLeftBig(
                duration: const Duration(seconds: 6),
                child: Text(
                  'Facturador Electrónico',
                  style: GoogleFonts.inter(fontSize: 30, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
