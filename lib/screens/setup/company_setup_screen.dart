import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'company_setup_controller.dart';

class CompanySetupScreen extends StatelessWidget {
  const CompanySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CompanySetupController>(
      init: CompanySetupController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Configuración Inicial'),
            backgroundColor: const Color(0xFF005285),
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false, // No permitir regresar
          ),
          body: controller.loading
              ? const Center(child: CircularProgressIndicator())
              : _buildSetupContent(context, controller),
        );
      },
    );
  }

  Widget _buildSetupContent(
    BuildContext context,
    CompanySetupController controller,
  ) {
    return Column(
      children: [
        // Indicador de progreso
        _buildProgressIndicator(controller),

        // Contenido del paso actual
        Expanded(child: _buildCurrentStep(context, controller)),

        // Botones de navegación
        _buildNavigationButtons(context, controller),
      ],
    );
  }

  Widget _buildProgressIndicator(CompanySetupController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Barra de progreso
          LinearProgressIndicator(
            value: _getProgressValue(controller.currentView),
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF005285)),
          ),
          const SizedBox(height: 16),

          // Pasos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['basic', 'schema', 'erp'].map((view) {
              final isCompleted = _isViewCompleted(
                controller.currentView,
                view,
              );
              final isCurrent = controller.currentView == view;

              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? const Color(0xFF005285)
                          : isCurrent
                          ? const Color(0xFF005285).withOpacity(0.3)
                          : Colors.grey[300],
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : _getViewIcon(view),
                      color: isCompleted || isCurrent
                          ? Colors.white
                          : Colors.grey[600],
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getViewName(view),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isCurrent
                          ? const Color(0xFF005285)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(
    BuildContext context,
    CompanySetupController controller,
  ) {
    switch (controller.currentView) {
      case 'basic':
        return _buildBasicInfoStep(context, controller);
      case 'schema':
        return _buildDataSchemaStep(context, controller);
      case 'erp':
        return _buildERPConnectionStep(context, controller);
      default:
        return _buildCompletedStep(context, controller);
    }
  }

  Widget _buildBasicInfoStep(
    BuildContext context,
    CompanySetupController controller,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información de la Empresa',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa los datos básicos de tu empresa para comenzar',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Formulario
              Form(
                key: controller.basicInfoFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.rncController,
                      decoration: const InputDecoration(
                        labelText: 'RNC de la Empresa *',
                        hintText: '000000000',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El RNC es requerido';
                        }
                        if (value.length != 9) {
                          return 'El RNC debe tener 9 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: controller.razonSocialController,
                      decoration: const InputDecoration(
                        labelText: 'Razón Social *',
                        hintText: 'Nombre legal de la empresa',
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
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: controller.nombreComercialController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Comercial',
                        hintText: 'Nombre con el que opera',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.store),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: controller.direccionController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección *',
                        hintText: 'Dirección física de la empresa',
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
                              hintText: '809-000-0000',
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
                              hintText: 'contacto@empresa.com',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: controller.websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Sitio Web',
                        hintText: 'www.empresa.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.language),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),

              // Widget de debug (temporal)
              _buildDebugInfo(controller),

              // Botón de debug para forzar avance (temporal)
              Container(
                margin: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    // Forzar avance al paso 2 para debug
                    controller.debugForceNextStep();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('🔧 DEBUG: Forzar Paso 2'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataSchemaStep(
    BuildContext context,
    CompanySetupController controller,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configuración de Datos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Define cómo se estructuran los datos de tu negocio',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Estado actual del esquema
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
                      Text(
                        'Esquema seleccionado: ${controller.selectedSchemaId}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Opciones de esquema
              if (controller.availableSchemas.isNotEmpty) ...[
                const Text(
                  'Selecciona un esquema predefinido:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                ...controller.availableSchemas.map((schema) {
                  final isSelected = controller.selectedSchemaId == schema.id;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isSelected
                        ? const Color(0xFF005285).withOpacity(0.1)
                        : null,
                    child: ListTile(
                      leading: Icon(
                        _getIndustryIcon(schema.industry),
                        color: isSelected ? const Color(0xFF005285) : null,
                      ),
                      title: Text(
                        schema.name,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? const Color(0xFF005285) : null,
                        ),
                      ),
                      subtitle: Text(schema.description),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF005285),
                            )
                          : null,
                      onTap: () => controller.selectSchema(schema.id),
                    ),
                  );
                }),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
              ],

              // Opción de crear esquema personalizado
              const Text(
                'O crea un esquema personalizado:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () => controller.createCustomSchema(),
                icon: const Icon(Icons.add),
                label: const Text('Crear Esquema Personalizado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Opción de generar desde datos de ejemplo
              OutlinedButton.icon(
                onPressed: () => controller.generateSchemaFromSample(),
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('Generar desde Datos de Ejemplo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF005285),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildERPConnectionStep(
    BuildContext context,
    CompanySetupController controller,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Conexión con ERP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Configura la conexión con tu sistema ERP (opcional)',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 32),

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
                          'Perfecto para probar el sistema antes de conectar tu ERP real. '
                          'Puedes cambiar esto más tarde.',
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
                          'Conecta directamente con tu sistema ERP para obtener datos reales.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

                      if (!controller.useFakeData) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: controller.erpUrlController,
                          decoration: const InputDecoration(
                            labelText: 'URL del Endpoint ERP',
                            hintText: 'https://mi-erp.com/api/facturas',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.link),
                          ),
                          validator: (value) {
                            if (!controller.useFakeData &&
                                (value == null || value.isEmpty)) {
                              return 'La URL del ERP es requerida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: controller.testERPConnection,
                          icon: const Icon(Icons.wifi_protected_setup),
                          label: const Text('Probar Conexión'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedStep(
    BuildContext context,
    CompanySetupController controller,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 24),
                const Text(
                  '¡Configuración Completada!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tu sistema de facturación está listo para usar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: controller.completeSetup,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Comenzar a Usar el Sistema'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005285),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    CompanySetupController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón anterior
          OutlinedButton(
            onPressed: controller.canGoBack ? controller.goBack : null,
            child: const Text('Anterior'),
          ),

          // Botón siguiente
          ElevatedButton(
            onPressed: controller.canGoNext ? controller.goNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005285),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[600],
            ),
            child: Text(controller.isLastStep ? 'Finalizar' : 'Siguiente'),
          ),
        ],
      ),
    );
  }

  double _getProgressValue(String currentView) {
    switch (currentView) {
      case 'basic':
        return 0.33;
      case 'schema':
        return 0.66;
      case 'erp':
        return 1.0;
      default:
        return 0.0;
    }
  }

  bool _isViewCompleted(String currentView, String checkView) {
    final views = ['basic', 'schema', 'erp'];
    final currentIndex = views.indexOf(currentView);
    final checkIndex = views.indexOf(checkView);
    return currentIndex > checkIndex;
  }

  IconData _getViewIcon(String view) {
    switch (view) {
      case 'basic':
        return Icons.business;
      case 'schema':
        return Icons.schema;
      case 'erp':
        return Icons.link;
      default:
        return Icons.check;
    }
  }

  String _getViewName(String view) {
    switch (view) {
      case 'basic':
        return 'Empresa';
      case 'schema':
        return 'Datos';
      case 'erp':
        return 'ERP';
      default:
        return 'Listo';
    }
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

  /// Widget de debug para mostrar el estado de validación
  Widget _buildDebugInfo(CompanySetupController controller) {
    if (controller.currentView != 'basic') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado de Validación:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _buildValidationRow('RNC', controller.rncController.text.isNotEmpty),
          _buildValidationRow(
            'Razón Social',
            controller.razonSocialController.text.isNotEmpty,
          ),
          _buildValidationRow(
            'Dirección',
            controller.direccionController.text.isNotEmpty,
          ),
          _buildValidationRow(
            'Teléfono',
            controller.telefonoController.text.isNotEmpty,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                controller.canGoNext ? Icons.check_circle : Icons.cancel,
                color: controller.canGoNext ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                controller.canGoNext
                    ? 'Puede continuar'
                    : 'Complete los campos requeridos',
                style: TextStyle(
                  color: controller.canGoNext ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValidationRow(String label, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check : Icons.close,
            color: isValid ? Colors.green : Colors.red,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
