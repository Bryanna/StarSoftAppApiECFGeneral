import 'package:flutter/material.dart';
import '../models/ui_types.dart';

class StatusChip extends StatelessWidget {
  final DisplayStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (bg, fg, label) = switch (status) {
      DisplayStatus.pendiente => (
        cs.surfaceContainerHighest,
        cs.onSurfaceVariant,
        'Pendiente',
      ),
      DisplayStatus.enviado => (
        cs.secondaryContainer,
        cs.onSecondaryContainer,
        'Enviado',
      ),
      DisplayStatus.aprobada => (
        cs.primaryContainer,
        cs.onPrimaryContainer,
        'Aprobada',
      ),
      DisplayStatus.rechazada => (
        cs.errorContainer,
        cs.onErrorContainer,
        'Rechazada',
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12)),
    );
  }
}
