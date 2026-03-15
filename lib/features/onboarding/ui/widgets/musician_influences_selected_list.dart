import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:upsessions/modules/musicians/models/artist_image_info.dart';
import 'package:upsessions/modules/musicians/models/musician_string_utils.dart';

import 'package:upsessions/modules/musicians/ui/widgets/artist_influence_tile.dart';

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
                      child: ArtistInfluenceTile(
                        artist: artist,
                        imageUrl: info?.imageUrl,
                        spotifyUrl: info?.spotifyUrl,
                        onDelete: () => onRemoveInfluence(style, artist),
                      ),
                    );
                  }).toList(),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: artists.map((artist) {
                    final info =
                        artistImagesByName[normalizeArtistName(artist)];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: ArtistInfluenceTile(
                          artist: artist,
                          imageUrl: info?.imageUrl,
                          spotifyUrl: info?.spotifyUrl,
                          onDelete: () => onRemoveInfluence(style, artist),
                        ),
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
