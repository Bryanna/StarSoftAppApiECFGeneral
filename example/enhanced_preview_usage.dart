import 'package:facturacion/models/erp_invoice_extensions.dart';
import 'package:flutter/material.dart';

import '../lib/models/erp_invoice.dart';
import '../lib/widgets/enhanced_invoice_preview.dart';

/// Ejemplo de uso de la vista previa mejorada de facturas
///
/// Esta nueva vista previa ofrece:
/// - Tamaño más grande (95% de la pantalla)
/// - Vista previa del PDF sin necesidad de zoom
/// - Botones integrados para imprimir, descargar y ver completo
/// - Información detallada de la factura en el header
/// - Diseño moderno con gradientes y sombras
/// - Manejo de errores mejorado
class EnhancedPreviewUsageExample extends StatelessWidget {
  const EnhancedPreviewUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Previa Mejorada - Ejemplo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y descripción
            Text(
              'Vista Previa Mejorada de Facturas',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              'La nueva vista previa ofrece una experiencia mejorada con:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Lista de características
            _buildFeatureList(),
            const SizedBox(height: 32),

            // Botones de ejemplo
            _buildExampleButtons(context),

            const SizedBox(height: 32),

            // Comparación con la vista anterior
            _buildComparison(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      '📱 Tamaño grande (95% de la pantalla)',
      '🔍 Vista previa clara sin necesidad de zoom',
      '📥 Botón de descarga integrado',
      '🖨️ Botón de impresión directa',
      '📄 Botón para ver en pantalla completa',
      '💫 Diseño moderno con gradientes',
      '📊 Información detallada en el header',
      '⚠️ Manejo de errores mejorado',
      '🔄 Regeneración automática del PDF',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.substring(0, 2), // Emoji
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature.substring(3), // Texto sin emoji
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildExampleButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ejemplos de Uso:',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Ejemplo con factura de consumo
            ElevatedButton.icon(
              onPressed: () => _showExamplePreview(
                context,
                _createSampleInvoice('E32', 'Factura de Consumo'),
              ),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Factura Consumo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            // Ejemplo con factura crédito fiscal
            ElevatedButton.icon(
              onPressed: () => _showExamplePreview(
                context,
                _createSampleInvoice('E31', 'Factura Crédito Fiscal'),
              ),
              icon: const Icon(Icons.account_balance),
              label: const Text('Crédito Fiscal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            // Ejemplo con nota de crédito
            ElevatedButton.icon(
              onPressed: () => _showExamplePreview(
                context,
                _createSampleInvoice('E34', 'Nota de Crédito'),
              ),
              icon: const Icon(Icons.receipt),
              label: const Text('Nota Crédito'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),

            // Ejemplo con gastos menores
            ElevatedButton.icon(
              onPressed: () => _showExamplePreview(
                context,
                _createSampleInvoice('E43', 'Gastos Menores'),
              ),
              icon: const Icon(Icons.money_off),
              label: const Text('Gastos Menores'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparison(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comparación con Vista Anterior',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vista anterior
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '❌ Vista Anterior',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Tamaño pequeño (80% pantalla)'),
                    const Text('• Necesitaba zoom para leer'),
                    const Text('• Solo botón "Ver Completo"'),
                    const Text('• Diseño básico'),
                    const Text('• Información limitada'),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Vista nueva
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ Vista Mejorada',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• Tamaño grande (95% pantalla)'),
                    const Text('• Lectura clara sin zoom'),
                    const Text('• Botones: Imprimir, Descargar, Ver'),
                    const Text('• Diseño moderno con gradientes'),
                    const Text('• Header con información completa'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExamplePreview(BuildContext context, ERPInvoice invoice) {
    showEnhancedInvoicePreview(
      context: context,
      invoice: invoice,
      customTitle: 'Ejemplo - ${invoice.tipoComprobanteDisplay}',
    );
  }

  ERPInvoice _createSampleInvoice(String tipoEcf, String tipo) {
    return ERPInvoice(
      encf: '${tipoEcf}0000000123',
      tipoecf: tipoEcf.substring(1), // Remover la 'E'
      version: '1.0',
      fechaemision: '15/12/2024',
      rncemisor: '123456789',
      razonsocialemisor: 'EMPRESA EJEMPLO SRL',
      direccionemisor: 'Calle Principal No. 123, Santo Domingo',
      telefonoemisor1: '809-555-0123',
      correoemisor: 'facturacion@ejemplo.com',
      rnccomprador: '987654321',
      razonsocialcomprador: 'CLIENTE EJEMPLO',
      direccioncomprador: 'Av. Independencia No. 456, Santiago',
      montogravadototal: '10000.00',
      montoexento: '0.00',
      totalitbis: '1800.00',
      montototal: '11800.00',
      numerofacturainterna: 'FAC-2024-001234',
      tipoFacturaTitulo: tipo,
      aseguradora: tipoEcf == 'E31' ? 'ARS EJEMPLO' : null,
      noAutorizacion: tipoEcf == 'E31' ? 'AUTH-123456' : null,
      nss: tipoEcf == 'E31' ? '12345678901' : null,
      medico: tipoEcf == 'E31' ? 'Dr. Juan Pérez' : null,
      cedulaMedico: tipoEcf == 'E31' ? '001-1234567-8' : null,
      detalleFactura: '''[
        {
          "referencia": "SERV001",
          "descripcion": "Consulta médica general",
          "cantidad": 1,
          "precio": 2500.00,
          "total": 2500.00
        },
        {
          "referencia": "MED001",
          "descripcion": "Medicamento recetado",
          "cantidad": 2,
          "precio": 750.00,
          "total": 1500.00
        },
        {
          "referencia": "LAB001",
          "descripcion": "Análisis de laboratorio",
          "cantidad": 1,
          "precio": 6000.00,
          "total": 6000.00
        }
      ]''',
    );
  }
}

/// Widget de demostración para mostrar las diferencias
class PreviewComparisonDemo extends StatelessWidget {
  const PreviewComparisonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comparación de Vistas Previa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Prueba ambas vistas para ver la diferencia',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Botón vista anterior (simulada)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showOldStylePreview(context),
                icon: const Icon(Icons.preview),
                label: const Text('Vista Previa Anterior (Simulada)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botón vista nueva
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showNewStylePreview(context),
                icon: const Icon(Icons.visibility),
                label: const Text('Vista Previa Mejorada (Nueva)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(16),
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
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Mejoras Implementadas',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('✅ Tamaño 95% vs 80% anterior'),
                  const Text('✅ Botones de acción integrados'),
                  const Text('✅ Descarga directa desde la vista previa'),
                  const Text('✅ Información completa en el header'),
                  const Text('✅ Diseño moderno y profesional'),
                  const Text('✅ Mejor experiencia de usuario'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOldStylePreview(BuildContext context) {
    // Simular la vista anterior con un diálogo más pequeño
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Vista Previa (Estilo Anterior)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Vista previa más pequeña'),
                      Text('Necesita zoom para leer'),
                      Text('Funcionalidad limitada'),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Ver Completo'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewStylePreview(BuildContext context) {
    final sampleInvoice = ERPInvoice(
      encf: 'E320000000456',
      tipoecf: '32',
      fechaemision: '15/12/2024',
      rncemisor: '123456789',
      razonsocialemisor: 'EMPRESA DEMO SRL',
      rnccomprador: '987654321',
      razonsocialcomprador: 'CLIENTE DEMO',
      montototal: '15000.00',
      numerofacturainterna: 'DEMO-001',
    );

    showEnhancedInvoicePreview(
      context: context,
      invoice: sampleInvoice,
      customTitle: 'Demostración - Vista Previa Mejorada',
    );
  }
}
