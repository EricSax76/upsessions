import 'package:flutter/material.dart';

class EventChipWrap extends StatelessWidget {
  const EventChipWrap({super.key, required this.values});

  final Iterable<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .where((value) => value.trim().isNotEmpty)
          .map(
            (value) => Chip(
              label: Text(value),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: scheme.surfaceContainerHighest,
              side: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.65),
              ),
              labelStyle: theme.textTheme.labelMedium,
            ),
          )
          .toList(),
    );
  }
}
