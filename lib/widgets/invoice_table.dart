import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../models/ui_types.dart';
import '../models/tipo_comprobante.dart';
import 'status_chip.dart';

typedef InvoiceCallback = void Function(Datum invoice);

class InvoiceTable extends StatelessWidget {
  final List<Datum> invoices;
  final InvoiceCallback onView;
  final InvoiceCallback onSend;
  final InvoiceCallback onDownload;

  const InvoiceTable({
    super.key,
    required this.invoices,
    required this.onView,
    required this.onSend,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    // Para PC siempre mostramos tabla (grid) sin cards
    return _wideTable(context);
  }

  Widget _wideTable(BuildContext context) {
    // Usamos Table con FlexColumnWidth para ocupar 100% del ancho
    return LayoutBuilder(
      builder: (context, constraints) {
        final sorted = _sortedBySecuencia(invoices);
        final columnWidths = <int, TableColumnWidth>{
          0: const FlexColumnWidth(1.2), // eCF
          1: const FlexColumnWidth(1.0), // Código Interno
          2: const FlexColumnWidth(2.0), // Razón Social Comprador
          3: const FlexColumnWidth(1.0), // (Vacío - era ARS)
          4: const FlexColumnWidth(1.1), // Monto
          5: const FlexColumnWidth(1.0), // Fecha
          6: const FlexColumnWidth(1.2), // RNC
          7: const FlexColumnWidth(1.2), // Tipo Comprobante
          8: const FlexColumnWidth(1.0), // Estado
          9: const FlexColumnWidth(1.0), // Acciones
        };

        Widget headerCell(String text) => Container(
          color: const Color(0xFF005285),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        );

        Widget bodyCell(Widget child) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: child,
        );

        return Column(
          children: [
            // Header fijo (sticky)
            SizedBox(
              width: constraints.maxWidth,
              child: Table(
                columnWidths: columnWidths,
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                children: [
                  TableRow(
                    children: [
                      headerCell('eCF'),
                      headerCell('Código'),
                      headerCell('Razón Social'),
                      headerCell(''), // Columna vacía
                      headerCell('Monto'),
                      headerCell('Fecha'),
                      headerCell('RNC'),
                      headerCell('Tipo'),
                      headerCell('Estado'),
                      headerCell('Acciones'),
                    ],
                  ),
                ],
              ),
            ),
            // Body scrollable
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: Table(
                    columnWidths: columnWidths,
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    children: [
                      for (final inv in sorted)
                        TableRow(
                          children: [
                            bodyCell(Text(_getDocumento(inv))),
                            bodyCell(Text(_getCodigoInternoComprador(inv))),
                            bodyCell(Text(_getRazonSocialComprador(inv))),
                            bodyCell(Text('')), // ARS no existe en JSON real
                            bodyCell(Text(_formatMonto(_getMontoTotal(inv)))),
                            bodyCell(Text(_getFechaEmision(inv))),
                            bodyCell(Text(_getRNCComprador(inv))),
                            bodyCell(_typeChip(_tipoComprobanteAlias(inv))),
                            bodyCell(StatusChip(status: _statusFrom(inv))),
                            bodyCell(_ActionsMenu(inv)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cardList(BuildContext context) {
    final sorted = _sortedBySecuencia(invoices);
    return ListView.separated(
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final inv = sorted[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getDocumento(inv),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    _ActionsMenu(inv),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _kv('Fecha', _getFechaEmision(inv)),
                    _kv('Comprador', _getRazonSocialComprador(inv)),
                    _kv('RNC', _getRNCComprador(inv)),
                    _kv('Comprobante', _tipoComprobanteAlias(inv)),
                    _kv('Monto', _formatMonto(_getMontoTotal(inv))),
                    Row(
                      children: [
                        const Text('Estado: '),
                        StatusChip(status: _statusFrom(inv)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Datum> _sortedBySecuencia(List<Datum> list) {
    final copy = List<Datum>.from(list);
    copy.sort((a, b) {
      final ai = a.fFacturaSecuencia ?? 0;
      final bi = b.fFacturaSecuencia ?? 0;
      return ai.compareTo(bi);
    });
    return copy;
  }

  Widget _kv(String k, String v) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$k: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(v),
      ],
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _formatMonto(String monto) {
    final s = monto.trim();
    if (s.isEmpty) return '';

    // Normaliza posibles formatos: quita símbolos y maneja coma como decimal
    var cleaned = s.replaceAll(RegExp(r'[^0-9,.-]'), '');
    if (cleaned.contains(',') && !cleaned.contains('.')) {
      cleaned = cleaned.replaceAll('.', '');
      cleaned = cleaned.replaceAll(',', '.');
    } else {
      cleaned = cleaned.replaceAll(',', '');
    }

    double? value;
    try {
      value = double.parse(cleaned);
    } catch (_) {
      return s; // Si no parsea, regresa tal cual
    }

    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(value);
  }

  DisplayStatus _statusFrom(Datum inv) {
    if (inv.fAnulada == true) return DisplayStatus.rechazada;
    if (inv.fPagada == true) return DisplayStatus.aprobada;
    final enviado =
        (inv.linkOriginal != null && inv.linkOriginal!.isNotEmpty) ||
        inv.fechaHoraFirma != null;
    if (enviado) return DisplayStatus.enviado;
    return DisplayStatus.pendiente;
  }

  // Métodos para extraer datos del JSON real
  String _getDocumento(Datum inv) {
    // Usar ENCF del JSON como documento principal
    return inv.encf ?? inv.fDocumento ?? '';
  }

  String _getCodigoInternoComprador(Datum inv) {
    // Usar CodigoInternoComprador del JSON como ID del paciente
    return ''; // Este campo no siempre existe, dejarlo vacío
  }

  String _getRazonSocialComprador(Datum inv) {
    // Usar RazonSocialComprador del JSON como nombre del paciente
    return inv.razonsocialcomprador?.toString() ?? '';
  }

  String _getMontoTotal(Datum inv) {
    // Usar MontoTotal del JSON
    return inv.montototal ?? '';
  }

  String _getFechaEmision(Datum inv) {
    // Formatear fecha de emisión
    if (inv.fechaemision != null) {
      return _formatDate(inv.fechaemision!);
    }
    return '';
  }

  String _getRNCComprador(Datum inv) {
    // Usar RNCComprador del JSON
    return inv.rnccomprador ?? '';
  }

  String _tipoComprobanteAlias(Datum inv) {
    // Usar ENCF para determinar el tipo
    final encf = inv.encf ?? inv.fDocumento ?? '';
    final alias = aliasDesdeDocumento(encf);
    return alias ?? '';
  }

  Widget _typeChip(String alias) {
    final (bg, fg) = switch (alias) {
      'Consumo' => (
        const Color(0xFFFFE5D9),
        const Color(0xFF6B4E4E),
      ), // Rosa pastel melocotón
      'Crédito Fiscal' => (
        const Color(0xFFD9F8FF),
        const Color(0xFF2E5D6E),
      ), // Azul pastel agua
      'Nota Crédito' => (
        const Color(0xFFFFD9E8),
        const Color(0xFF6B3B53),
      ), // Rosado empolvado
      'Nota Débito' => (
        const Color(0xFFE5FFD9),
        const Color(0xFF3F6B42),
      ), // Verde menta
      'Gastos Menores' => (
        const Color(0xFFF9F5D7),
        const Color(0xFF6E6232),
      ), // Amarillo crema pastel
      'Factura Gubernamental' => (
        const Color(0xFFE6E5FF),
        const Color(0xFF403B6B),
      ), // Lila suave
      'Factura Regímenes Especiales' => (
        const Color(0xFFFFEED9),
        const Color(0xFF6B533B),
      ), // Durazno claro
      'Pagos al Exterior' => (
        const Color(0xFFE5F0FF),
        const Color(0xFF2E4A6B),
      ), // Azul cielo
      'Regímenes Especiales' => (
        const Color(0xFFEFFFD9),
        const Color(0xFF4A6B2E),
      ), // Verde lima
      'Exportación' => (
        const Color(0xFFFFF0D9),
        const Color(0xFF6B5C2E),
      ), // Amarillo suave
      'Pagos Electrónicos' => (
        const Color(0xFFD9E8FF),
        const Color(0xFF2E4A6B),
      ), // Azul bebé
      'Donaciones' => (
        const Color(0xFFF9D9FF),
        const Color(0xFF5B2E6B),
      ), // Lila rosado
      'Bonos o Incentivos' => (
        const Color(0xFFD9FFF7),
        const Color(0xFF2E6B5A),
      ), // Verde agua
      'Venta por Terceros' => (
        const Color(0xFFE5E9FF),
        const Color(0xFF343A6B),
      ), // Azul lavanda
      'Gasto Gubernamental' => (
        const Color(0xFFFFF7D9),
        const Color(0xFF6B5D2E),
      ), // Amarillo arena
      'Compras Gubernamentales' => (
        const Color(0xFFE9FFF0),
        const Color(0xFF3C6B4A),
      ), // Verde menta suave
      _ => (
        const Color(0xFFF0F4F6),
        const Color(0xFF4C4C4C),
      ), // Gris claro por defecto
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(alias, style: TextStyle(color: fg, fontSize: 12)),
    );
  }

  Widget _ActionsMenu(Datum invoice) {
    Widget btn(
      IconData icon,
      String tooltip,
      Color color,
      VoidCallback onPressed,
    ) {
      return IconButton(
        tooltip: tooltip,
        icon: FaIcon(icon, color: color),
        iconSize: 18,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(
          FontAwesomeIcons.eye,
          'Ver detalles',
          const Color(0xFF005285),
          () => onView(invoice),
        ),
        const SizedBox(width: 6),
        btn(
          FontAwesomeIcons.paperPlane,
          'Enviar',
          const Color(0xFF0072CE),
          () => onSend(invoice),
        ),
        const SizedBox(width: 6),
        btn(
          FontAwesomeIcons.download,
          'Descargar',
          const Color(0xFF005285),
          () => onDownload(invoice),
        ),
      ],
    );
  }
}
