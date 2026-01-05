import 'package:flutter/material.dart';

import '../../../models/musician_entity.dart';

class MusicianHighlightsGrid extends StatelessWidget {
  const MusicianHighlightsGrid({super.key, required this.musician});

  final MusicianEntity musician;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Widget buildHighlight({
      required IconData icon,
      required String label,
      required String value,
    }) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colors.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;
        final items = [
          buildHighlight(
            icon: Icons.work_history_outlined,
            label: 'Experiencia',
            value: '${musician.experienceYears} años',
          ),
          buildHighlight(
            icon: Icons.music_video,
            label: 'Instrumento',
            value: musician.instrument,
          ),
          buildHighlight(
            icon: Icons.place_outlined,
            label: 'Con base en',
            value: musician.city,
          ),
        ];
        if (isNarrow) {
          return Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                items[i],
                if (i != items.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: items[0]),
            const SizedBox(width: 12),
            Expanded(child: items[1]),
            const SizedBox(width: 12),
            Expanded(child: items[2]),
          ],
        );
      },
    );
  }
}
