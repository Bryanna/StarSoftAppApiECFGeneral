import 'package:flutter/material.dart';

/// Ejemplo visual de cómo se ven los tabs generados automáticamente
/// basados en el campo tipo_tab_envio_factura del endpoint ERP

class TabsResultadoFinalScreen extends StatelessWidget {
  const TabsResultadoFinalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado Final: Tabs Dinámicos'),
        backgroundColor: const Color(0xFF005285),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Simulación de los tabs generados
          Container(
            height: 60,
            color: Colors.grey[100],
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _TabChip(
                  icon: '📋',
                  label: 'Todos',
                  count: 15,
                  isSelected: true,
                ),
                _TabChip(
                  icon: '🏥',
                  label: 'Factura Ars',
                  count: 8,
                  isSelected: false,
                ),
                _TabChip(
                  icon: '🛒',
                  label: 'Factura Consumo',
                  count: 4,
                ),
                _TabChip(
                  icon: '📉',
                  label: 'Nota Credito',
                  count: 2,
                ),
                _TabChip(
                  icon: '💸',
                  label: 'Gasto Menor',
                  count: 1,
                ),
              ],
            ),
          ),

          // Contenido de ejemplo
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoCard(),
                  const SizedBox(height: 16),
                  _ExampleFacturas(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String icon;
  final String label;
  final int count;
  final bool isSelected;

  const _TabChip({
    required this.icon,
    required this.label,
    required this.count,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Material(
        color: isSelected ? const Color(0xFF005285) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        elevation: isSelected ? 2 : 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  '¡Tabs Generados Automáticamente!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'El sistema analizó el campo "tipo_tab_envio_factura" de tus facturas y generó automáticamente estos tabs:',
              style: TextStyle(color: Colors.green[700]),
            ),
            const SizedBox(height: 8),

            _GeneratedTabInfo(
              original: '"FacturaArs"',
              generated: '🏥 Factura Ars (8)',
            ),
            _GeneratedTabInfo(
              original: '"FacturaConsumo"',
              generated: '🛒 Factura Consumo (4)',
            ),
            _GeneratedTabInfo(
              original: '"NotaCredito"',
              generated: '📉 Nota Credito (2)',
            ),
            _GeneratedTabInfo(
              original: '"GastoMenor"',
              generated: '💸 Gasto Menor (1)',
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedTabInfo extends StatelessWidget {
  final String original;
  final String generated;

  const _GeneratedTabInfo({
    required this.original,
    required this.generated,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              original,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 12),
          const SizedBox(width: 8),
          Text(
            generated,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _ExampleFacturas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Facturas en el Tab Seleccionado: "Todos"',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _FacturaItem(
              encf: 'E31000000123',
              tipo: 'FacturaArs',
              cliente: 'ARS Salud Segura',
              monto: 2500.00,
            ),
            _FacturaItem(
              encf: 'E32000000124',
              tipo: 'FacturaConsumo',
              cliente: 'Juan Pérez',
              monto: 850.00,
            ),
            _FacturaItem(
              encf: 'E34000000125',
              tipo: 'NotaCredito',
              cliente: 'María González',
              monto: -300.00,
            ),
            _FacturaItem(
              encf: 'E43000000126',
              tipo: 'GastoMenor',
              cliente: 'Oficina Central',
              monto: 125.00,
            ),
          ],
        ),
      ),
    );
  }
}

class _FacturaItem extends StatelessWidget {
  final String encf;
  final String tipo;
  final String cliente;
  final double monto;

  const _FacturaItem({
    required this.encf,
    required this.tipo,
    required this.cliente,
    required this.monto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTipoColor(tipo),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatTipo(tipo),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  encf,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  cliente,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${monto.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: monto >= 0 ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'FacturaArs':
        return Colors.blue;
      case 'FacturaConsumo':
        return Colors.green;
      case 'NotaCredito':
        return Colors.orange;
      case 'GastoMenor':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatTipo(String tipo) {
    // Simular el formateo que hace el servicio
    switch (tipo) {
      case 'FacturaArs':
        return 'ARS';
      case 'FacturaConsumo':
        return 'CONSUMO';
      case 'NotaCredito':
        return 'N.CREDITO';
      case 'GastoMenor':
        return 'GASTO';
      default:
        return tipo.toUpperCase();
    }
  }
}
