import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    super.key,
    required this.count,
    this.showBorder = false,
  });

  final int count;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = count > 99 ? '99+' : count.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      decoration: BoxDecoration(
        color: showBorder ? scheme.error : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: showBorder
            ? Border.all(color: scheme.surface, width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: showBorder ? scheme.onError : scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
