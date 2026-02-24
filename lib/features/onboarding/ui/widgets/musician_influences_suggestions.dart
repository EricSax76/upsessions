import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:upsessions/modules/musicians/application/affinity_flow.dart';
import 'package:upsessions/modules/musicians/models/artist_image_info.dart';
import 'package:upsessions/modules/musicians/ui/widgets/artist_image_label.dart';

class MusicianInfluencesSuggestions extends StatelessWidget {
  const MusicianInfluencesSuggestions({
    super.key,
    required this.selectedStyle,
    required this.loadingStyleOptions,
    required this.suggestedArtists,
    required this.artistImagesByName,
    required this.influences,
    required this.onAddInfluence,
    required this.onRemoveInfluence,
  });

  final String? selectedStyle;
  final bool loadingStyleOptions;
  final List<String> suggestedArtists;
  final Map<String, ArtistImageInfo> artistImagesByName;
  final Map<String, List<String>> influences;
  final ValueChanged<String> onAddInfluence;
  final ValueChanged<String> onRemoveInfluence;

  @override
  Widget build(BuildContext context) {
    final style = selectedStyle;
    if (style == null) return const SizedBox.shrink();

    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isMobile = MediaQuery.sizeOf(context).width < 640;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            loc.affinitySuggestedOptionsLabel,
            style: theme.textTheme.labelLarge,
          ),
        ),
        const SizedBox(height: 8),
        if (loadingStyleOptions)
          const Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (suggestedArtists.isEmpty)
          Text(loc.affinityNoMatchesForStyle, style: theme.textTheme.bodySmall)
        else
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: suggestedArtists.map((artist) {
                    final info =
                        artistImagesByName[normalizeArtistName(artist)];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ArtistChipWithAttribution(
                        spotifyUrl: info?.spotifyUrl,
                        expand: true,
                        chip: FilterChip(
                          label: ArtistImageLabel(
                            artist: artist,
                            imageUrl: info?.imageUrl,
                          ),
                          selected: AffinityFlow.isArtistSelected(
                            influences: influences,
                            style: style,
                            artist: artist,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              onAddInfluence(artist);
                              return;
                            }
                            onRemoveInfluence(artist);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestedArtists.map((artist) {
                    final info =
                        artistImagesByName[normalizeArtistName(artist)];
                    return ArtistChipWithAttribution(
                      spotifyUrl: info?.spotifyUrl,
                      chip: FilterChip(
                        label: ArtistImageLabel(
                          artist: artist,
                          imageUrl: info?.imageUrl,
                        ),
                        selected: AffinityFlow.isArtistSelected(
                          influences: influences,
                          style: style,
                          artist: artist,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            onAddInfluence(artist);
                            return;
                          }
                          onRemoveInfluence(artist);
                        },
                      ),
                    );
                  }).toList(),
                ),
      ],
    );
  }
}
