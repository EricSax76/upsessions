import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:upsessions/modules/musicians/models/artist_image_info.dart';
import 'package:upsessions/modules/musicians/ui/widgets/artist_image_label.dart';

class MusicianInfluencesSelectedList extends StatelessWidget {
  const MusicianInfluencesSelectedList({
    super.key,
    required this.influences,
    required this.artistImagesByName,
    required this.onRemoveInfluence,
  });

  final Map<String, List<String>> influences;
  final Map<String, ArtistImageInfo> artistImagesByName;
  final void Function(String style, String artist) onRemoveInfluence;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = MediaQuery.sizeOf(context).width < 640;

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
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: artists.map((artist) {
                    final info =
                        artistImagesByName[normalizeArtistName(artist)];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ArtistChipWithAttribution(
                        spotifyUrl: info?.spotifyUrl,
                        expand: true,
                        chip: RawChip(
                          label: ArtistImageLabel(
                            artist: artist,
                            imageUrl: info?.imageUrl,
                            textStyle: theme.textTheme.bodySmall?.copyWith(
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
                      ),
                    );
                  }).toList(),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: artists.map((artist) {
                    final info =
                        artistImagesByName[normalizeArtistName(artist)];
                    return ArtistChipWithAttribution(
                      spotifyUrl: info?.spotifyUrl,
                      chip: RawChip(
                        label: ArtistImageLabel(
                          artist: artist,
                          imageUrl: info?.imageUrl,
                          textStyle: theme.textTheme.bodySmall?.copyWith(
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
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
