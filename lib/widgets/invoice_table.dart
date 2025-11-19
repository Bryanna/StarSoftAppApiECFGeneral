import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../models/erp_invoice.dart';
import '../models/erp_invoice_extensions.dart';
import '../models/ui_types.dart';
import 'status_chip.dart';

typedef InvoiceCallback = void Function(ERPInvoice invoice);
typedef SelectionCallback = void Function(String encf);
typedef SelectAllCallback = void Function();
typedef IsSelectedCallback = bool Function(String? encf);

class InvoiceTable extends StatelessWidget {
  final List<ERPInvoice> invoices;
  final InvoiceCallback? onView;
  final InvoiceCallback onSend;
  final InvoiceCallback? onPreview;
  final InvoiceCallback? onPrint80mm; // Nuevo: Impresión 80mm
  final InvoiceCallback? onPreviewArsHeader;
  final InvoiceCallback? onPreviewArsDetail;
  final SelectionCallback? onToggleSelection;
  final SelectAllCallback? onToggleSelectAll;
  final IsSelectedCallback? isSelected;
  final bool? isAllSelected;
  final bool isArsTab;

  const InvoiceTable({
    super.key,
    required this.invoices,
    required this.onView,
    required this.onSend,
    this.onPreview,
    this.onPrint80mm, // Nuevo: Impresión 80mm
    this.onPreviewArsHeader,
    this.onPreviewArsDetail,
    this.onToggleSelection,
    this.onToggleSelectAll,
    this.isSelected,
    this.isAllSelected,
    this.isArsTab = false,
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
        final hasSelection = onToggleSelection != null;
        final columnWidths = <int, TableColumnWidth>{
          if (hasSelection) 0: const FixedColumnWidth(50), // Checkbox
          if (hasSelection)
            1: const FlexColumnWidth(1.2)
          else
            0: const FlexColumnWidth(1.2), // eCF
          if (hasSelection)
            2: const FlexColumnWidth(1.0)
          else
            1: const FlexColumnWidth(1.0), // Código Interno
          if (hasSelection)
            3: const FlexColumnWidth(2.0)
          else
            2: const FlexColumnWidth(2.0), // Razón Social Comprador
          if (hasSelection)
            4: const FlexColumnWidth(1.1)
          else
            3: const FlexColumnWidth(1.1), // Monto
          if (hasSelection)
            5: const FlexColumnWidth(1.0)
          else
            4: const FlexColumnWidth(1.0), // Fecha
          if (hasSelection)
            6: const FlexColumnWidth(1.2)
          else
            5: const FlexColumnWidth(1.2), // Tipo Comprobante
          if (hasSelection)
            7: const FlexColumnWidth(1.0)
          else
            6: const FlexColumnWidth(1.0), // Estado
          if (hasSelection)
            8: const FlexColumnWidth(1.0)
          else
            7: const FlexColumnWidth(1.0), // Acciones
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
                      if (hasSelection)
                        Container(
                          color: const Color(0xFF005285),
                          height: 40,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Transform.scale(
                            scale: 0.85,
                            child: Checkbox(
                              value: isAllSelected ?? false,
                              onChanged: (_) => onToggleSelectAll?.call(),
                              fillColor: WidgetStateProperty.all(Colors.white),
                              checkColor: const Color(0xFF005285),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      headerCell('ENCF'),
                      headerCell('Código'),
                      headerCell('Razón Social'),
                      headerCell('Monto'),
                      headerCell('Fecha'),
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
                            if (hasSelection)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                child: Transform.scale(
                                  scale: 0.9,
                                  child: Checkbox(
                                    value: isSelected?.call(inv.encf) ?? false,
                                    onChanged: inv.encf != null
                                        ? (_) =>
                                              onToggleSelection?.call(inv.encf!)
                                        : null,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ),
                            bodyCell(Text(_getDocumento(inv))),
                            bodyCell(Text(_getCodigoInterno(inv))),
                            bodyCell(Text(_getRazonSocialComprador(inv))),
                            bodyCell(Text(_formatMonto(_getMontoTotal(inv)))),
                            bodyCell(Text(_getFechaEmision(inv))),
                            bodyCell(_typeCell(context, inv)),
                            bodyCell(StatusChip(status: _statusFrom(inv))),
                            bodyCell(_actionsMenu(inv)),
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

  List<ERPInvoice> _sortedBySecuencia(List<ERPInvoice> list) {
    final copy = List<ERPInvoice>.from(list);
    copy.sort((a, b) {
      final ai = a.fFacturaSecuencia ?? 0;
      final bi = b.fFacturaSecuencia ?? 0;
      return ai.compareTo(bi);
    });
    return copy;
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

  DisplayStatus _statusFrom(ERPInvoice inv) {
    // Priorizar el estado del endpoint (1: Pendiente, 2: Rechazado, 3: Enviado)
    final code = inv.estadoCode;
    if (code != null) {
      switch (code) {
        case 1:
          return DisplayStatus.pendiente;
        case 2:
          return DisplayStatus.rechazada;
        case 3:
          return DisplayStatus.enviado;
      }
    }

    // Fallback al comportamiento anterior si no viene el estado
    if (inv.fAnulada == true) return DisplayStatus.rechazada;
    if (inv.fPagada == true) return DisplayStatus.aprobada;
    final enviado =
        (inv.linkOriginal != null && inv.linkOriginal!.isNotEmpty) ||
        inv.fechaHoraFirma != null;
    if (enviado) return DisplayStatus.enviado;
    return DisplayStatus.pendiente;
  }

  // Métodos para extraer datos del JSON real
  String _getDocumento(ERPInvoice inv) {
    // Usar el numeroFactura que ya maneja la lógica de fallback
    return inv.numeroFactura;
  }

  String _getCodigoInterno(ERPInvoice inv) {
    // Usar numerofacturainterna del ERP
    return inv.numerofacturainterna ?? '';
  }

  String _getRazonSocialComprador(ERPInvoice inv) {
    // Usar clienteNombre que ya maneja la lógica de fallback
    return inv.clienteNombre;
  }

  String _getMontoTotal(ERPInvoice inv) {
    // Usar el formateador integrado de ERPInvoice
    return inv.formattedTotal;
  }

  String _getFechaEmision(ERPInvoice inv) {
    // Usar el formateador integrado de ERPInvoice
    return inv.formattedFechaEmision;
  }

  Widget _typeChip(BuildContext context, ERPInvoice invoice) {
    final colors = invoice.tipoComprobanteColors;
    final alias = invoice.tipoComprobanteDisplay;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.borderColor, width: 1),
      ),
      child: Text(
        alias,
        style: TextStyle(
          color: colors.textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Badge extra para distinguir ARS vs Paciente en el tab TODOS
  Widget _arsPacienteBadge(ERPInvoice invoice) {
    final isArs = _isArsInvoice(invoice);
    final isPaciente = _isPacienteInvoice(invoice);
    if (!isArs && !isPaciente) return const SizedBox.shrink();

    final label = isArs ? 'ARS' : 'Paciente';
    final bg = isArs ? const Color(0xFFEDE7F6) : const Color(0xFFE0F7FA);
    final border = isArs ? const Color(0xFF6f42c1) : const Color(0xFF0072CE);
    final text = isArs ? const Color(0xFF6f42c1) : const Color(0xFF005285);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Componente combinado para la columna Tipo
  Widget _typeCell(BuildContext context, ERPInvoice invoice) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: _typeChip(context, invoice)),
        const SizedBox(width: 6),
        _arsPacienteBadge(invoice),
      ],
    );
  }

  bool _isArsInvoice(ERPInvoice invoice) {
    // Usar exclusivamente el campo del endpoint
    final raw = invoice.tipoTabEnvioFactura?.trim();
    if (raw == null || raw.isEmpty) return false;
    final lower = raw.toLowerCase().replaceAll(' ', '');
    return lower == 'facturaars';
  }


  // Detección de Paciente usando exclusivamente el campo del endpoint
  bool _isPacienteInvoice(ERPInvoice invoice) {

    final raw = invoice.tipoTabEnvioFactura?.trim();
    if (raw == null || raw.isEmpty) return false;
    final lower = raw.toLowerCase().replaceAll(' ', '');
    return lower == 'facturapaciente';
  }

  Widget _actionsMenu(ERPInvoice invoice) {
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

    final isArs = _isArsInvoice(invoice);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Ver detalles" solo para facturas NO ARS
        // Oculto en tab ARS y también por fila si es ARS
        if (onView != null && !isArs && !isArsTab) ...[
          btn(
            FontAwesomeIcons.eye,
            'Ver detalles',
            const Color(0xFF005285),
            () => onView!(invoice),
          ),
        ],
        const SizedBox(width: 8),
        btn(
          FontAwesomeIcons.paperPlane,
          'Enviar',
          const Color(0xFF0072CE),
          () => onSend(invoice),
        ),
        if (onPreview != null) ...[
          const SizedBox(width: 8),
          btn(
            FontAwesomeIcons.magnifyingGlass,
            'Vista previa',
            const Color(0xFF28a745),
            () => onPreview!(invoice),
          ),
        ],
        // Botón de impresión 80mm
        if (onPrint80mm != null) ...[
          const SizedBox(width: 8),
          btn(
            FontAwesomeIcons.receipt,
            'Imprimir 80mm',
            const Color(0xFFFF6F00),
            () => onPrint80mm!(invoice),
          ),
        ],
        // Acciones ARS solo visibles si la factura es ARS
        if (onPreviewArsHeader != null && isArs) ...[
          const SizedBox(width: 8),
          btn(
            FontAwesomeIcons.idBadge,
            'Encabezado ARS',
            const Color(0xFF6f42c1),
            () => onPreviewArsHeader!(invoice),
          ),
        ],
        if (onPreviewArsDetail != null && isArs) ...[
          const SizedBox(width: 8),
          btn(
            FontAwesomeIcons.tableCellsLarge,
            'Detalle ARS',
            const Color(0xFF9c27b0),
            () => onPreviewArsDetail!(invoice),
          ),
        ],
      ],
    );
  }
}
