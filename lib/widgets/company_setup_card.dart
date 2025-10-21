import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/company_model.dart';
import '../services/company_config_service.dart';
import '../routes/app_routes.dart';

/// Widget que muestra el estado de configuración de la empresa
class CompanySetupCard extends StatelessWidget {
  const CompanySetupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: CompanyConfigService().isSetupComplete(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final isComplete = snapshot.data ?? false;

        // Si está completamente configurado, no mostrar nada
        if (isComplete) {
          return const SizedBox.shrink();
        }

        return FutureBuilder<int>(
          future: CompanyConfigService().getCurrentSetupStep(),
          builder: (context, stepSnapshot) {
            final currentStep = stepSnapshot.data ?? 1;
            final progress =
                (currentStep - 1) / 3; // Convertir paso a progreso (0-1)

            return Card(
              margin: const EdgeInsets.all(16),
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Configuración Pendiente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'Tu empresa necesita completar la configuración inicial para usar todas las funcionalidades.',
                      style: TextStyle(color: Colors.orange[800]),
                    ),

                    const SizedBox(height: 16),

                    // Barra de progreso
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.orange[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orange[600]!,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Paso $currentStep de 3 - ${(progress * 100).toInt()}% completado',
                      style: TextStyle(fontSize: 12, color: Colors.orange[600]),
                    ),

                    const SizedBox(height: 16),

                    // Botón para continuar configuración
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed(AppRoutes.SETUP),
                        icon: const Icon(Icons.settings),
                        label: const Text('Continuar Configuración'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Widget para mostrar información de la empresa configurada
class CompanyInfoCard extends StatelessWidget {
  const CompanyInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CompanyModel?>(
      future: CompanyConfigService().getCurrentCompany(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final company = snapshot.data;
        if (company == null) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.business,
                      color: Color(0xFF005285),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Información de la Empresa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF005285),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Get.toNamed(AppRoutes.SETUP),
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar configuración',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _InfoRow(label: 'RNC', value: company.rnc),
                _InfoRow(label: 'Razón Social', value: company.razonSocial),
                if (company.nombreComercial != null)
                  _InfoRow(
                    label: 'Nombre Comercial',
                    value: company.nombreComercial!,
                  ),
                if (company.direccion != null)
                  _InfoRow(label: 'Dirección', value: company.direccion!),
                if (company.telefono != null)
                  _InfoRow(label: 'Teléfono', value: company.telefono!),

                const SizedBox(height: 16),

                // Estado de configuración
                Row(
                  children: [
                    Icon(
                      company.isConfigured ? Icons.check_circle : Icons.warning,
                      color: company.isConfigured
                          ? Colors.green
                          : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      company.isConfigured
                          ? 'Configuración Completa'
                          : 'Configuración Pendiente',
                      style: TextStyle(
                        color: company.isConfigured
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                if (company.useFakeData) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[600], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Usando datos de prueba',
                        style: TextStyle(color: Colors.blue[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
