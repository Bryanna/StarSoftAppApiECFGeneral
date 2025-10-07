import 'package:flutter/material.dart';
import '../models/ui_types.dart';

class StatusChip extends StatelessWidget {
  final DisplayStatus status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, label) = switch (status) {
      DisplayStatus.pendiente => (const Color(0xFFf0f4f6), 'Pendiente'),
      DisplayStatus.enviado => (const Color(0xFF0072CE), 'Enviado'),
      DisplayStatus.aprobada => (const Color(0xFF005285), 'Aprobada'),
      DisplayStatus.rechazada => (const Color(0xFFdd1416), 'Rechazada'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: label == 'Pendiente' ? Colors.black : Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
