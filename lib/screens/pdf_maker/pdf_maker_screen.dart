import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pdf_maker_controller.dart';
import 'data_inspector_widget.dart';
import 'page_size_selector.dart';

class PdfMakerScreen extends StatelessWidget {
  const PdfMakerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PdfMakerController>(
      init: PdfMakerController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: const Color(0xFF005285),
            centerTitle: false,
            elevation: 0,
            title: Row(
              children: [
                Image.asset('assets/logo.png', height: 50),
                const SizedBox(width: 12),
                const Text(
                  'PDF Maker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // Botón de plantillas
              IconButton(
                onPressed: controller.showTemplateSelector,
                icon: const Icon(
                  Icons.dashboard_customize,
                  color: Colors.white,
                ),
                tooltip: 'Plantillas Predefinidas',
              ),
              // Botón de cargar JSON
              IconButton(
                onPressed: controller.showJsonInputDialog,
                icon: Icon(
                  controller.hasLoadedJson ? Icons.code : Icons.code_off,
                  color: controller.hasLoadedJson ? Colors.green : Colors.white,
                ),
                tooltip: controller.hasLoadedJson
                    ? 'JSON Cargado - Clic para cambiar'
                    : 'Cargar Datos JSON',
              ),
              // Botón de auto-mapeo
              IconButton(
                onPressed: controller.autoMapFields,
                icon: const Icon(Icons.auto_fix_high, color: Colors.white),
                tooltip: 'Auto-mapeo Inteligente',
              ),
              // Botón de toggle data inspector
              IconButton(
                onPressed: controller.toggleDataInspector,
                icon: Icon(
                  controller.showDataInspector
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white,
                ),
                tooltip: 'Mostrar/Ocultar Datos ERP',
              ),
              // Menú de más opciones
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'save':
                      controller.saveTemplate();
                      break;
                    case 'preview':
                      controller.previewPdf();
                      break;
                    case 'print':
                      controller.printDirectly();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'save',
                    child: Row(
                      children: [
                        Icon(Icons.save, size: 20),
                        SizedBox(width: 8),
                        Text('Guardar Plantilla'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'preview',
                    child: Row(
                      children: [
                        Icon(Icons.preview, size: 20),
                        SizedBox(width: 8),
                        Text('Vista Previa'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'print',
                    child: Row(
                      children: [
                        Icon(Icons.print, size: 20),
                        SizedBox(width: 8),
                        Text('Imprimir Directamente'),
                      ],
                    ),
                  ),
                ],
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.more_vert, color: Colors.white),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Banner de estado JSON
              if (controller.hasLoadedJson)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.green.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'JSON cargado correctamente - ${controller.countFields(controller.erpData)} campos disponibles',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: controller.clearJsonData,
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Limpiar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

              // Barra de herramientas avanzada
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),

                    // Undo/Redo
                    IconButton(
                      onPressed: controller.canUndo() ? controller.undo : null,
                      icon: const Icon(Icons.undo, size: 20),
                      tooltip: 'Deshacer (Ctrl+Z)',
                    ),
                    IconButton(
                      onPressed: controller.canRedo() ? controller.redo : null,
                      icon: const Icon(Icons.redo, size: 20),
                      tooltip: 'Rehacer (Ctrl+Y)',
                    ),

                    const VerticalDivider(),

                    // Selección múltiple
                    IconButton(
                      onPressed: controller.toggleMultiSelect,
                      icon: Icon(
                        controller.isMultiSelectMode
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 20,
                        color: controller.isMultiSelectMode
                            ? Colors.blue
                            : null,
                      ),
                      tooltip: 'Selección Múltiple',
                    ),

                    if (controller.isMultiSelectMode) ...[
                      IconButton(
                        onPressed: controller.selectAllElements,
                        icon: const Icon(Icons.select_all, size: 20),
                        tooltip: 'Seleccionar Todo',
                      ),
                      IconButton(
                        onPressed: controller.deselectAll,
                        icon: const Icon(Icons.deselect, size: 20),
                        tooltip: 'Deseleccionar Todo',
                      ),
                    ],

                    const VerticalDivider(),

                    // Alineación
                    if (controller.selectedElements.length > 1) ...[
                      IconButton(
                        onPressed: () =>
                            controller.alignSelectedElements('left'),
                        icon: const Icon(Icons.format_align_left, size: 20),
                        tooltip: 'Alinear Izquierda',
                      ),
                      IconButton(
                        onPressed: () => controller.alignSelectedElements(
                          'center_horizontal',
                        ),
                        icon: const Icon(Icons.format_align_center, size: 20),
                        tooltip: 'Centrar Horizontal',
                      ),
                      IconButton(
                        onPressed: () =>
                            controller.alignSelectedElements('right'),
                        icon: const Icon(Icons.format_align_right, size: 20),
                        tooltip: 'Alinear Derecha',
                      ),

                      const VerticalDivider(),

                      IconButton(
                        onPressed: () =>
                            controller.distributeSelectedElements('horizontal'),
                        icon: const Icon(Icons.space_bar, size: 20),
                        tooltip: 'Distribuir Horizontalmente',
                      ),
                    ],

                    const Spacer(),

                    // Zoom
                    IconButton(
                      onPressed: controller.zoomOut,
                      icon: const Icon(Icons.zoom_out, size: 20),
                      tooltip: 'Alejar',
                    ),
                    Text(
                      '${(controller.zoomLevel * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    IconButton(
                      onPressed: controller.zoomIn,
                      icon: const Icon(Icons.zoom_in, size: 20),
                      tooltip: 'Acercar',
                    ),
                    IconButton(
                      onPressed: controller.resetZoom,
                      icon: const Icon(Icons.fit_screen, size: 20),
                      tooltip: 'Ajustar Zoom',
                    ),

                    const VerticalDivider(),

                    // Grilla
                    IconButton(
                      onPressed: controller.toggleGrid,
                      icon: Icon(
                        Icons.grid_on,
                        size: 20,
                        color: controller.isGridEnabled ? Colors.blue : null,
                      ),
                      tooltip: 'Mostrar/Ocultar Grilla',
                    ),
                    IconButton(
                      onPressed: controller.toggleSnapToGrid,
                      icon: Icon(
                        Icons.grid_4x4,
                        size: 20,
                        color: controller.isSnapToGrid ? Colors.blue : null,
                      ),
                      tooltip: 'Ajustar a Grilla',
                    ),

                    const SizedBox(width: 16),
                  ],
                ),
              ),

              // Contenido principal
              Expanded(
                child: Row(
                  children: [
                    // Panel izquierdo - Herramientas
                    Container(
                      width: 280,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border(
                          right: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Selector de tamaño de papel
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: PageSizeSelector(controller: controller),
                          ),

                          // Herramientas básicas
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Elementos',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Botones de elementos
                                  _buildToolButton(
                                    'Texto',
                                    Icons.text_fields,
                                    () => controller.addElement('text'),
                                  ),
                                  _buildToolButton(
                                    'Logo',
                                    Icons.image,
                                    () => controller.addElement('logo'),
                                  ),
                                  _buildToolButton(
                                    'Línea',
                                    Icons.horizontal_rule,
                                    () => controller.addElement('line'),
                                  ),
                                  _buildToolButton(
                                    'Rectángulo',
                                    Icons.rectangle_outlined,
                                    () => controller.addElement('rectangle'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Panel central - Editor visual
                    Expanded(
                      child: Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: Container(
                            width: controller.getCurrentPageFormat().width,
                            height: controller.getCurrentPageFormat().height,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Elementos del PDF
                                ...controller.elements.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final element = entry.value;

                                  return Positioned(
                                    left: element.x,
                                    top: element.y,
                                    child: GestureDetector(
                                      onTap: () =>
                                          controller.selectElement(index),
                                      onPanUpdate: (details) => controller
                                          .moveElement(index, details.delta),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border:
                                              controller.selectedElementIndex ==
                                                  index
                                              ? Border.all(
                                                  color: Colors.blue,
                                                  width: 2,
                                                )
                                              : null,
                                        ),
                                        child: _buildElementWidget(element),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Panel derecho - Propiedades y datos
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border(
                          left: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Panel de propiedades
                          if (controller.selectedElementIndex >= 0)
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Propiedades',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Propiedades básicas del elemento seleccionado
                                  const Text('Elemento seleccionado'),
                                ],
                              ),
                            ),

                          // Inspector de datos
                          if (controller.showDataInspector)
                            Expanded(
                              child: DataInspectorWidget(
                                controller: controller,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolButton(String label, IconData icon, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildElementWidget(element) {
    switch (element.type) {
      case 'text':
      case 'invoice_number':
      case 'date':
      case 'client':
      case 'total':
      case 'company_name':
      case 'company_rnc':
      case 'company_address':
      case 'company_phone':
        return Text(
          element.content,
          style: TextStyle(
            fontSize: element.fontSize,
            color: element.color,
            fontWeight: element.bold ? FontWeight.bold : FontWeight.normal,
          ),
        );
      case 'logo':
        return Container(
          width: element.width,
          height: element.height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
        );
      case 'line':
        return Container(
          width: element.width,
          height: element.height,
          color: element.color,
        );
      case 'rectangle':
        return Container(
          width: element.width,
          height: element.height,
          decoration: BoxDecoration(
            border: Border.all(color: element.color),
            borderRadius: BorderRadius.circular(element.borderRadius),
            color: element.backgroundColor,
          ),
        );
      case 'products_table':
      case 'totals_table':
        return Container(
          width: element.width,
          height: element.height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(child: Text('Tabla')),
        );
      default:
        return Text(
          element.content,
          style: TextStyle(fontSize: element.fontSize, color: element.color),
        );
    }
  }
}

// Painter para la grilla
class GridPainter extends CustomPainter {
  final double gridSize;
  final Color color;

  GridPainter({required this.gridSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    // Líneas verticales
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Líneas horizontales
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
