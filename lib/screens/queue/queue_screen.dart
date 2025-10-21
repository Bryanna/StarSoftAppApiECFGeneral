import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/invoice_queue_item.dart';
import '../../services/firebase_queue_service.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 50),
            const Text('Cola de Envío DGII'),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => _showClearDialog(context),
            tooltip: 'Limpiar Completados',
          ),
        ],
      ),
      body: StreamBuilder<List<InvoiceQueueItem>>(
        stream: FirebaseQueueService.instance.queueStream,
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
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('Volver'),
                  ),
                ],
              ),
            );
          }

          final queueItems = snapshot.data ?? [];

          if (queueItems.isEmpty) {
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
              // Resumen de la cola
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: _buildQueueSummary(queueItems),
              ),

              // Lista de items
              Expanded(
                child: ListView.builder(
                  itemCount: queueItems.length,
                  itemBuilder: (context, index) {
                    final item = queueItems[index];
                    return _buildQueueItemCard(context, item, index + 1);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQueueSummary(List<InvoiceQueueItem> items) {
    final pending = items.where((i) => i.status == QueueStatus.pending).length;
    final processing = items
        .where((i) => i.status == QueueStatus.processing)
        .length;
    final completed = items
        .where(
          (i) =>
              [QueueStatus.completed, QueueStatus.approved].contains(i.status),
        )
        .length;
    final failed = items
        .where(
          (i) => [QueueStatus.failed, QueueStatus.rejected].contains(i.status),
        )
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'En Cola',
            pending.toString(),
            Colors.orange,
            Icons.schedule,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Enviando',
            processing.toString(),
            Colors.blue,
            Icons.sync,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Exitosos',
            completed.toString(),
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Errores',
            failed.toString(),
            Colors.red,
            Icons.error,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueItemCard(
    BuildContext context,
    InvoiceQueueItem item,
    int position,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.status.color.withOpacity(0.1),
          child: item.status == QueueStatus.processing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(item.status.color),
                  ),
                )
              : Icon(item.status.icon, color: item.status.color, size: 20),
        ),
        title: Text(
          item.numeroFactura.isNotEmpty
              ? 'Factura ${item.numeroFactura}'
              : 'eCF: ${item.encf}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.status.displayName,
              style: TextStyle(
                color: item.status.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (item.errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                item.errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (item.dgiiResponse != null) ...[
              const SizedBox(height: 4),
              Text(
                'Respuesta DGII disponible',
                style: TextStyle(color: Colors.green.shade700, fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.retryCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Intento ${item.retryCount}',
                  style: TextStyle(fontSize: 10, color: Colors.amber.shade800),
                ),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, value, item),
              itemBuilder: (context) => [
                if (item.status == QueueStatus.failed)
                  const PopupMenuItem(
                    value: 'retry',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 16),
                        SizedBox(width: 8),
                        Text('Reintentar'),
                      ],
                    ),
                  ),
                if (item.dgiiResponse != null)
                  const PopupMenuItem(
                    value: 'view_response',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 16),
                        SizedBox(width: 8),
                        Text('Ver Respuesta'),
                      ],
                    ),
                  ),
                if ([
                  QueueStatus.pending,
                  QueueStatus.retrying,
                ].contains(item.status))
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Cancelar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () => _showItemDetails(context, item),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    InvoiceQueueItem item,
  ) {
    switch (action) {
      case 'retry':
        FirebaseQueueService.instance.retryFailedItem(item.id);
        Get.snackbar(
          'Reintentando',
          'La factura ${item.numeroFactura} se reintentará',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'view_response':
        _showResponseDialog(context, item);
        break;
      case 'cancel':
        _showCancelDialog(context, item);
        break;
    }
  }

  void _showItemDetails(BuildContext context, InvoiceQueueItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles - ${item.numeroFactura}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Estado', item.status.displayName),
              _buildDetailRow('eCF', item.encf),
              _buildDetailRow('Creado', _formatDateTime(item.createdAt)),
              if (item.processedAt != null)
                _buildDetailRow(
                  'Procesado',
                  _formatDateTime(item.processedAt!),
                ),
              if (item.retryCount > 0)
                _buildDetailRow('Reintentos', item.retryCount.toString()),
              if (item.errorMessage != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Error:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  item.errorMessage!,
                  style: const TextStyle(color: Colors.red),
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

  void _showResponseDialog(BuildContext context, InvoiceQueueItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respuesta DGII'),
        content: SingleChildScrollView(
          child: Text(
            item.dgiiResponse.toString(),
            style: const TextStyle(fontFamily: 'monospace'),
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

  void _showCancelDialog(BuildContext context, InvoiceQueueItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Envío'),
        content: Text(
          '¿Estás seguro de cancelar el envío de la factura ${item.numeroFactura}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              FirebaseQueueService.instance.cancelQueueItem(item.id);
              Get.snackbar(
                'Cancelado',
                'Envío de factura ${item.numeroFactura} cancelado',
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

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Cola'),
        content: const Text(
          '¿Deseas eliminar todos los items completados y fallidos de la cola?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              FirebaseQueueService.instance.clearCompletedItems();
              Get.snackbar(
                'Limpiado',
                'Items completados eliminados de la cola',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
