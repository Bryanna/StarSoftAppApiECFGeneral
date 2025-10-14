import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pdf_maker_controller.dart';

class DataInspectorWidget extends StatelessWidget {
  final PdfMakerController controller;

  const DataInspectorWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PdfMakerController>(
      builder: (c) {
        return Container(
          height: 400,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF005285),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.data_object, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Datos del ERP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: c.loadSampleData,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: 'Cargar datos de ejemplo',
                    ),
                  ],
                ),
              ),

              // Contenido
              Expanded(
                child: c.erpData.isEmpty
                    ? _buildEmptyState()
                    : _buildDataTree(c.erpData),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.data_object_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay datos cargados',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Haz clic en el botón de actualizar\npara cargar datos de ejemplo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.loadSampleData,
            icon: const Icon(Icons.download),
            label: const Text('Cargar Datos de Ejemplo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005285),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTree(Map<String, dynamic> data) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: data.entries.map((entry) {
        return _buildDataItem(entry.key, entry.value, 0);
      }).toList(),
    );
  }

  Widget _buildDataItem(String key, dynamic value, int depth) {
    final indent = depth * 20.0;

    if (value is Map<String, dynamic>) {
      return ExpansionTile(
        leading: Icon(
          Icons.folder_outlined,
          color: Colors.orange.shade600,
          size: 20,
        ),
        title: Text(
          key,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: value.entries.map((subEntry) {
          return Padding(
            padding: EdgeInsets.only(left: indent + 20),
            child: _buildDataItem(subEntry.key, subEntry.value, depth + 1),
          );
        }).toList(),
      );
    } else if (value is List) {
      return ExpansionTile(
        leading: Icon(
          Icons.list_outlined,
          color: Colors.blue.shade600,
          size: 20,
        ),
        title: Text(
          '$key (${value.length} items)',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        children: value.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(left: indent + 20),
            child: _buildDataItem('[${entry.key}]', entry.value, depth + 1),
          );
        }).toList(),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(left: indent),
        child: _buildDraggableDataField(key, value),
      );
    }
  }

  Widget _buildDraggableDataField(String key, dynamic value) {
    final displayValue = _formatValue(value);
    final dataType = _getDataType(value);

    return Draggable<Map<String, dynamic>>(
      data: {
        'key': key,
        'value': value,
        'type': dataType,
        'displayValue': displayValue,
      },
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF005285),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getDataIcon(dataType), color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                key,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildDataFieldTile(key, displayValue, dataType),
      ),
      child: _buildDataFieldTile(key, displayValue, dataType),
    );
  }

  Widget _buildDataFieldTile(String key, String displayValue, String dataType) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () =>
              controller.addElementFromData(key, displayValue, dataType),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  _getDataIcon(dataType),
                  size: 16,
                  color: _getDataColor(dataType),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        displayValue,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getDataColor(dataType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    dataType,
                    style: TextStyle(
                      fontSize: 8,
                      color: _getDataColor(dataType),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.add_circle_outline,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) {
      if (value.isEmpty) return '(vacío)';
      if (value.length > 30) return '${value.substring(0, 30)}...';
      return value;
    }
    if (value is num) return value.toString();
    if (value is bool) return value ? 'true' : 'false';
    return value.toString();
  }

  String _getDataType(dynamic value) {
    if (value == null) return 'null';
    if (value is String) {
      if (value.contains('@')) return 'email';
      if (RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) return 'date';
      if (RegExp(r'^\d+\.?\d*$').hasMatch(value)) return 'number';
      if (value.toLowerCase().contains('tel') ||
          value.toLowerCase().contains('phone'))
        return 'phone';
      return 'text';
    }
    if (value is int) return 'integer';
    if (value is double) return 'decimal';
    if (value is bool) return 'boolean';
    return 'unknown';
  }

  IconData _getDataIcon(String dataType) {
    switch (dataType) {
      case 'text':
        return Icons.text_fields;
      case 'number':
      case 'integer':
      case 'decimal':
        return Icons.numbers;
      case 'date':
        return Icons.calendar_today;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'boolean':
        return Icons.check_box;
      default:
        return Icons.data_object;
    }
  }

  Color _getDataColor(String dataType) {
    switch (dataType) {
      case 'text':
        return Colors.blue;
      case 'number':
      case 'integer':
      case 'decimal':
        return Colors.green;
      case 'date':
        return Colors.orange;
      case 'email':
        return Colors.purple;
      case 'phone':
        return Colors.teal;
      case 'boolean':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
