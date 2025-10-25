import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'test_individual_endpoints.dart';
import 'debug_invoices_only.dart';
import 'test_combined_endpoints.dart';

/// Pantalla de navegación para acceder a todos los tests
class TestNavigationScreen extends StatelessWidget {
  const TestNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tests de Endpoints'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Tests Disponibles',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona un test para debuggear el problema de los endpoints.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            // Lista de tests
            Expanded(
              child: ListView(
                children: [
                  _TestCard(
                    title: 'Test Individual de Endpoints',
                    description:
                        'Llama a cada endpoint por separado para ver qué datos devuelve cada uno.',
                    icon: Icons.api,
                    color: Colors.purple,
                    onTap: () =>
                        Get.to(() => const TestIndividualEndpointsScreen()),
                  ),

                  const SizedBox(height: 12),

                  _TestCard(
                    title: 'Debug: Solo ARS, no Invoices',
                    description:
                        'Debuggea específicamente por qué solo se ven datos de ARS y no de invoices.',
                    icon: Icons.bug_report,
                    color: Colors.red,
                    onTap: () => Get.to(() => const DebugInvoicesOnlyScreen()),
                  ),

                  const SizedBox(height: 12),

                  _TestCard(
                    title: 'Test de Endpoints Combinados',
                    description:
                        'Prueba la combinación de múltiples endpoints como debería funcionar.',
                    icon: Icons.merge_type,
                    color: Colors.blue,
                    onTap: () =>
                        Get.to(() => const TestCombinedEndpointsScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final MaterialColor color;
  final VoidCallback onTap;

  const _TestCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color[700], size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
