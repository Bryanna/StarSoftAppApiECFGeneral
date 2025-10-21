import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dynamic_home_controller.dart';
import '../services/dynamic_tabs_service.dart';

/// Widget que muestra tabs dinámicos basados en los tipos de ENCF encontrados
class DynamicTabsBar extends StatelessWidget {
  final bool isWide;

  const DynamicTabsBar({super.key, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DynamicHomeController>(
      builder: (controller) {
        if (controller.dynamicTabs.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tab in controller.dynamicTabs)
                _DynamicTabChip(
                  tab: tab,
                  isSelected: controller.currentTab?.id == tab.id,
                  onTap: () => controller.selectTab(tab),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DynamicTabChip extends StatelessWidget {
  final DynamicTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _DynamicTabChip({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRejected = tab.id == 'rechazados';

    return ChoiceChip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      selectedColor: isRejected
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.primaryContainer,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: StadiumBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono del tipo
          Text(tab.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          // Etiqueta
          Text(
            tab.label,
            style: TextStyle(
              color: isSelected
                  ? (isRejected
                        ? Theme.of(context).colorScheme.onError
                        : Theme.of(context).colorScheme.onPrimaryContainer)
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 6),
          // Badge con contador
          _CountBadge(
            count: tab.count,
            isSelected: isSelected,
            isRejected: isRejected,
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final bool isSelected;
  final bool isRejected;

  const _CountBadge({
    required this.count,
    required this.isSelected,
    required this.isRejected,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    if (isSelected) {
      if (isRejected) {
        backgroundColor = Theme.of(context).colorScheme.onError;
        textColor = Theme.of(context).colorScheme.error;
      } else {
        backgroundColor = Theme.of(context).colorScheme.onPrimaryContainer;
        textColor = Theme.of(context).colorScheme.primaryContainer;
      }
    } else {
      backgroundColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.onPrimary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
