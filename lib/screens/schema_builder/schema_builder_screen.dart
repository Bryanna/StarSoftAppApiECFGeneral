import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'schema_builder_controller.dart';
import '../../models/schema_definition.dart';

class SchemaBuilderScreen extends StatelessWidget {
  const SchemaBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SchemaBuilderController>(
      init: SchemaBuilderController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurar Esquema de Datos'),
            backgroundColor: const Color(0xFF005285),
            foregroundColor: Colors.white,
            actions: [
              if (controller.currentSchema != null)
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: controller.saveSchema,
                ),
            ],
          ),
          body: controller.loading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(context, controller),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateSchemaDialog(context, controller),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Esquema'),
            backgroundColor: const Color(0xFF005285),
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SchemaBuilderController controller) {
    if (controller.schemas.isEmpty) {
      return _buildEmptyState(context, controller);
    }

    return Column(
      children: [
        // Selector de esquema
        Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Esquema Actual',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: controller.currentSchema?.id,
                    decoration: const InputDecoration(
                      labelText: 'Seleccionar Esquema',
                      border: OutlineInputBorder(),
                    ),
                    items: controller.schemas.map((schema) {
                      return DropdownMenuItem(
                        value: schema.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(schema.name),
                            Text(
                              schema.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (schemaId) {
                      if (schemaId != null) {
                        controller.selectSchema(schemaId);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Editor de esquema
        if (controller.currentSchema != null)
          Expanded(child: _buildSchemaEditor(context, controller)),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    SchemaBuilderController controller,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schema_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay esquemas configurados',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea un esquema para definir la estructura\nde datos de tu negocio',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateSchemaDialog(context, controller),
            icon: const Icon(Icons.add),
            label: const Text('Crear Primer Esquema'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005285),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemaEditor(
    BuildContext context,
    SchemaBuilderController controller,
  ) {
    final schema = controller.currentSchema!;

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFF005285),
            tabs: [
              Tab(text: 'Factura', icon: Icon(Icons.receipt)),
              Tab(text: 'Productos', icon: Icon(Icons.inventory)),
              Tab(text: 'Cliente', icon: Icon(Icons.person)),
              Tab(text: 'Empresa', icon: Icon(Icons.business)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildFieldsList(
                  context,
                  controller,
                  schema.invoiceFields,
                  'invoice',
                ),
                _buildFieldsList(
                  context,
                  controller,
                  schema.itemFields,
                  'item',
                ),
                _buildFieldsList(
                  context,
                  controller,
                  schema.clientFields,
                  'client',
                ),
                _buildFieldsList(
                  context,
                  controller,
                  schema.companyFields,
                  'company',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldsList(
    BuildContext context,
    SchemaBuilderController controller,
    List<FieldDefinition> fields,
    String category,
  ) {
    return Column(
      children: [
        // Header con botón agregar
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Campos de ${_getCategoryName(category)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    _showAddFieldDialog(context, controller, category),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar Campo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005285),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Lista de campos
        Expanded(
          child: fields.isEmpty
              ? Center(
                  child: Text(
                    'No hay campos definidos\nToca "Agregar Campo" para comenzar',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: fields.length,
                  itemBuilder: (context, index) {
                    final field = fields[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(field.displayName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Clave: ${field.key}'),
                            Text('Tipo: ${_getTypeDisplayName(field.type)}'),
                            if (field.required)
                              const Text(
                                'Requerido',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Eliminar'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditFieldDialog(
                                context,
                                controller,
                                field,
                                category,
                              );
                            } else if (value == 'delete') {
                              controller.removeField(category, field.key);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showCreateSchemaDialog(
    BuildContext context,
    SchemaBuilderController controller,
  ) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedIndustry = 'medical';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nuevo Esquema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Esquema',
                hintText: 'Ej: Mi Clínica Dental',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe el tipo de negocio',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedIndustry,
              decoration: const InputDecoration(labelText: 'Industria'),
              items: const [
                DropdownMenuItem(value: 'medical', child: Text('Médica')),
                DropdownMenuItem(
                  value: 'retail',
                  child: Text('Retail/Ferretería'),
                ),
                DropdownMenuItem(
                  value: 'manufacturing',
                  child: Text('Manufactura'),
                ),
                DropdownMenuItem(value: 'services', child: Text('Servicios')),
                DropdownMenuItem(value: 'other', child: Text('Otro')),
              ],
              onChanged: (value) => selectedIndustry = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.createSchema(
                  nameController.text,
                  descriptionController.text,
                  selectedIndustry,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showAddFieldDialog(
    BuildContext context,
    SchemaBuilderController controller,
    String category,
  ) {
    _showFieldDialog(context, controller, category, null);
  }

  void _showEditFieldDialog(
    BuildContext context,
    SchemaBuilderController controller,
    FieldDefinition field,
    String category,
  ) {
    _showFieldDialog(context, controller, category, field);
  }

  void _showFieldDialog(
    BuildContext context,
    SchemaBuilderController controller,
    String category,
    FieldDefinition? existingField,
  ) {
    final keyController = TextEditingController(text: existingField?.key ?? '');
    final nameController = TextEditingController(
      text: existingField?.displayName ?? '',
    );
    final descriptionController = TextEditingController(
      text: existingField?.description ?? '',
    );
    FieldDataType selectedType = existingField?.type ?? FieldDataType.string;
    bool isRequired = existingField?.required ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existingField == null ? 'Agregar Campo' : 'Editar Campo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: keyController,
                  decoration: const InputDecoration(
                    labelText: 'Clave del Campo',
                    hintText: 'nombre_cliente, total_amount, etc.',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre para Mostrar',
                    hintText: 'Nombre del Cliente, Monto Total, etc.',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<FieldDataType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Tipo de Dato'),
                  items: FieldDataType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeDisplayName(type)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (Opcional)',
                    hintText: 'Información adicional sobre este campo',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Campo Requerido'),
                  value: isRequired,
                  onChanged: (value) => setState(() => isRequired = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (keyController.text.isNotEmpty &&
                    nameController.text.isNotEmpty) {
                  final field = FieldDefinition(
                    key: keyController.text,
                    displayName: nameController.text,
                    type: selectedType,
                    required: isRequired,
                    description: descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                  );

                  if (existingField == null) {
                    controller.addField(category, field);
                  } else {
                    controller.updateField(category, existingField.key, field);
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(existingField == null ? 'Agregar' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'invoice':
        return 'Factura';
      case 'item':
        return 'Productos/Servicios';
      case 'client':
        return 'Cliente';
      case 'company':
        return 'Empresa';
      default:
        return category;
    }
  }

  String _getTypeDisplayName(FieldDataType type) {
    switch (type) {
      case FieldDataType.string:
        return 'Texto';
      case FieldDataType.number:
        return 'Número Entero';
      case FieldDataType.decimal:
        return 'Número Decimal';
      case FieldDataType.date:
        return 'Fecha';
      case FieldDataType.boolean:
        return 'Verdadero/Falso';
      case FieldDataType.array:
        return 'Lista';
      case FieldDataType.object:
        return 'Objeto';
    }
  }
}
