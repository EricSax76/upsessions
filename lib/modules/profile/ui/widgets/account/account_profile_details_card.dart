import 'package:flutter/material.dart';
import 'package:upsessions/modules/musicians/models/artist_image_info.dart';
import 'package:upsessions/modules/musicians/ui/widgets/artist_influence_tile.dart';

class AccountProfileDetailsCard extends StatelessWidget {
  const AccountProfileDetailsCard({
    super.key,
    required this.bio,
    required this.location,
    required this.skills,
    required this.influences,
    this.spotifyArtistImagesFuture,
  });

  final String bio;
  final String location;
  final List<String> skills;
  final Map<String, List<String>> influences;
  final Future<Map<String, ArtistImageInfo>>? spotifyArtistImagesFuture;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.badge_outlined, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Detalles del perfil',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailSection(
            context,
            icon: Icons.info_outline,
            label: 'Biografía',
            value: bio.isNotEmpty ? bio : 'Sin biografía',
          ),
          const Divider(height: 32),
          _buildDetailSection(
            context,
            icon: Icons.location_on_outlined,
            label: 'Ubicación',
            value: location.isNotEmpty ? location : 'Sin ubicación',
          ),
          const Divider(height: 32),
          _buildDetailSection(
            context,
            icon: Icons.psychology_outlined,
            label: 'Estilos',
            value: skills.isNotEmpty
                ? skills.join(', ')
                : 'Sin estilos registrados',
          ),
          const Divider(height: 32),
          _buildAffinitiesSection(context),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAffinitiesSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.hub_outlined,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              'Afinidades',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _buildAffinitiesContent(context),
      ],
    );
  }

  Widget _buildAffinitiesContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (influences.isEmpty) {
      return Text('Sin afinidades registradas', style: textTheme.bodyLarge);
    }

    final future = spotifyArtistImagesFuture;
    if (future == null) {
      return Text(_formatInfluences(influences), style: textTheme.bodyLarge);
    }

    return FutureBuilder<Map<String, ArtistImageInfo>>(
      future: future,
      builder: (context, snapshot) {
        final artistImagesByName =
            snapshot.data ?? const <String, ArtistImageInfo>{};
        final sortedStyles = influences.keys.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        if (sortedStyles.isEmpty) {
          return Text('Sin afinidades registradas', style: textTheme.bodyLarge);
        }

        final rows = <Widget>[];
        if (snapshot.connectionState == ConnectionState.waiting) {
          rows.add(const LinearProgressIndicator(minHeight: 2));
          rows.add(const SizedBox(height: 12));
        }

        for (final style in sortedStyles) {
          final artists = (influences[style] ?? const <String>[])
              .map((artist) => artist.trim())
              .where((artist) => artist.isNotEmpty)
              .toList(growable: false);
          if (artists.isEmpty) {
            continue;
          }

          rows.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }

        if (rows.isEmpty) {
          return Text('Sin afinidades registradas', style: textTheme.bodyLarge);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      },
    );
  }

  String _formatInfluences(Map<String, List<String>> data) {
    if (data.isEmpty) {
      return 'Sin afinidades registradas';
    }

    final lines = <String>[];
    final styles = data.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    for (final style in styles) {
      final artists = data[style] ?? const <String>[];
      if (artists.isEmpty) {
        continue;
      }
      lines.add('$style: ${artists.join(', ')}');
    }

    return lines.isEmpty ? 'Sin afinidades registradas' : lines.join('\n');
  }
}
