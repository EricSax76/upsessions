import 'package:flutter/material.dart';

class RehearsalsGroupsHeader extends StatelessWidget {
  const RehearsalsGroupsHeader({
    super.key,
    required this.groupCount,
    required this.visibleCount,
  });

  final int groupCount;
  final int visibleCount;

  @override
  Widget build(BuildContext context) {
    final showCount = groupCount > 0;
    final label = visibleCount == groupCount
        ? '$groupCount grupos'
        : '$visibleCount de $groupCount';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Ensayos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            if (showCount)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Tus grupos activos para organizar ensayos.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
