import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/queue_processor_service.dart';

class QueueScreenSimple extends StatelessWidget {
  const QueueScreenSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cola de Envío DGII'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _startProcessor(),
            tooltip: 'Iniciar Procesador',
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: () => _stopProcessor(),
            tooltip: 'Detener Procesador',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _processAllPending(),
            tooltip: 'Procesar Todos',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _clearCompletedItems(),
            tooltip: 'Limpiar Completados',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear_all') {
                _clearAllItems();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Vaciar Cola Completa',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getQueueStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando cola...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          // Ordenar por fecha de creación (más reciente primero)
          final docs = List.from(allDocs);
          docs.sort((a, b) {
            final aTime =
                (a.data() as Map<String, dynamic>)['created_at'] as Timestamp?;
            final bTime =
                (b.data() as Map<String, dynamic>)['created_at'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime); // Más reciente primero
          });

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.queue, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay facturas en cola',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Las facturas aparecerán aquí cuando las envíes',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress Bar General
              _buildProgressBar(docs),

              // Lista de items
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(
                            data['status'],
                          ).withOpacity(0.1),
                          child: data['status'] == 'processing'
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      _getStatusColor(data['status']),
                                    ),
                                  ),
                                )
                              : Icon(
                                  _getStatusIcon(data['status']),
                                  color: _getStatusColor(data['status']),
                                  size: 20,
                                ),
                        ),
                        title: Text(
                          data['numero_factura']?.toString() ?? 'Sin número',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusDisplayName(data['status']),
                              style: TextStyle(
                                color: _getStatusColor(data['status']),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text('eCF: ${data['encf'] ?? 'N/A'}'),
                            if (data['error_message'] != null)
                              Text(
                                data['error_message'].toString(),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                        trailing: _buildActionButtons(context, doc, data),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot>? _getQueueStream() {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return null;

      return FirebaseFirestore.instance
          .collection('invoice_queue')
          .where('user_id', isEqualTo: userId)
          .snapshots();
    } catch (e) {
      debugPrint('Error creando stream: $e');
      return null;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'approved':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red;
      case 'failed':
        return Colors.red.shade700;
      case 'retrying':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.sync;
      case 'completed':
        return Icons.check_circle;
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.cancel;
      case 'failed':
        return Icons.error;
      case 'retrying':
        return Icons.refresh;
      default:
        return Icons.help;
    }
  }

  String _getStatusDisplayName(String? status) {
    switch (status) {
      case 'pending':
        return 'En Cola';
      case 'processing':
        return 'Enviando...';
      case 'completed':
        return 'Enviado';
      case 'approved':
        return 'Aprobado';
      case 'rejected':
        return 'Rechazado';
      case 'failed':
        return 'Error';
      case 'retrying':
        return 'Reintentando...';
      default:
        return 'Desconocido';
    }
  }

  // Progress Bar General
  Widget _buildProgressBar(List<dynamic> docs) {
    if (docs.isEmpty) return const SizedBox.shrink();

    final total = docs.length;
    final completed = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return [
        'completed',
        'approved',
        'failed',
        'rejected',
      ].contains(data['status']);
    }).length;
    final processing = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['status'] == 'processing';
    }).length;

    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso de Envío',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              Text(
                '$completed de $total completados',
                style: TextStyle(color: Colors.blue.shade600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(
              progress == 1.0 ? Colors.green : Colors.blue,
            ),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% completado',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              if (processing > 0)
                Text(
                  '$processing enviando...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Obtener status de respuesta DGII
  String _getDGIIStatus(Map<String, dynamic>? response) {
    if (response == null) return 'Sin respuesta';

    // === CASO 1: Analizar código DGII ===
    if (response.containsKey('data')) {
      final data = response['data'];
      Map<String, dynamic>? parsedData;

      // Si data es string, parsearlo
      if (data is String) {
        try {
          parsedData = jsonDecode(data);
        } catch (e) {
          return 'Error de formato';
        }
      } else if (data is Map<String, dynamic>) {
        parsedData = data;
      }

      if (parsedData != null) {
        // Verificar código
        if (parsedData.containsKey('codigo')) {
          final codigo = parsedData['codigo'];
          if (codigo == 0) {
            return 'Aprobado';
          } else {
            return 'Rechazado (Código $codigo)';
          }
        }

        // Verificar mensajes
        if (parsedData.containsKey('mensajes')) {
          final mensajes = parsedData['mensajes'] as List?;
          if (mensajes != null && mensajes.isNotEmpty) {
            return 'Rechazado (${mensajes.length} error${mensajes.length > 1 ? 'es' : ''})';
          }
        }
      }
    }

    // === CASO 2: Analizar respuesta directa ===
    if (response.containsKey('errors') && response['errors'] != null) {
      final errors = response['errors'] as List?;
      if (errors != null && errors.isNotEmpty) {
        return 'Rechazado';
      }
    }

    if (response.containsKey('status')) {
      final status = response['status']?.toString().toLowerCase();
      if (status == 'success' || status == 'approved') {
        return 'Aprobado';
      } else if (status == 'error' || status == 'rejected') {
        return 'Rechazado';
      }
    }

    return 'Procesado';
  }

  Color _getDGIIStatusColor(Map<String, dynamic>? response) {
    final status = _getDGIIStatus(response);
    switch (status) {
      case 'Aprobado':
        return Colors.green.shade700;
      case 'Rechazado':
        return Colors.red.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  // Manejar acciones del menú
  void _handleMenuAction(BuildContext context, String action, dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;

    switch (action) {
      case 'retry':
        _retryItem(doc.id);
        break;
      case 'view_response':
        _showDGIIResponse(context, data['dgii_response']);
        break;
      case 'cancel':
        _cancelItem(doc.id, data['numero_factura'] ?? 'Sin número');
        break;
    }
  }

  // Reintentar item (método simple sin diálogo)
  void _retryItem(String docId) {
    FirebaseFirestore.instance.collection('invoice_queue').doc(docId).update({
      'status': 'pending',
      'retry_count': 0,
      'error_message': null,
    });

    Get.snackbar(
      'Reintentando',
      'La factura se reintentará automáticamente',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  // Cancelar item
  void _cancelItem(String docId, String numeroFactura) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancelar Envío'),
        content: Text(
          '¿Estás seguro de cancelar el envío de la factura $numeroFactura?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              FirebaseFirestore.instance
                  .collection('invoice_queue')
                  .doc(docId)
                  .delete();
              Get.snackbar(
                'Cancelado',
                'Envío de factura $numeroFactura cancelado',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  // Mostrar respuesta DGII formateada
  void _showDGIIResponse(BuildContext context, Map<String, dynamic>? response) {
    if (response == null) {
      _showSimpleDialog(context, 'Respuesta DGII', 'Sin respuesta disponible');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respuesta DGII'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [_buildFormattedResponse(response)],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Construir respuesta formateada
  Widget _buildFormattedResponse(Map<String, dynamic> response) {
    final widgets = <Widget>[];

    // === CASO 1: Respuesta con data ===
    if (response.containsKey('data')) {
      final data = response['data'];
      Map<String, dynamic>? parsedData;

      if (data is String) {
        try {
          parsedData = jsonDecode(data);
        } catch (e) {
          widgets.add(_buildErrorSection('Error de formato', data.toString()));
          return Column(children: widgets);
        }
      } else if (data is Map<String, dynamic>) {
        parsedData = data;
      }

      if (parsedData != null) {
        // Mostrar código
        if (parsedData.containsKey('codigo')) {
          final codigo = parsedData['codigo'];
          final isError = codigo != 0;
          widgets.add(
            _buildStatusSection(
              'Código DGII',
              codigo.toString(),
              isError ? Colors.red : Colors.green,
            ),
          );
        }

        // Mostrar mensajes
        if (parsedData.containsKey('mensajes')) {
          final mensajes = parsedData['mensajes'] as List?;
          if (mensajes != null && mensajes.isNotEmpty) {
            widgets.add(const SizedBox(height: 16));
            widgets.add(_buildMessagesSection(mensajes));
          }
        }
      }
    }

    // === CASO 2: Status HTTP ===
    if (response.containsKey('status')) {
      final status = response['status'];
      final isError = status is int && status >= 400;
      widgets.add(
        _buildStatusSection(
          'Status HTTP',
          status.toString(),
          isError ? Colors.red : Colors.green,
        ),
      );
    }

    // === CASO 3: Mensaje directo ===
    if (response.containsKey('message')) {
      widgets.add(
        _buildErrorSection('Mensaje', response['message'].toString()),
      );
    }

    // Si no hay contenido específico, mostrar JSON raw
    if (widgets.isEmpty) {
      widgets.add(
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            JsonEncoder.withIndent('  ').convert(response),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildStatusSection(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            value == '0' ? Icons.check_circle : Icons.error,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesSection(List<dynamic> mensajes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mensajes:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...mensajes.asMap().entries.map((entry) {
          final index = entry.key;
          final mensaje = entry.value;

          if (mensaje is Map<String, dynamic>) {
            final codigo = mensaje['codigo'] ?? '';
            final valor = mensaje['valor'] ?? mensaje['message'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Mensaje ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      if (codigo.toString().isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Código: $codigo',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(valor.toString(), style: const TextStyle(fontSize: 13)),
                ],
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(mensaje.toString()),
          );
        }),
      ],
    );
  }

  Widget _buildErrorSection(String title, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }

  void _showSimpleDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Mostrar detalles del item
  void _showItemDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles - ${data['numero_factura'] ?? 'Sin número'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Estado', _getStatusDisplayName(data['status'])),
              _buildDetailRow('eCF', data['encf'] ?? 'N/A'),
              _buildDetailRow('Número', data['numero_factura'] ?? 'N/A'),
              if (data['created_at'] != null)
                _buildDetailRow('Creado', _formatTimestamp(data['created_at'])),
              if (data['processed_at'] != null)
                _buildDetailRow(
                  'Procesado',
                  _formatTimestamp(data['processed_at']),
                ),
              if (data['retry_count'] != null && data['retry_count'] > 0)
                _buildDetailRow('Reintentos', data['retry_count'].toString()),
              if (data['error_message'] != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Error:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  data['error_message'].toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              if (data['dgii_response'] != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Respuesta DGII:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _getDGIIStatus(data['dgii_response']),
                  style: TextStyle(
                    color: _getDGIIStatusColor(data['dgii_response']),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';

    try {
      final dateTime = (timestamp as Timestamp).toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  // Iniciar procesador manualmente
  void _startProcessor() {
    debugPrint('[QueueScreenSimple] 🚀 Iniciando procesador manualmente');
    QueueProcessorService.instance.startProcessing();

    Get.snackbar(
      'Procesador Iniciado',
      'El procesador automático ha sido iniciado',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.play_arrow, color: Colors.white),
    );
  }

  // Detener procesador manualmente
  void _stopProcessor() {
    debugPrint('[QueueScreenSimple] ⏹️ Deteniendo procesador manualmente');
    QueueProcessorService.instance.stopProcessing();

    Get.snackbar(
      'Procesador Detenido',
      'El procesador automático ha sido detenido',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.stop, color: Colors.white),
    );
  }

  // Procesar todos los pendientes manualmente
  void _processAllPending() async {
    debugPrint(
      '[QueueScreenSimple] 🔄 Procesando todos los pendientes manualmente',
    );

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      Get.snackbar(
        'Error',
        'Usuario no autenticado',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Obtener todos los items pendientes
      final query = await FirebaseFirestore.instance
          .collection('invoice_queue')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (query.docs.isEmpty) {
        Get.snackbar(
          'Sin Items',
          'No hay facturas pendientes para procesar',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      debugPrint(
        '[QueueScreenSimple] 📊 Encontrados ${query.docs.length} items pendientes',
      );

      // Iniciar el procesador
      QueueProcessorService.instance.startProcessing();

      Get.snackbar(
        'Procesando',
        '${query.docs.length} facturas en cola. Procesando automáticamente...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        icon: const Icon(Icons.sync, color: Colors.white),
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('[QueueScreenSimple] ❌ Error: $e');
      Get.snackbar(
        'Error',
        'Error verificando cola: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Construir botones de acción para cada factura
  Widget _buildActionButtons(
    BuildContext context,
    dynamic doc,
    Map<String, dynamic> data,
  ) {
    final status = data['status'] as String?;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge de reintentos
        if (data['retry_count'] != null && data['retry_count'] > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Intento ${data['retry_count']}',
              style: TextStyle(fontSize: 10, color: Colors.amber.shade800),
            ),
          ),
          const SizedBox(width: 4),
        ],

        // Botón Reintentar (para failed o rejected)
        if (['failed', 'rejected'].contains(status))
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: () => _retryItemWithDialog(
              doc.id,
              data['numero_factura'] ?? 'Sin número',
            ),
            tooltip: 'Reintentar',
            color: Colors.blue,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),

        // Botón Ver Request Enviado
        IconButton(
          icon: const Icon(Icons.send, size: 18),
          onPressed: () => _showRequestSent(context, data),
          tooltip: 'Ver Request Enviado',
          color: Colors.blue,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),

        // Botón Ver Respuesta DGII
        if (data['dgii_response'] != null)
          IconButton(
            icon: const Icon(Icons.visibility, size: 18),
            onPressed: () => _showDGIIResponse(context, data['dgii_response']),
            tooltip: 'Ver Respuesta DGII',
            color: Colors.green,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),

        // Botón Eliminar de Cola (para pending, failed, rejected)
        if (['pending', 'failed', 'rejected', 'retrying'].contains(status))
          IconButton(
            icon: const Icon(Icons.delete, size: 18),
            onPressed: () => _removeFromQueue(
              doc.id,
              data['numero_factura'] ?? 'Sin número',
            ),
            tooltip: 'Eliminar de Cola',
            color: Colors.red,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),

        // Botón Procesar Ahora (solo para pending)
        if (status == 'pending')
          IconButton(
            icon: const Icon(Icons.play_arrow, size: 18),
            onPressed: () =>
                _processItemNow(doc.id, data['numero_factura'] ?? 'Sin número'),
            tooltip: 'Procesar Ahora',
            color: Colors.orange,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
      ],
    );
  }

  // Reintentar item específico con diálogo
  void _retryItemWithDialog(String docId, String numeroFactura) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reintentar Envío'),
        content: Text(
          '¿Deseas reintentar el envío de la factura $numeroFactura?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();

              FirebaseFirestore.instance
                  .collection('invoice_queue')
                  .doc(docId)
                  .update({
                    'status': 'pending',
                    'retry_count': 0,
                    'error_message': null,
                    'dgii_response': null,
                  });

              // Iniciar procesador para que tome este item
              QueueProcessorService.instance.startProcessing();

              Get.snackbar(
                'Reintentando',
                'La factura $numeroFactura se reintentará automáticamente',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue,
                colorText: Colors.white,
                icon: const Icon(Icons.refresh, color: Colors.white),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // Eliminar de la cola
  void _removeFromQueue(String docId, String numeroFactura) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar de Cola'),
        content: Text(
          '¿Estás seguro de eliminar la factura $numeroFactura de la cola?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();

              FirebaseFirestore.instance
                  .collection('invoice_queue')
                  .doc(docId)
                  .delete();

              Get.snackbar(
                'Eliminado',
                'Factura $numeroFactura eliminada de la cola',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                icon: const Icon(Icons.delete, color: Colors.white),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // Procesar item específico ahora
  void _processItemNow(String docId, String numeroFactura) {
    Get.dialog(
      AlertDialog(
        title: const Text('Procesar Ahora'),
        content: Text(
          '¿Deseas procesar inmediatamente la factura $numeroFactura?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();

              // Marcar como priority o simplemente iniciar el procesador
              QueueProcessorService.instance.startProcessing();

              Get.snackbar(
                'Procesando',
                'La factura $numeroFactura se procesará inmediatamente',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                icon: const Icon(Icons.play_arrow, color: Colors.white),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Procesar'),
          ),
        ],
      ),
    );
  }

  // Limpiar items completados
  void _clearCompletedItems() {
    Get.dialog(
      AlertDialog(
        title: const Text('Limpiar Cola'),
        content: const Text(
          '¿Deseas eliminar todas las facturas completadas (aprobadas, rechazadas y fallidas) de la cola?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              try {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId == null) {
                  Get.snackbar(
                    'Error',
                    'Usuario no autenticado',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                // Obtener items completados
                final query = await FirebaseFirestore.instance
                    .collection('invoice_queue')
                    .where('user_id', isEqualTo: userId)
                    .where(
                      'status',
                      whereIn: ['completed', 'approved', 'rejected', 'failed'],
                    )
                    .get();

                if (query.docs.isEmpty) {
                  Get.snackbar(
                    'Sin Items',
                    'No hay facturas completadas para limpiar',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                  return;
                }

                // Eliminar en lote
                final batch = FirebaseFirestore.instance.batch();
                for (final doc in query.docs) {
                  batch.delete(doc.reference);
                }
                await batch.commit();

                Get.snackbar(
                  'Limpiado',
                  '${query.docs.length} facturas completadas eliminadas de la cola',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  icon: const Icon(Icons.clear_all, color: Colors.white),
                );
              } catch (e) {
                debugPrint('[QueueScreenSimple] ❌ Error limpiando cola: $e');
                Get.snackbar(
                  'Error',
                  'Error limpiando cola: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  // Vaciar toda la cola
  void _clearAllItems() {
    Get.dialog(
      AlertDialog(
        title: const Text('⚠️ Vaciar Cola Completa'),
        content: const Text(
          'ATENCIÓN: Esto eliminará TODAS las facturas de la cola, incluyendo las pendientes.\n\n¿Estás seguro de continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              try {
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId == null) {
                  Get.snackbar(
                    'Error',
                    'Usuario no autenticado',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                // Detener procesador primero
                QueueProcessorService.instance.stopProcessing();

                // Obtener todos los items del usuario
                final query = await FirebaseFirestore.instance
                    .collection('invoice_queue')
                    .where('user_id', isEqualTo: userId)
                    .get();

                if (query.docs.isEmpty) {
                  Get.snackbar(
                    'Cola Vacía',
                    'No hay facturas en la cola',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                  return;
                }

                // Eliminar todos en lote
                final batch = FirebaseFirestore.instance.batch();
                for (final doc in query.docs) {
                  batch.delete(doc.reference);
                }
                await batch.commit();

                Get.snackbar(
                  'Cola Vaciada',
                  '${query.docs.length} facturas eliminadas de la cola',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                );
              } catch (e) {
                debugPrint('[QueueScreenSimple] ❌ Error vaciando cola: $e');
                Get.snackbar(
                  'Error',
                  'Error vaciando cola: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, Vaciar Todo'),
          ),
        ],
      ),
    );
  }

  // Mostrar el request que se envió a la DGII
  void _showRequestSent(BuildContext context, Map<String, dynamic> data) {
    // Intentar obtener el request real enviado
    final realRequestData = data['dgii_request_data'] as Map<String, dynamic>?;
    final invoiceData = data['invoice_data'] as Map<String, dynamic>? ?? {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Enviado a DGII'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (realRequestData != null)
                _buildRealRequestPreview(realRequestData)
              else
                _buildRequestPreview(invoiceData),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // Construir preview del request
  Widget _buildRequestPreview(Map<String, dynamic> invoiceData) {
    // Recrear el scenario que se enviaría (simulado)
    final scenario = _buildScenarioPreview(invoiceData);

    final requestBody = {
      'scenarios': [scenario],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información general
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Información del Request',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Endpoint: [Tu endpoint configurado]/test-scenarios-json'),
              Text('Método: POST'),
              Text('Content-Type: application/json'),
              Text('eNCF de prueba: E320000000213'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Scenario individual
        const Text(
          'Scenario (datos principales):',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            JsonEncoder.withIndent('  ').convert(scenario),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),

        const SizedBox(height: 16),

        // Request body completo
        const Text(
          'Request Body Completo:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            JsonEncoder.withIndent('  ').convert(requestBody),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
      ],
    );
  }

  // Construir scenario preview (simulado)
  Map<String, dynamic> _buildScenarioPreview(Map<String, dynamic> invoiceData) {
    final scenario = <String, dynamic>{};

    // Orden correcto según XSD
    scenario['Version'] = invoiceData['version'] ?? '1.0';
    scenario['TipoeCF'] = '32'; // TEMPORAL
    scenario['eNCF'] = 'E320000000356'; // TEMPORAL

    // Datos del emisor (simulados desde Firebase)
    scenario['RNCEmisor'] = '[RNC desde Firebase]';
    scenario['RazonSocialEmisor'] = '[Razón Social desde Firebase]';
    scenario['DireccionEmisor'] = '[Dirección desde Firebase]';

    // Fecha de emisión
    if (invoiceData['fechaemision'] != null) {
      final fechaEmision = invoiceData['fechaemision'].toString();
      // Convertir formato de fecha de MM/dd/yyyy o dd/MM/yyyy a dd-MM-yyyy
      final formattedDate = fechaEmision.replaceAll('/', '-');
      scenario['FechaEmision'] = formattedDate;
    }

    // Tipo de ingresos y pago
    scenario['TipoIngresos'] = invoiceData['tipoingresos'] ?? '01';
    scenario['TipoPago'] = invoiceData['tipopago'] ?? '1';

    // Comprador
    if (invoiceData['rnccomprador'] != null) {
      scenario['RNCComprador'] = invoiceData['rnccomprador'];
    }
    if (invoiceData['razonsocialcomprador'] != null) {
      scenario['RazonSocialComprador'] = invoiceData['razonsocialcomprador'];
    }

    // Totales
    scenario['MontoTotal'] = invoiceData['montototal'] ?? '0.00';

    // Items básicos
    scenario['NumeroLinea[1]'] = '1';
    scenario['IndicadorFacturacion[1]'] = '4';
    scenario['NombreItem[1]'] = 'Servicio Médico';
    scenario['IndicadorBienoServicio[1]'] = '2';
    scenario['CantidadItem[1]'] = '1.00';
    scenario['PrecioUnitarioItem[1]'] = invoiceData['montototal'] ?? '0.00';
    scenario['MontoItem[1]'] = invoiceData['montototal'] ?? '0.00';

    // CasoPrueba
    scenario['CasoPrueba'] = '[RNC]E320000000213';

    return scenario;
  }

  // Construir preview del request real enviado
  Widget _buildRealRequestPreview(Map<String, dynamic> realRequestData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información general
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Request Real Enviado',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Endpoint: ${realRequestData['endpoint'] ?? 'N/A'}'),
              Text('Método: POST'),
              Text('Content-Type: application/json'),
              Text(
                'ENCF: ${realRequestData['scenarios']?[0]?['ENCF'] ?? 'N/A'}',
              ),
              Text(
                'TipoeCF: ${realRequestData['scenarios']?[0]?['TipoeCF'] ?? 'N/A'}',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Request body completo real
        const Text(
          'Request Body Real Enviado:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            JsonEncoder.withIndent('  ').convert(realRequestData),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ),
      ],
    );
  }
}
