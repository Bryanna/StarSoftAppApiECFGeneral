import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/erp_endpoint.dart';
import 'unified_setup_controller.dart';

class UnifiedSetupScreen extends StatelessWidget {
  const UnifiedSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UnifiedSetupController>(
      init: UnifiedSetupController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Configuración de Empresa'),
            backgroundColor: const Color(0xFF005285),
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
          ),
          body: controller.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progreso general
                      _buildProgressHeader(controller),
                      const SizedBox(height: 32),

                      // Sección 1: Información de la Empresa
                      _buildCompanySection(controller),
                      const SizedBox(height: 32),

                      // Sección 2: Esquema de Datos
                      _buildSchemaSection(controller),
                      const SizedBox(height: 32),

                      // Sección 3: Configuración ERP
                      _buildERPSection(controller),
                      const SizedBox(height: 32),

                      // Botón de guardar
                      _buildSaveButton(controller),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildProgressHeader(UnifiedSetupController controller) {
    final progress = controller.getConfigurationProgress();
    final percentage = (progress * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuración de tu Sistema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Completa la información para comenzar a usar el sistema',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF005285),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage% completado',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanySection(UnifiedSetupController controller) {
    final isComplete = controller.isCompanyInfoComplete();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, color: const Color(0xFF005285)),
                const SizedBox(width: 12),
                const Text(
                  'Información de la Empresa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isComplete) ...[
                  const Spacer(),
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ],
            ),
            const SizedBox(height: 16),

            Form(
              key: controller.companyFormKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.rncController,
                          decoration: const InputDecoration(
                            labelText: 'RNC *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El RNC es requerido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: controller.razonSocialController,
                          decoration: const InputDecoration(
                            labelText: 'Razón Social *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.account_balance),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La razón social es requerida';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: controller.direccionController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La dirección es requerida';
                      }
                      return null;
                    },
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.telefonoController,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El teléfono es requerido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: controller.emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchemaSection(UnifiedSetupController controller) {
    final hasSchema = controller.hasSchemaSelected();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schema, color: const Color(0xFF005285)),
                const SizedBox(width: 12),
                const Text(
                  'Esquema de Datos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (hasSchema) ...[
                  const Spacer(),
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Define cómo se estructuran los datos de tu negocio',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Esquema seleccionado actual
            if (controller.selectedSchemaId != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esquema seleccionado: ${controller.getSchemaDisplayName()}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => controller.clearSelectedSchema(),
                      child: const Text('Cambiar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Lista de esquemas disponibles
            if (controller.selectedSchemaId == null) ...[
              if (controller.availableSchemas.isNotEmpty) ...[
                const Text(
                  'Esquemas Predefinidos:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                ...controller.availableSchemas.map((schema) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(_getIndustryIcon(schema.industry)),
                      title: Text(schema.name),
                      subtitle: Text(schema.description),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => controller.selectSchema(schema.id),
                    ),
                  );
                }),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
              ],

              // Opciones para crear esquema personalizado
              const Text(
                'Crear Esquema Personalizado:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.createCustomSchema(),
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Nuevo Esquema'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.generateSchemaFromSample(),
                      icon: const Icon(Icons.auto_fix_high),
                      label: const Text('Desde Datos de Ejemplo'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildERPSection(UnifiedSetupController controller) {
    final isConfigured = controller.isERPConfigured();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link, color: const Color(0xFF005285)),
                const SizedBox(width: 12),
                const Text(
                  'Conexión con ERP',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isConfigured) ...[
                  const Spacer(),
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Configura la conexión con tu sistema ERP (opcional)',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Opción de usar datos de prueba
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: controller.useFakeData,
                          onChanged: (value) =>
                              controller.setUseFakeData(value!),
                        ),
                        const Expanded(
                          child: Text(
                            'Usar datos de prueba',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 32),
                      child: Text(
                        'Perfecto para probar el sistema antes de conectar tu ERP real.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Opción de configurar ERP
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Radio<bool>(
                          value: false,
                          groupValue: controller.useFakeData,
                          onChanged: (value) =>
                              controller.setUseFakeData(value!),
                        ),
                        const Expanded(
                          child: Text(
                            'Conectar con mi ERP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 32),
                      child: Text(
                        'Configura múltiples endpoints de tu ERP para obtener datos reales.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),

                    if (!controller.useFakeData) ...[
                      const SizedBox(height: 16),

                      // Lista de endpoints configurados
                      if (controller.erpEndpoints.isNotEmpty) ...[
                        const Text(
                          'Endpoints Configurados:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...controller.erpEndpoints.map((endpoint) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                _getEndpointIcon(endpoint.type),
                                color: Colors.green,
                              ),
                              title: Text(endpoint.name),
                              subtitle: Text(
                                '${endpoint.method} - ${endpoint.url}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    onPressed: () =>
                                        controller.testEndpoint(endpoint),
                                    tooltip: 'Probar',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () =>
                                        controller.deleteEndpoint(endpoint),
                                    tooltip: 'Eliminar',
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],

                      // Botón para agregar endpoint
                      ElevatedButton.icon(
                        onPressed: controller.addEndpoint,
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Endpoint'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botón para guardar información básica
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.loading
                    ? null
                    : controller.saveBasicCompanyInfo,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar Información'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(UnifiedSetupController controller) {
    final isReady = controller.isConfigurationReady();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.loading ? null : controller.saveConfiguration,
        icon: Icon(isReady ? Icons.check : Icons.save),
        label: Text(
          isReady ? 'Completar Configuración' : 'Guardar Configuración',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF005285),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  IconData _getIndustryIcon(String industry) {
    switch (industry) {
      case 'medical':
        return Icons.local_hospital;
      case 'retail':
        return Icons.store;
      case 'manufacturing':
        return Icons.precision_manufacturing;
      case 'services':
        return Icons.room_service;
      default:
        return Icons.business;
    }
  }

  IconData _getEndpointIcon(EndpointType type) {
    switch (type) {
      case EndpointType.invoices:
        return Icons.receipt_long;
      case EndpointType.clients:
        return Icons.people;
      case EndpointType.products:
        return Icons.inventory;
      case EndpointType.services:
        return Icons.room_service;
      case EndpointType.payments:
        return Icons.payment;
      case EndpointType.custom:
        return Icons.api;
    }
  }
}
