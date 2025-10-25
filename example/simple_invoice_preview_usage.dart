import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../lib/models/erp_invoice.dart';
import '../lib/screens/invoice_preview/invoice_preview_screen.dart';

/// Ejemplo de uso de la pantalla simple de vista previa de facturas
///
/// Esta versión simplificada se enfoca en lo esencial:
/// - PDF más grande que ocupa casi toda la pantalla
/// - Botones de descarga e impresión en el AppBar
/// - Floating Action Button para descarga rápida
/// - Menú con opciones adicionales (pantalla completa, compartir, regenerar)
/// - Sin complejidad innecesaria
class SimpleInvoicePreviewUsageExample extends StatelessWidget {
  const SimpleInvoicePreviewUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Previa Simple - Ejemplo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título y descripción
            Text(
              'Vista Previa Simple de Facturas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Versión simplificada enfocada en mostrar el PDF más grande y con opciones de descarga directas.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Características principales
            _buildFeaturesList(),
            const SizedBox(height: 32),

            // Botones de ejemplo
            _buildExampleButtons(context),

            const SizedBox(height: 32),

            // Comparación simple
            _buildSimpleComparison(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      '📱 PDF ocupa casi toda la pantalla',
      '📥 Botón de descarga directo en AppBar',
      '🖨️ Botón de impresión integrado',
      '🎯 Floating Action Button para descarga rápida',
      '📋 Menú con opciones adicionales',
      '🔄 Regeneración de PDF si hay errores',
      '📄 Vista en pantalla completa disponible',
      '🚀 Interfaz limpia y sin distracciones',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Características Principales:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...features.map((feature) => Padding(
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
        ),
      ],
    );
  }

  Widget _buildExampleButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Probar con Diferentes Tipos:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Factura médica
            ElevatedButton.icon(
              onPressed: () => _showSimplePreview(
                context,
                _createSampleInvoice('E31', 'Factura Médica', true),
              ),
              icon: const Icon(Icons.local_hospital),
              label: const Text('Factura Médica'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
            ),

            // Factura de consumo
            ElevatedButton.icon(
              onPressed: () => _showSimplePreview(
                context,
                _createSampleInvoice('E32', 'Factura Consumo', false),
              ),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Factura Consumo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),

            // Nota de crédito
            ElevatedButton.icon(
              onPressed: () => _showSimplePreview(
                context,
                _createSampleInvoice('E34', 'Nota Crédito', false),
              ),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Nota Crédito'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleComparison(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Antes vs Ahora - Versión Simple',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Antes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '❌ Antes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• PDF pequeño (80% pantalla)'),
                    const Text('• Necesitaba zoom para leer'),
                    const Text('• Pocas opciones de descarga'),
                    const Text('• Interfaz básica'),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // Ahora
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ Ahora',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('• PDF grande (95% pantalla)'),
                    const Text('• Lectura clara sin zoom'),
                    const Text('• Descarga directa desde AppBar'),
                    const Text('• Floating button para acceso rápido'),
                    const Text('• Menú con opciones adicionales'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSimplePreview(BuildContext context, ERPInvoice invoice) {
    // Simular navegación a la pantalla simple
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InvoicePreviewScreen(),
        settings: RouteSettings(arguments: invoice),
      ),
    );
  }

  ERPInvoice _createSampleInvoice(String tipoEcf, String tipo, bool isMedical) {
    return ERPInvoice(
      encf: '${tipoEcf}0000001234',
      tipoecf: tipoEcf.substring(1), // Remover la 'E'
      version: '1.0',
      fechaemision: '15/12/2024',
      numerofacturainterna: '${tipo.toUpperCase()}-2024-001234',

      // Emisor
      rncemisor: '123456789',
      razonsocialemisor: isMedical ? 'CENTRO MÉDICO EJEMPLO SRL' : 'EMPRESA EJEMPLO SRL',
      direccionemisor: 'Av. Principal No. 123, Santo Domingo',
      telefonoemisor1: '809-555-0123',
      correoemisor: 'facturacion@ejemplo.com',
      website: 'www.ejemplo.com',

      // Comprador
      rnccomprador: '40212345678',
      razonsocialcomprador: 'CLIENTE EJEMPLO',
      direccioncomprador: 'Calle Secundaria No. 456, Santiago',

      // Información médica (solo si es médica)
      aseguradora: isMedical ? 'ARS HUMANO' : null,
      noAutorizacion: isMedical ? 'AUTH-789456123' : null,
      nss: isMedical ? '12345678901' : null,
      medico: isMedical ? 'Dr. María Elena Rodríguez' : null,
      cedulaMedico: isMedical ? '001-1234567-8' : null,
      tipoFacturaTitulo: isMedical ? 'ARS - CONSULTA ESPECIALIZADA' : tipo,
      montoCobertura: isMedical ? '15000.00' : null,

      // Montos
      montogravadototal: '10000.00',
      montoexento: '2000.00',
      totalitbis: '1800.00',
      montototal: '13800.00',

      // Detalles básicos
      detalleFactura: '''[
        {
          "referencia": "ITEM001",
          "descripcion": "${isMedical ? 'Consulta médica especializada' : 'Producto/Servicio principal'}",
          "cantidad": 1,
          "precio": 8000.00,
          "total": 8000.00
        },
        {
          "referencia": "ITEM002",
          "descripcion": "${isMedical ? 'Examen complementario' : 'Producto/Servicio adicional'}",
          "cantidad": 1,
          "precio": 2000.00,
          "total": 2000.00
        },
        {
          "referencia": "ITEM003",
          "descripcion": "Servicio exento de impuestos",
          "cantidad": 1,
          "precio": 2000.00,
          "total": 2000.00
        }
      ]''',
    );
  }
}

/// Widget de demostración para mostrar la simplicidad
class SimplePreviewDemo extends StatelessWidget {
  const SimplePreviewDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo: Vista Previa Simple'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Vista Previa Simplificada',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            Text(
              'Enfocada en lo esencial: ver el PDF grande y descargarlo fácilmente',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Características clave
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Características Clave',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('✅ PDF ocupa 95% de la pantalla'),
                  const Text('✅ Botones de descarga e impresión directos'),
                  const Text('✅ Floating button para acceso rápido'),
                  const Text('✅ Menú con opciones adicionales'),
                  const Text('✅ Sin complejidad innecesaria'),
                  const Text('✅ Interfaz limpia y enfocada'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botón para probar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SimpleInvoicePreviewUsageExample(),
                  ),
                ),
                icon: const Icon(Icons.visibility),
                label: const Text('Probar Vista Previa Simple'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
