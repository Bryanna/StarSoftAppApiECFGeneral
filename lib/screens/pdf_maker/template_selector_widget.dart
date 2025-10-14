import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pdf_maker_controller.dart';
import '../../widgets/pdf_viewer_widget.dart';
import '../../services/custom_pdf_service.dart';
import '../../models/pdf_element.dart';
import 'package:pdf/pdf.dart';

class TemplateSelectorWidget extends StatefulWidget {
  final PdfMakerController controller;

  const TemplateSelectorWidget({super.key, required this.controller});

  @override
  State<TemplateSelectorWidget> createState() => _TemplateSelectorWidgetState();
}

class _TemplateSelectorWidgetState extends State<TemplateSelectorWidget> {
  String? selectedCategory;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: Get.width * 0.9,
        height: Get.height * 0.85,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildCategoryFilters(),
            const SizedBox(height: 20),
            _buildTemplateGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF005285).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.dashboard_customize,
            color: Color(0xFF005285),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Galería de Plantillas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              'Selecciona una plantilla para comenzar',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
        decoration: const InputDecoration(
          hintText: 'Buscar plantillas...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      {'name': 'Todas', 'value': null, 'icon': Icons.apps},
      {
        'name': 'Facturación',
        'value': 'Facturación',
        'icon': Icons.receipt_long,
      },
      {'name': 'Recibos', 'value': 'Recibos', 'icon': Icons.receipt},
      {
        'name': 'Tickets',
        'value': 'Tickets',
        'icon': Icons.confirmation_number,
      },
      {'name': 'Etiquetas', 'value': 'Etiquetas', 'icon': Icons.label},
      {
        'name': 'Certificados',
        'value': 'Certificados',
        'icon': Icons.workspace_premium,
      },
      {'name': 'Reportes', 'value': 'Reportes', 'icon': Icons.analytics},
      {
        'name': 'Cotizaciones',
        'value': 'Cotizaciones',
        'icon': Icons.request_quote,
      },
      {'name': 'Órdenes', 'value': 'Órdenes', 'icon': Icons.shopping_cart},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category['value'];

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              avatar: Icon(
                category['icon'] as IconData,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF005285),
              ),
              label: Text(
                category['name'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF005285),
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = selected
                      ? category['value'] as String?
                      : null;
                });
              },
              selectedColor: const Color(0xFF005285),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF005285)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateGrid() {
    final filteredTemplates = _getFilteredTemplates();

    if (filteredTemplates.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No se encontraron plantillas',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'Intenta cambiar los filtros o el término de búsqueda',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredTemplates.length,
        itemBuilder: (context, index) {
          final template = filteredTemplates[index];
          return _buildTemplateCard(template);
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredTemplates() {
    var templates = widget.controller.availableTemplates;

    // Filtrar por categoría
    if (selectedCategory != null) {
      templates = templates
          .where((template) => template['category'] == selectedCategory)
          .toList();
    }

    // Filtrar por búsqueda
    if (searchQuery.isNotEmpty) {
      templates = templates.where((template) {
        final name = (template['name'] as String).toLowerCase();
        final description = (template['description'] as String).toLowerCase();
        final category = (template['category'] as String).toLowerCase();

        return name.contains(searchQuery) ||
            description.contains(searchQuery) ||
            category.contains(searchQuery);
      }).toList();
    }

    return templates;
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    final templateColor =
        template['color'] as Color? ?? const Color(0xFF005285);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _selectTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vista previa
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    // Simulación de documento
                    Center(
                      child: Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildMiniPreview(template, templateColor),
                      ),
                    ),

                    // Botones de acción
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            Icons.visibility,
                            'Vista previa',
                            () => _showTemplatePreview(template),
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            Icons.download,
                            'Usar plantilla',
                            () => _selectTemplate(template),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Información
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(template['icon'], size: 16, color: templateColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            template['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: templateColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        template['category'],
                        style: TextStyle(
                          color: templateColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        template['description'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildMiniPreview(Map<String, dynamic> template, Color templateColor) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          // Header
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: templateColor.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 2),

          // Contenido
          Expanded(
            child: Column(
              children: [
                // Título
                Container(
                  height: 2,
                  width: double.infinity,
                  color: templateColor.withValues(alpha: 0.7),
                  margin: const EdgeInsets.only(bottom: 2),
                ),

                // Líneas de contenido
                ...List.generate(
                  8,
                  (i) => Container(
                    height: 1,
                    width: i % 3 == 0 ? 30.0 : double.infinity,
                    color: Colors.grey.shade400,
                    margin: const EdgeInsets.only(bottom: 1),
                  ),
                ),

                const Spacer(),

                // Footer
                Container(
                  height: 2,
                  width: 25,
                  color: templateColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Icon(icon, size: 14, color: const Color(0xFF005285)),
      ),
    );
  }

  void _selectTemplate(Map<String, dynamic> template) {
    Get.back();
    final actualIndex = widget.controller.availableTemplates.indexOf(template);
    widget.controller.loadTemplate(actualIndex);
  }

  void _showTemplatePreview(Map<String, dynamic> template) async {
    try {
      // Mostrar indicador de carga
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Generar vista previa
      final sampleData = widget.controller.getSampleDataForTemplate(
        template['name'],
      );

      final pdfBytes = await CustomPdfService.generatePdfFromTemplate(
        template: (template['elements'] as List<PdfElement>),
        invoiceData: sampleData,
        format: PdfPageFormat.a4,
      );

      // Cerrar indicador de carga
      Get.back();

      // Mostrar vista previa
      Get.dialog(
        Dialog(
          child: SizedBox(
            width: Get.width * 0.8,
            height: Get.height * 0.9,
            child: Column(
              children: [
                _buildPreviewHeader(template),
                Expanded(
                  child: PdfViewerWidget(
                    pdfBytes: pdfBytes,
                    title: template['name'],
                    showActions: false,
                  ),
                ),
                _buildPreviewFooter(template),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      Get.back(); // Cerrar indicador de carga
      Get.snackbar(
        'Error',
        'No se pudo generar la vista previa: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildPreviewHeader(Map<String, dynamic> template) {
    final templateColor =
        template['color'] as Color? ?? const Color(0xFF005285);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: templateColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(template['icon'], color: templateColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  template['description'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(backgroundColor: Colors.grey.shade200),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewFooter(Map<String, dynamic> template) {
    final templateColor =
        template['color'] as Color? ?? const Color(0xFF005285);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: templateColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              template['category'],
              style: TextStyle(
                color: templateColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          TextButton(onPressed: () => Get.back(), child: const Text('Cerrar')),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              Get.back(); // Cerrar vista previa
              _selectTemplate(template);
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Usar Esta Plantilla'),
            style: ElevatedButton.styleFrom(
              backgroundColor: templateColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
