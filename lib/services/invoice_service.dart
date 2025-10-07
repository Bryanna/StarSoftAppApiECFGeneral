import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import '../models/invoice.dart';
import '../models/ui_types.dart';
import 'company_config_service.dart';

class InvoiceService {
  final CompanyConfigService _configService = CompanyConfigService();

  // Obtiene facturas reales desde el endpoint ERP configurado
  Future<List<Datum>> fetchInvoices(InvoiceCategory category) async {
    try {
      // Obtener URL del ERP desde la configuración
      final erpUrl = await _configService.getERPEndpointUrl();

      // Si no hay URL configurada o es "Sin configurar", lanzar excepción específica
      if (erpUrl == null || erpUrl.isEmpty || erpUrl == 'Sin configurar') {
        throw ERPNotConfiguredException('URL del ERP no configurado');
      }

      // El URL ERP ya debe incluir la ruta completa, no agregar /api/invoices
      final fullUrl = erpUrl.endsWith('/')
          ? erpUrl.substring(0, erpUrl.length - 1)
          : erpUrl;

      final uri = Uri.parse(fullUrl);
      debugPrint('[InvoiceService] GET $uri (category=$category)');

      final resp = await http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      debugPrint(
        '[InvoiceService] status=${resp.statusCode} length=${resp.body.length}',
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final model = invoiceModelFromJson(resp.body);
        final data = model.data ?? [];

        // Si no hay datos, lanzar excepción específica
        if (data.isEmpty) {
          throw NoInvoicesFoundException(
            'No hay facturas pendientes en el ERP',
          );
        }

        return data;
      }

      // Si el servidor responde con error, lanzar excepción específica
      throw ERPConnectionException(
        'Error del servidor ERP: ${resp.statusCode}',
      );
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

  // La generación de datos falsos ya no es necesaria.
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
