import 'package:flutter/material.dart';

import '../lib/models/erp_invoice.dart';
import '../lib/screens/invoice_preview/invoice_preview_screen.dart';

/// Ejemplo de uso de la pantalla de detalles de factura mejorada
///
/// La nueva InvoicePreviewScreen ofrece:
/// - Vista detallada con 3 pestañas organizadas
/// - Header con información principal y estado visual
/// - Pestaña de detalles con información completa
/// - Pestaña de PDF con vista previa integrada
/// - Pestaña de acciones con opciones disponibles
/// - Floating action buttons para acceso rápido
/// - Integración con la vista previa mejorada
class InvoiceDetailUsageExample extends StatelessWidget {
  const InvoiceDetailUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de Factura - Ejemplo'),
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
              'Pantalla de Detalles Mejorada',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              'La nueva pantalla de detalles ofrece una vista completa y organizada de la información de la factura.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Características principales
            _buildFeaturesList(),
            const SizedBox(height: 32),

            // Botones de ejemplo
            _buildExampleButtons(context),

            const SizedBox(height: 32),

            // Información de las pestañas
            _buildTabsInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      '📋 Header con información principal y estado visual',
      '🗂️ 3 pestañas organizadas: Detalles, PDF, Acciones',
      '📊 Información completa del emisor y comprador',
      '🏥 Sección médica para facturas de salud',
      '💰 Desglose tributario detallado',
      '📄 Lista de items con precios y cantidades',
      '🔍 Vista previa del PDF integrada',
      '⚡ Floating action buttons para acceso rápido',
      '📱 Diseño responsive y moderno',
      '🎨 Colores adaptativos según tipo de comprobante',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Características Principales:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...features.map(
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
        ),
      ],
    );
  }

  Widget _buildExampleButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ejemplos de Facturas:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Factura médica completa
            ElevatedButton.icon(
              onPressed: () =>
                  _showInvoiceDetail(context, _createMedicalInvoice()),
              icon: const Icon(Icons.local_hospital),
              label: const Text('Factura Médica'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
            ),

            // Factura de consumo
            ElevatedButton.icon(
              onPressed: () =>
                  _showInvoiceDetail(context, _createConsumerInvoice()),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Factura Consumo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
            ),

            // Nota de crédito
            ElevatedButton.icon(
              onPressed: () => _showInvoiceDetail(context, _createCreditNote()),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Nota Crédito'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
              ),
            ),

            // Gastos menores
            ElevatedButton.icon(
              onPressed: () =>
                  _showInvoiceDetail(context, _createMinorExpense()),
              icon: const Icon(Icons.money_off),
              label: const Text('Gastos Menores'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabsInfo(BuildContext context) {
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
            'Organización por Pestañas',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Pestaña Detalles
          _buildTabDescription(
            icon: Icons.info_outline,
            title: '📋 Detalles',
            description:
                'Información completa del emisor, comprador, datos médicos (si aplica), desglose tributario y lista de items.',
            color: Colors.blue,
          ),

          const SizedBox(height: 12),

          // Pestaña PDF
          _buildTabDescription(
            icon: Icons.picture_as_pdf,
            title: '📄 PDF',
            description:
                'Vista previa del documento PDF generado con indicadores de estado y opciones de regeneración.',
            color: Colors.red,
          ),

          const SizedBox(height: 12),

          // Pestaña Acciones
          _buildTabDescription(
            icon: Icons.settings,
            title: '⚙️ Acciones',
            description:
                'Opciones disponibles: vista previa mejorada, descarga, impresión, compartir y más.',
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildTabDescription({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInvoiceDetail(BuildContext context, ERPInvoice invoice) {
    // Simular navegación a la pantalla de detalles
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InvoicePreviewScreen(),
        settings: RouteSettings(arguments: invoice),
      ),
    );
  }

  // Métodos para crear facturas de ejemplo
  ERPInvoice _createMedicalInvoice() {
    return ERPInvoice(
      encf: 'E310000001234',
      tipoecf: '31',
      version: '1.0',
      fechaemision: '15/12/2024',
      numerofacturainterna: 'MED-2024-001234',

      // Emisor
      rncemisor: '123456789',
      razonsocialemisor: 'CENTRO MÉDICO EJEMPLO SRL',
      direccionemisor: 'Av. Sarasota No. 123, Bella Vista, Santo Domingo',
      telefonoemisor1: '809-555-0123',
      correoemisor: 'facturacion@centromedico.com',
      website: 'www.centromedico.com',

      // Comprador
      rnccomprador: '40212345678',
      razonsocialcomprador: 'JUAN CARLOS PÉREZ GONZÁLEZ',
      direccioncomprador: 'Calle Principal No. 456, Santiago',

      // Información médica
      aseguradora: 'ARS HUMANO',
      noAutorizacion: 'AUTH-789456123',
      nss: '12345678901',
      medico: 'Dr. María Elena Rodríguez',
      cedulaMedico: '001-1234567-8',
      tipoFacturaTitulo: 'ARS - CONSULTA ESPECIALIZADA',
      montoCobertura: '15000.00',

      // Montos
      montogravadototal: '20000.00',
      montoexento: '5000.00',
      totalitbis: '3600.00',
      montototal: '28600.00',

      // Detalles
      detalleFactura: '''[
        {
          "referencia": "CONS001",
          "descripcion": "Consulta cardiología especializada",
          "cantidad": 1,
          "precio": 8000.00,
          "total": 8000.00
        },
        {
          "referencia": "ECG001",
          "descripcion": "Electrocardiograma completo",
          "cantidad": 1,
          "precio": 3500.00,
          "total": 3500.00
        },
        {
          "referencia": "LAB001",
          "descripcion": "Perfil lipídico completo",
          "cantidad": 1,
          "precio": 4500.00,
          "total": 4500.00
        },
        {
          "referencia": "MED001",
          "descripcion": "Medicamento prescrito",
          "cantidad": 2,
          "precio": 2000.00,
          "total": 4000.00
        },
        {
          "referencia": "PROC001",
          "descripcion": "Procedimiento menor (exento)",
          "cantidad": 1,
          "precio": 5000.00,
          "total": 5000.00
        }
      ]''',
    );
  }

  ERPInvoice _createConsumerInvoice() {
    return ERPInvoice(
      encf: 'E320000005678',
      tipoecf: '32',
      version: '1.0',
      fechaemision: '15/12/2024',
      numerofacturainterna: 'CONS-2024-005678',

      // Emisor
      rncemisor: '987654321',
      razonsocialemisor: 'SUPERMERCADO EJEMPLO SRL',
      direccionemisor: 'Av. 27 de Febrero No. 789, Santo Domingo',
      telefonoemisor1: '809-555-0456',
      correoemisor: 'ventas@supermercado.com',

      // Comprador
      rnccomprador: '40298765432',
      razonsocialcomprador: 'ANA MARÍA LÓPEZ SANTOS',
      direccioncomprador: 'Calle Secundaria No. 321, La Vega',

      // Montos
      montogravadototal: '5000.00',
      montoexento: '1000.00',
      totalitbis: '900.00',
      montototal: '6900.00',

      // Detalles
      detalleFactura: '''[
        {
          "referencia": "PROD001",
          "descripcion": "Arroz blanco 5 lbs",
          "cantidad": 2,
          "precio": 450.00,
          "total": 900.00
        },
        {
          "referencia": "PROD002",
          "descripcion": "Aceite vegetal 1 litro",
          "cantidad": 3,
          "precio": 280.00,
          "total": 840.00
        },
        {
          "referencia": "PROD003",
          "descripcion": "Pollo entero fresco",
          "cantidad": 1,
          "precio": 650.00,
          "total": 650.00
        },
        {
          "referencia": "PROD004",
          "descripción": "Leche entera 1 litro",
          "cantidad": 4,
          "precio": 120.00,
          "total": 480.00
        },
        {
          "referencia": "PROD005",
          "descripcion": "Pan tostado integral",
          "cantidad": 2,
          "precio": 180.00,
          "total": 360.00
        },
        {
          "referencia": "PROD006",
          "descripcion": "Medicinas (exento)",
          "cantidad": 1,
          "precio": 1000.00,
          "total": 1000.00
        }
      ]''',
    );
  }

  ERPInvoice _createCreditNote() {
    return ERPInvoice(
      encf: 'E340000009012',
      tipoecf: '34',
      version: '1.0',
      fechaemision: '15/12/2024',
      numerofacturainterna: 'NC-2024-009012',

      // Emisor
      rncemisor: '456789123',
      razonsocialemisor: 'TIENDA ELECTRÓNICOS SRL',
      direccionemisor: 'Plaza Central, Local 45, Santiago',
      telefonoemisor1: '809-555-0789',
      correoemisor: 'devoluciones@electronicos.com',

      // Comprador
      rnccomprador: '40287654321',
      razonsocialcomprador: 'CARLOS ALBERTO MÉNDEZ',
      direccioncomprador: 'Av. Núñez de Cáceres No. 567, Santo Domingo',

      // Montos (negativos para nota de crédito)
      montogravadototal: '-15000.00',
      montoexento: '0.00',
      totalitbis: '-2700.00',
      montototal: '-17700.00',

      // Detalles
      detalleFactura: '''[
        {
          "referencia": "DEV001",
          "descripcion": "Devolución: Televisor LED 55 pulgadas",
          "cantidad": -1,
          "precio": 15000.00,
          "total": -15000.00
        }
      ]''',
    );
  }

  ERPInvoice _createMinorExpense() {
    return ERPInvoice(
      encf: 'E430000003456',
      tipoecf: '43',
      version: '1.0',
      fechaemision: '15/12/2024',
      numerofacturainterna: 'GM-2024-003456',

      // Emisor
      rncemisor: '789123456',
      razonsocialemisor: 'CAFETERÍA LA ESQUINA',
      direccionemisor: 'Calle El Conde No. 234, Zona Colonial',
      telefonoemisor1: '809-555-0234',

      // Comprador
      rnccomprador: '40276543210',
      razonsocialcomprador: 'EMPRESA CONSULTORA ABC SRL',
      direccioncomprador: 'Torre Empresarial, Piso 15, Piantini',

      // Montos
      montogravadototal: '800.00',
      montoexento: '0.00',
      totalitbis: '144.00',
      montototal: '944.00',

      // Detalles
      detalleFactura: '''[
        {
          "referencia": "CAF001",
          "descripcion": "Desayuno ejecutivo",
          "cantidad": 2,
          "precio": 250.00,
          "total": 500.00
        },
        {
          "referencia": "BEB001",
          "descripcion": "Café americano grande",
          "cantidad": 3,
          "precio": 100.00,
          "total": 300.00
        }
      ]''',
    );
  }
}

/// Widget de demostración para mostrar las mejoras
class InvoiceDetailComparisonDemo extends StatelessWidget {
  const InvoiceDetailComparisonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comparación: Antes vs Ahora')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Mejoras en la Pantalla de Detalles',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            Expanded(
              child: Row(
                children: [
                  // Antes
                  Expanded(
                    child: _buildComparisonCard(
                      context,
                      title: '❌ Antes',
                      color: Colors.red.shade100,
                      borderColor: Colors.red.shade300,
                      items: [
                        'Solo vista previa del PDF',
                        'Información limitada',
                        'Sin organización clara',
                        'Pocas opciones de acción',
                        'Diseño básico',
                        'No mostraba detalles médicos',
                        'Sin desglose de items',
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Ahora
                  Expanded(
                    child: _buildComparisonCard(
                      context,
                      title: '✅ Ahora',
                      color: Colors.green.shade100,
                      borderColor: Colors.green.shade300,
                      items: [
                        '3 pestañas organizadas',
                        'Información completa y detallada',
                        'Header con estado visual',
                        'Múltiples opciones de acción',
                        'Diseño moderno y profesional',
                        'Sección médica especializada',
                        'Lista completa de items',
                        'Floating action buttons',
                        'Integración con vista previa mejorada',
                      ],
                    ),
                  ),
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
                    builder: (context) => const InvoiceDetailUsageExample(),
                  ),
                ),
                icon: const Icon(Icons.visibility),
                label: const Text('Probar Ejemplos'),
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

  Widget _buildComparisonCard(
    BuildContext context, {
    required String title,
    required Color color,
    required Color borderColor,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        items[index],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
