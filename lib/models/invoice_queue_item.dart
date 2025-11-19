import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InvoiceQueueItem {
  final String id;
  final String invoiceId;
  final String encf;
  final String numeroFactura;
  final Map<String, dynamic> invoiceData;
  final QueueStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? errorMessage;
  final Map<String, dynamic>? dgiiResponse;
  final Map<String, dynamic>? dgiiRequestData;
  final int retryCount;
  final int position;

  InvoiceQueueItem({
    required this.id,
    required this.invoiceId,
    required this.encf,
    required this.numeroFactura,
    required this.invoiceData,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.errorMessage,
    this.dgiiResponse,
    this.dgiiRequestData,
    this.retryCount = 0,
    this.position = 0,
  });

  factory InvoiceQueueItem.fromFirestore(Map<String, dynamic> data, String id) {
    return InvoiceQueueItem(
      id: id,
      invoiceId: data['invoice_id'] ?? '',
      encf: data['encf'] ?? '',
      numeroFactura: data['numero_factura'] ?? '',
      invoiceData: Map<String, dynamic>.from(data['invoice_data'] ?? {}),
      status: QueueStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => QueueStatus.pending,
      ),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      processedAt: (data['processed_at'] as Timestamp?)?.toDate(),
      errorMessage: data['error_message'],
      dgiiResponse: data['dgii_response'] != null
          ? Map<String, dynamic>.from(data['dgii_response'])
          : null,
      dgiiRequestData: data['dgii_request_data'] != null
          ? Map<String, dynamic>.from(data['dgii_request_data'])
          : null,
      retryCount: data['retry_count'] ?? 0,
      position: data['position'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'invoice_id': invoiceId,
      'encf': encf,
      'numero_factura': numeroFactura,
      'invoice_data': invoiceData,
      'status': status.name,
      'created_at': Timestamp.fromDate(createdAt),
      'processed_at': processedAt != null
          ? Timestamp.fromDate(processedAt!)
          : null,
      'error_message': errorMessage,
      'dgii_response': dgiiResponse,
      'dgii_request_data': dgiiRequestData,
      'retry_count': retryCount,
      'position': position,
    };
  }

  InvoiceQueueItem copyWith({
    QueueStatus? status,
    DateTime? processedAt,
    String? errorMessage,
    Map<String, dynamic>? dgiiResponse,
    Map<String, dynamic>? dgiiRequestData,
    int? retryCount,
    int? position,
  }) {
    return InvoiceQueueItem(
      id: id,
      invoiceId: invoiceId,
      encf: encf,
      numeroFactura: numeroFactura,
      invoiceData: invoiceData,
      status: status ?? this.status,
      createdAt: createdAt,
      processedAt: processedAt ?? this.processedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      dgiiResponse: dgiiResponse ?? this.dgiiResponse,
      dgiiRequestData: dgiiRequestData ?? this.dgiiRequestData,
      retryCount: retryCount ?? this.retryCount,
      position: position ?? this.position,
    );
  }
}

enum QueueStatus {
  pending, // En cola esperando
  processing, // Enviando a DGII
  completed, // Enviado exitosamente
  approved, // Aprobado por DGII
  rejected, // Rechazado por DGII
  failed, // Error técnico
  retrying, // Reintentando envío
}

extension QueueStatusExtension on QueueStatus {
  String get displayName {
    switch (this) {
      case QueueStatus.pending:
        return 'En Cola';
      case QueueStatus.processing:
        return 'Enviando...';
      case QueueStatus.completed:
        return 'Enviado';
      case QueueStatus.approved:
        return 'Aprobado';
      case QueueStatus.rejected:
        return 'Rechazado';
      case QueueStatus.failed:
        return 'Error';
      case QueueStatus.retrying:
        return 'Reintentando...';
    }
  }

  Color get color {
    switch (this) {
      case QueueStatus.pending:
        return Colors.orange;
      case QueueStatus.processing:
        return Colors.blue;
      case QueueStatus.completed:
        return Colors.green;
      case QueueStatus.approved:
        return Colors.green.shade700;
      case QueueStatus.rejected:
        return Colors.red;
      case QueueStatus.failed:
        return Colors.red.shade700;
      case QueueStatus.retrying:
        return Colors.amber;
    }
  }

  IconData get icon {
    switch (this) {
      case QueueStatus.pending:
        return Icons.schedule;
      case QueueStatus.processing:
        return Icons.sync;
      case QueueStatus.completed:
        return Icons.check_circle;
      case QueueStatus.approved:
        return Icons.verified;
      case QueueStatus.rejected:
        return Icons.cancel;
      case QueueStatus.failed:
        return Icons.error;
      case QueueStatus.retrying:
        return Icons.refresh;
    }
  }
}
