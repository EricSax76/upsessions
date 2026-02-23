import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class MusicianInfluencesSelectedList extends StatelessWidget {
  const MusicianInfluencesSelectedList({
    super.key,
    required this.influences,
    required this.onRemoveInfluence,
  });

  final Map<String, List<String>> influences;
  final void Function(String style, String artist) onRemoveInfluence;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (influences.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            loc.onboardingInfluencesEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: influences.entries.map((entry) {
        final style = entry.key;
        final artists = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: artists
                    .map(
                      (artist) => Chip(
                        label: Text(artist),
                        onDeleted: () => onRemoveInfluence(style, artist),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
