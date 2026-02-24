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
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
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
                style.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: artists
                    .map(
                      (artist) => RawChip(
                        label: Text(
                          artist,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: colorScheme.outlineVariant.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        deleteIcon: Icon(
                          Icons.close,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
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
