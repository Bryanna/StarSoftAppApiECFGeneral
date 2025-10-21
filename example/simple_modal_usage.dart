import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../lib/models/erp_invoice.dart';
import '../lib/widgets/simple_invoice_modal.dart';

/// Ejemplo de uso del modal simple de vista previa de facturas
///
/// Este modal combina lo mejor de ambos mundos:
/// - Modal grande como la vista previa mejorada (95% de la pantalla)
/// - Descarga DIRECTA sin abrir otra pantalla
/// - PDF grande y claro
/// - Interfaz simple y enfocada
class SimpleModalUsageExample extends StatelessWidget {
  const SimpleModalUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modal Simple - Ejemplo'),
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
              'Modal Simple de Vista Previa',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              'Combina lo mejor de ambos mundos: modal grande + descarga directa.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Características principales
            _buildFeaturesList(),
            const SizedBox(height: 32),

            // Botones de ejemplo
            _buildExampleButtons(context),

            const SizedBox(height: 32),

            // Comparación
            _buildComparison(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      '📱 Modal ocupa 95% de la pantalla',
      '📄 PDF grande y claro sin zoom',
      '📥 Descarga DIRECTA sin abrir otra pantalla',
      '🖨️ Impresión directa integrada',
      '🎨 Header con información de la factura',
      '📋 Nombre de archivo formato RNC+ENCF.pdf',
      '❌ Botón cerrar fácil acceso',
      '🚀 Interfaz limpia y enfocada',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Características del Modal:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...features
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
      ],
    );
  }

  Widget _buildExampleButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Probar Modal con Diferentes Facturas:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Factura médica
            ElevatedButton.icon(
              onPressed: () => _showModalExample(
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
              onPressed: () => _showModalExample(
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
              onPressed: () => _showModalExample(
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
            'Comparación de Opciones',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Tabla de comparación
          Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              // Header
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Característica',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Pantalla',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Modal Complejo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Modal Simple',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Filas de datos
              _buildTableRow('Tamaño', '100%', '95%', '95%'),
              _buildTableRow('Navegación', 'Nueva pantalla', 'Modal', 'Modal'),
              _buildTableRow('Descarga', 'Abre visor', 'Abre visor', 'Directa'),
              _buildTableRow('Complejidad', 'Media', 'Alta', 'Baja'),
              _buildTableRow('Velocidad', 'Media', 'Media', 'Rápida'),
              _buildTableRow('UX', 'Buena', 'Completa', 'Excelente'),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(
    String feature,
    String pantalla,
    String complejo,
    String simple,
  ) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8), child: Text(feature)),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(pantalla, style: const TextStyle(fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(complejo, style: const TextStyle(fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            simple,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ),
      ],
    );
  }

  void _showModalExample(BuildContext context, ERPInvoice invoice) {
    showSimpleInvoiceModal(context: context, invoice: invoice);
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
      razonsocialemisor: isMedical
          ? 'CENTRO MÉDICO EJEMPLO SRL'
          : 'EMPRESA EJEMPLO SRL',
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
      detalleFactura:
          '''[
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

/// Widget de demostración para mostrar las ventajas del modal
class ModalAdvantagesDemo extends StatelessWidget {
  const ModalAdvantagesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventajas del Modal Simple')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Modal Simple: Lo Mejor de Ambos Mundos',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Ventajas principales
            Expanded(
              child: ListView(
                children: [
                  _buildAdvantageCard(
                    icon: Icons.speed,
                    title: 'Descarga Directa',
                    description:
                        'El botón de descarga funciona inmediatamente sin abrir otra pantalla. Un solo clic y el archivo se descarga.',
                    color: Colors.green,
                  ),

                  _buildAdvantageCard(
                    icon: Icons.fullscreen,
                    title: 'PDF Grande',
                    description:
                        'El PDF ocupa 95% de la pantalla, permitiendo ver todos los detalles claramente sin necesidad de zoom.',
                    color: Colors.blue,
                  ),

                  _buildAdvantageCard(
                    icon: Icons.layers,
                    title: 'Modal vs Pantalla',
                    description:
                        'Al ser un modal, no pierdes el contexto de donde venías. Fácil cerrar y continuar trabajando.',
                    color: Colors.purple,
                  ),

                  _buildAdvantageCard(
                    icon: Icons.cleaning_services,
                    title: 'Interfaz Limpia',
                    description:
                        'Solo lo esencial: PDF grande, botón de descarga directa e impresión. Sin distracciones.',
                    color: Colors.orange,
                  ),

                  _buildAdvantageCard(
                    icon: Icons.file_present,
                    title: 'Nombre Correcto',
                    description:
                        'Los archivos se nombran automáticamente con el formato RNC+ENCF.pdf para fácil identificación.',
                    color: Colors.teal,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botón para probar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SimpleModalUsageExample(),
                  ),
                ),
                icon: const Icon(Icons.visibility),
                label: const Text('Probar Modal Simple'),
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

  Widget _buildAdvantageCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
