import 'package:flutter/material.dart';
import 'package:upsessions/modules/musicians/ui/widgets/artist_image_label.dart';
import 'package:upsessions/modules/musicians/ui/utils/spotify_launcher.dart';

class ArtistInfluenceTile extends StatelessWidget {
  const ArtistInfluenceTile({
    super.key,
    required this.artist,
    this.imageUrl,
    this.spotifyUrl,
    this.onDelete,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final String artist;
  final String? imageUrl;
  final String? spotifyUrl;
  final VoidCallback? onDelete;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          ArtistImageThumbnail(imageUrl: imageUrl, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              artist,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (spotifyUrl != null && spotifyUrl!.isNotEmpty) ...[
            _ActionButton(
              icon: Icons.open_in_new,
              label: 'Spotify',
              onTap: () => SpotifyLauncher.launch(context, spotifyUrl),
            ),
          ],
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: colorScheme.error.withValues(alpha: 0.8),
              ),
              visualDensity: VisualDensity.compact,
              tooltip: 'Eliminar afinidad',
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
