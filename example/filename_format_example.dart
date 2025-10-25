import 'package:flutter/material.dart';
import '../lib/models/erp_invoice.dart';

/// Ejemplo que muestra el nuevo formato de nombres de archivo RNC+ENCF.pdf
///
/// Este ejemplo demuestra cómo se generan los nombres de archivo
/// usando el formato RNC del emisor + ENCF de la factura
class FilenameFormatExample extends StatelessWidget {
  const FilenameFormatExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formato de Nombres - RNC+ENCF.pdf'),
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
              'Nuevo Formato de Nombres de Archivo',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(
              'Los archivos PDF ahora se nombran usando el formato: RNC del emisor + ENCF de la factura',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Formato explicado
            _buildFormatExplanation(context),
            const SizedBox(height: 32),

            // Ejemplos de nombres
            _buildExamples(context),

            const SizedBox(height: 32),

            // Casos especiales
            _buildSpecialCases(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatExplanation(BuildContext context) {
    return Container(
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
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Formato del Nombre de Archivo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Fórmula
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'RNC_EMISOR + ENCF + .pdf',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Explicación de componentes
          const Text('Donde:'),
          const SizedBox(height: 8),
          _buildComponent(
            'RNC_EMISOR',
            'RNC de la empresa que emite la factura',
          ),
          _buildComponent('ENCF', 'Número de Comprobante Fiscal Electrónico'),
          _buildComponent('.pdf', 'Extensión del archivo PDF'),
        ],
      ),
    );
  }

  Widget _buildComponent(String component, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Text(
            '$component: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }

  Widget _buildExamples(BuildContext context) {
    final examples = [
      _ExampleInvoice(
        rncEmisor: '123456789',
        encf: 'E310000001234',
        tipoFactura: 'Factura Médica (Crédito Fiscal)',
        expectedFilename: '123456789E310000001234.pdf',
      ),
      _ExampleInvoice(
        rncEmisor: '987654321',
        encf: 'E320000005678',
        tipoFactura: 'Factura de Consumo',
        expectedFilename: '987654321E320000005678.pdf',
      ),
      _ExampleInvoice(
        rncEmisor: '456789123',
        encf: 'E340000009012',
        tipoFactura: 'Nota de Crédito',
        expectedFilename: '456789123E340000009012.pdf',
      ),
      _ExampleInvoice(
        rncEmisor: '789123456',
        encf: 'E430000003456',
        tipoFactura: 'Gastos Menores',
        expectedFilename: '789123456E430000003456.pdf',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ejemplos de Nombres Generados',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        ...examples.map((example) => _buildExampleCard(example)),
      ],
    );
  }

  Widget _buildExampleCard(_ExampleInvoice example) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo de factura
          Text(
            example.tipoFactura,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),

          // Datos de entrada
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RNC Emisor: ${example.rncEmisor}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'ENCF: ${example.encf}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Resultado
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.file_present,
                  color: Colors.green.shade700,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    example.expectedFilename,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialCases(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Casos Especiales',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Manejo de Datos Faltantes',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildSpecialCase(
                'Sin RNC Emisor',
                'SIN_RNC + ENCF + .pdf',
                'SIN_RNCE310000001234.pdf',
              ),

              _buildSpecialCase(
                'Sin ENCF',
                'RNC_EMISOR + SIN_ENCF + .pdf',
                '123456789SIN_ENCF.pdf',
              ),

              _buildSpecialCase(
                'Sin RNC ni ENCF',
                'SIN_RNC + SIN_ENCF + .pdf',
                'SIN_RNCSIN_ENCF.pdf',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialCase(String caso, String formato, String ejemplo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• $caso:', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Formato: $formato',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  'Ejemplo: $ejemplo',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleInvoice {
  final String rncEmisor;
  final String encf;
  final String tipoFactura;
  final String expectedFilename;

  const _ExampleInvoice({
    required this.rncEmisor,
    required this.encf,
    required this.tipoFactura,
    required this.expectedFilename,
  });
}

/// Widget de demostración para probar el formato
class FilenameFormatDemo extends StatelessWidget {
  const FilenameFormatDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo: Formato de Nombres')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Generador de Nombres de Archivo',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            Text(
              'Ingresa los datos para ver cómo se genera el nombre del archivo',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Formulario simple
            const _FilenameGenerator(),

            const SizedBox(height: 32),

            // Botón para ver ejemplos
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FilenameFormatExample(),
                  ),
                ),
                icon: const Icon(Icons.visibility),
                label: const Text('Ver Ejemplos Completos'),
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

class _FilenameGenerator extends StatefulWidget {
  const _FilenameGenerator();

  @override
  State<_FilenameGenerator> createState() => _FilenameGeneratorState();
}

class _FilenameGeneratorState extends State<_FilenameGenerator> {
  final _rncController = TextEditingController();
  final _encfController = TextEditingController();
  String _generatedFilename = '';

  @override
  void initState() {
    super.initState();
    _rncController.addListener(_generateFilename);
    _encfController.addListener(_generateFilename);
  }

  @override
  void dispose() {
    _rncController.dispose();
    _encfController.dispose();
    super.dispose();
  }

  void _generateFilename() {
    final rnc = _rncController.text.trim().isEmpty
        ? 'SIN_RNC'
        : _rncController.text.trim();
    final encf = _encfController.text.trim().isEmpty
        ? 'SIN_ENCF'
        : _encfController.text.trim();

    setState(() {
      _generatedFilename = '$rnc$encf.pdf';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo RNC
        TextField(
          controller: _rncController,
          decoration: const InputDecoration(
            labelText: 'RNC del Emisor',
            hintText: 'Ej: 123456789',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Campo ENCF
        TextField(
          controller: _encfController,
          decoration: const InputDecoration(
            labelText: 'ENCF de la Factura',
            hintText: 'Ej: E310000001234',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),

        // Resultado
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nombre de Archivo Generado:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _generatedFilename.isEmpty
                    ? 'SIN_RNCSIN_ENCF.pdf'
                    : _generatedFilename,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
