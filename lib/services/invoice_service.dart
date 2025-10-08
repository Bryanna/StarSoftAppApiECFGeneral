import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/invoice.dart';
import '../models/ui_types.dart';
import 'fake_invoices_data.dart';

class InvoiceService {
  // Obtiene facturas reales desde el endpoint ERP configurado
  Future<List<Datum>> fetchInvoices(InvoiceCategory category) async {
    try {
      // Por ahora, siempre usar datos fake para desarrollo
      debugPrint('[InvoiceService] Using fake data for development');
      return await _generateFakeInvoices(category);
    } on ERPNotConfiguredException {
      rethrow;
    } on NoInvoicesFoundException {
      rethrow;
    } on ERPConnectionException {
      rethrow;
    } on TimeoutException catch (e) {
      debugPrint('[InvoiceService] Timeout: ${e.message ?? '20s'}');
      throw ERPConnectionException(
        'Timeout conectando al ERP (${e.message ?? '20s'})',
      );
    } catch (e, s) {
      debugPrint('[InvoiceService] Error al obtener facturas: $e');
      debugPrint('$s');
      throw ERPConnectionException('Error conectando al ERP: $e');
    }
  }

  // Genera datos fake para testing
  Future<List<Datum>> _generateFakeInvoices(InvoiceCategory category) async {
    debugPrint(
      '[InvoiceService] Generando datos fake para categoría: $category',
    );

    try {
      // Usar datos básicos que sabemos que funcionan
      final fakeInvoices = _generateBasicFakeInvoices(category);

      debugPrint(
        '[InvoiceService] Generated ${fakeInvoices.length} fake invoices for $category',
      );
      return fakeInvoices;
    } catch (e) {
      debugPrint('[InvoiceService] Error generating fake data: $e');
      return [];
    }
  }

  // Datos completos basados en ejemplos.json y tipos.json
  List<Datum> _generateBasicFakeInvoices(InvoiceCategory category) {
    // Obtener TODAS las facturas del archivo fake_invoices_data.dart
    final allInvoices = getAllFakeInvoices();

    // Filtrar por categoría
    switch (category) {
      case InvoiceCategory.pacientes:
        // Facturas de consumo y crédito fiscal para pacientes
        return allInvoices
            .where(
              (inv) =>
                  inv.tipoecf == '31' ||
                  inv.tipoecf == '32' ||
                  inv.tipoecf == '33',
            )
            .toList();
      case InvoiceCategory.ars:
        // Facturas específicas para ARS (RNC 533445861)
        return allInvoices
            .where((inv) => inv.rnccomprador == '533445861')
            .toList();
      case InvoiceCategory.enviados:
        // Facturas que han sido firmadas/enviadas
        return allInvoices.where((inv) => inv.fechaHoraFirma != null).toList();
      case InvoiceCategory.notasCredito:
        // Notas de crédito (E43)
        return allInvoices.where((inv) => inv.tipoecf == '43').toList();
      case InvoiceCategory.notasDebito:
        // Notas de débito (E41)
        return allInvoices.where((inv) => inv.tipoecf == '41').toList();
      case InvoiceCategory.gastos:
        // Gastos menores y comprobantes de compras (E44, E45, E46, E47)
        return allInvoices
            .where(
              (inv) =>
                  inv.tipoecf == '44' ||
                  inv.tipoecf == '45' ||
                  inv.tipoecf == '46' ||
                  inv.tipoecf == '47',
            )
            .toList();
      case InvoiceCategory.rechazados:
        // Facturas rechazadas/anuladas
        return allInvoices.where((inv) => inv.fAnulada == true).toList();
    }
  }
}

// Excepciones personalizadas para manejo de errores específicos
class ERPNotConfiguredException implements Exception {
  final String message;
  ERPNotConfiguredException(this.message);

  @override
  String toString() => 'ERPNotConfiguredException: $message';
}

class NoInvoicesFoundException implements Exception {
  final String message;
  NoInvoicesFoundException(this.message);

  @override
  String toString() => 'NoInvoicesFoundException: $message';
}

class ERPConnectionException implements Exception {
  final String message;
  ERPConnectionException(this.message);

  @override
  String toString() => 'ERPConnectionException: $message';
}
