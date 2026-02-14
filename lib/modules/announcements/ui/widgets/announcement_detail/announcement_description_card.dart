import 'package:flutter/material.dart';
import 'package:upsessions/core/widgets/section_card.dart';

class AnnouncementDescriptionCard extends StatelessWidget {
  const AnnouncementDescriptionCard({super.key, required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final trimmed = body.trim();

    return SectionCard(
      title: 'Descripción',
      child: trimmed.isEmpty
          ? Text(
              'Este anuncio no tiene descripción.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          : Text(
              trimmed,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
    );
  }
}
