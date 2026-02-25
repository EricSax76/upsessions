import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArtistImageLabel extends StatelessWidget {
  const ArtistImageLabel({
    super.key,
    required this.artist,
    this.imageUrl,
    this.textStyle,
    this.thumbnailSize = 20,
    this.labelMaxWidth = 180,
  });

  final String artist;
  final String? imageUrl;
  final TextStyle? textStyle;
  final double thumbnailSize;
  final double labelMaxWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ArtistImageThumbnail(imageUrl: imageUrl, size: thumbnailSize),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: labelMaxWidth),
          child: Text(
            artist,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class ArtistImageThumbnail extends StatelessWidget {
  const ArtistImageThumbnail({
    super.key,
    required this.imageUrl,
    this.size = 20,
  });

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasImage = imageUrl?.trim().isNotEmpty ?? false;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: hasImage
          ? Padding(
              padding: const EdgeInsets.all(1.5),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                errorBuilder: (_, _, _) => _fallbackIcon(colorScheme),
              ),
            )
          : _fallbackIcon(colorScheme),
    );
  }

  Widget _fallbackIcon(ColorScheme colorScheme) {
    return Icon(
      Icons.person_outline,
      size: size * 0.65,
      color: colorScheme.onSurfaceVariant,
    );
  }
}

class ArtistChipWithAttribution extends StatelessWidget {
  const ArtistChipWithAttribution({
    super.key,
    required this.chip,
    this.spotifyUrl,
    this.expand = false,
    this.alignStart = false,
  });

  final Widget chip;
  final String? spotifyUrl;
  final bool expand;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(spotifyUrl?.trim() ?? '');
    if (uri == null) {
      if (!expand) {
        return chip;
      }
      return SizedBox(
        width: double.infinity,
        child: alignStart
            ? Align(alignment: Alignment.centerLeft, child: chip)
            : chip,
      );
    }

    if (expand) {
      return Row(
        children: [
          Expanded(
            child: alignStart
                ? Align(alignment: Alignment.centerLeft, child: chip)
                : chip,
          ),
          const SizedBox(width: 6),
          _SpotifyLinkButton(uri: uri),
        ],
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        chip,
        _SpotifyLinkButton(uri: uri),
      ],
    );
  }
}

class _SpotifyLinkButton extends StatelessWidget {
  const _SpotifyLinkButton({required this.uri});

  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Abrir en Spotify',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          try {
            final openedExternally = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            if (openedExternally) {
              return;
            }

            final openedWithDefault = await launchUrl(
              uri,
              mode: LaunchMode.platformDefault,
            );
            if (openedWithDefault || !context.mounted) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo abrir el enlace de Spotify.'),
              ),
            );
          } catch (_) {
            if (!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo abrir el enlace de Spotify.'),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.open_in_new, size: 13),
              const SizedBox(width: 3),
              Text(
                'Spotify',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
