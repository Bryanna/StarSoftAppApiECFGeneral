import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pdf_maker_controller.dart';

class PageSizeSelector extends StatelessWidget {
  final PdfMakerController controller;

  const PageSizeSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PdfMakerController>(
      builder: (c) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.aspect_ratio,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Tamaño de Papel',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Selector de tamaño
              DropdownButtonFormField<String>(
                value: c.selectedPageSize,
                decoration: InputDecoration(
                  labelText: 'Formato',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: c.pageSizes.keys.map((String size) {
                  return DropdownMenuItem<String>(
                    value: size,
                    child: Row(
                      children: [
                        _getIconForPageSize(size),
                        const SizedBox(width: 8),
                        Text(size),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    c.changePageSize(newValue);
                  }
                },
              ),

              const SizedBox(height: 12),

              // Información del tamaño actual
              _buildPageSizeInfo(c),

              // Configuración personalizada
              if (c.selectedPageSize == 'Personalizado') ...[
                const SizedBox(height: 16),
                _buildCustomSizeConfig(c),
              ],

              const SizedBox(height: 16),

              // Presets rápidos
              _buildQuickPresets(c),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageSizeInfo(PdfMakerController c) {
    final info = c.getPageSizeInfo();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 6),
              Text(
                'Dimensiones: ${info['name']}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${info['widthMM'].toStringAsFixed(0)} × ${info['heightMM'].toStringAsFixed(0)} mm',
            style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
          ),
          Text(
            '${info['widthInch'].toStringAsFixed(2)}" × ${info['heightInch'].toStringAsFixed(2)}"',
            style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSizeConfig(PdfMakerController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dimensiones Personalizadas (mm)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: TextEditingController(
                  text: c.customWidth.toStringAsFixed(0),
                ),
                decoration: const InputDecoration(
                  labelText: 'Ancho',
                  border: OutlineInputBorder(),
                  suffixText: 'mm',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final width = double.tryParse(value) ?? c.customWidth;
                  c.updateCustomDimensions(width, c.customHeight);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: TextEditingController(
                  text: c.customHeight.toStringAsFixed(0),
                ),
                decoration: const InputDecoration(
                  labelText: 'Alto',
                  border: OutlineInputBorder(),
                  suffixText: 'mm',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final height = double.tryParse(value) ?? c.customHeight;
                  c.updateCustomDimensions(c.customWidth, height);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickPresets(PdfMakerController c) {
    final presets = [
      {'name': 'A4', 'icon': Icons.description, 'color': Colors.blue},
      {
        'name': 'Térmico 80mm',
        'icon': Icons.receipt_long,
        'color': Colors.green,
      },
      {'name': 'Térmico 58mm', 'icon': Icons.receipt, 'color': Colors.orange},
      {'name': 'Térmico 57mm', 'icon': Icons.receipt, 'color': Colors.teal},
      {
        'name': 'Ticket Largo',
        'icon': Icons.confirmation_number,
        'color': Colors.purple,
      },
      {'name': 'Etiqueta 4x6"', 'icon': Icons.label, 'color': Colors.red},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accesos Rápidos',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((preset) {
            final isSelected = c.selectedPageSize == preset['name'];
            final color = preset['color'] as Color;

            return GestureDetector(
              onTap: () => c.changePageSize(preset['name'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      preset['icon'] as IconData,
                      size: 16,
                      color: isSelected ? color : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      preset['name'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected ? color : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _getIconForPageSize(String size) {
    switch (size) {
      case 'A4':
      case 'A5':
      case 'Letter':
      case 'Legal':
        return const Icon(Icons.description, size: 16);
      case 'Térmico 80mm':
      case 'Térmico 58mm':
      case 'Térmico 57mm':
      case 'Térmico 48mm':
        return const Icon(Icons.receipt_long, size: 16);
      case 'Recibo 3"':
      case 'Recibo 2"':
        return const Icon(Icons.receipt, size: 16);
      case 'Ticket Largo':
      case 'Ticket Corto':
        return const Icon(Icons.confirmation_number, size: 16);
      case 'Etiqueta 4x6"':
      case 'Etiqueta 2x1"':
        return const Icon(Icons.label, size: 16);
      case 'Personalizado':
        return const Icon(Icons.tune, size: 16);
      default:
        return const Icon(Icons.insert_drive_file, size: 16);
    }
  }
}
