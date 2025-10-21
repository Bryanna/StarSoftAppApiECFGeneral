import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/company_setup_card.dart';
import '../../routes/app_routes.dart';

/// Pantalla de acceso rápido a configuraciones
class SetupAccessScreen extends StatelessWidget {
  const SetupAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Empresa'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado de configuración actual
            const CompanySetupCard(),
            const CompanyInfoCard(),

            const SizedBox(height: 24),

            // Opciones de configuración
            const Text(
              'Opciones de Configuración',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Tarjetas de opciones
            _ConfigOptionCard(
              icon: Icons.business_center,
              title: 'Configuración de Empresa',
              description:
                  'Información básica, esquemas de datos y conexión ERP',
              onTap: () => Get.toNamed(AppRoutes.SETUP),
            ),

            const SizedBox(height: 12),

            _ConfigOptionCard(
              icon: Icons.schema,
              title: 'Constructor de Esquemas',
              description: 'Crear y editar esquemas de datos personalizados',
              onTap: () => Get.toNamed(AppRoutes.SCHEMA_BUILDER),
            ),

            const SizedBox(height: 12),

            _ConfigOptionCard(
              icon: Icons.settings,
              title: 'Configuración del Sistema',
              description: 'Configuraciones avanzadas y preferencias',
              onTap: () => Get.toNamed(AppRoutes.CONFIGURACION),
            ),

            const SizedBox(height: 32),

            // Información adicional
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Información',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• La configuración de empresa es necesaria para usar el sistema\n'
                      '• Los esquemas de datos definen cómo se estructuran las facturas\n'
                      '• Puedes usar datos de prueba mientras configuras tu ERP\n'
                      '• Todas las configuraciones se pueden cambiar más tarde',
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfigOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ConfigOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF005285).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF005285), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
