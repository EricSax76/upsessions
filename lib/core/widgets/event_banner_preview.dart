import 'package:flutter/material.dart';

class EventBannerPreview extends StatelessWidget {
  const EventBannerPreview({
    super.key,
    required this.imageUrl,
    required this.height,
    this.overlayAlpha = 0.22,
    this.fallbackPrimaryAlpha = 0.32,
    this.fallbackSecondaryAlpha = 0.2,
    this.fallbackIcon = Icons.event_available_outlined,
    this.fallbackIconAlpha = 0.85,
    this.fallbackIconPadding = 10,
  });

  final String? imageUrl;
  final double height;
  final double overlayAlpha;
  final double fallbackPrimaryAlpha;
  final double fallbackSecondaryAlpha;
  final IconData fallbackIcon;
  final double fallbackIconAlpha;
  final double fallbackIconPadding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: hasImage
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imageUrl!, fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colorScheme.primary.withValues(alpha: overlayAlpha),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: fallbackPrimaryAlpha),
                    colorScheme.secondary.withValues(
                      alpha: fallbackSecondaryAlpha,
                    ),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(fallbackIconPadding),
                  child: Icon(
                    fallbackIcon,
                    color: colorScheme.onPrimary.withValues(
                      alpha: fallbackIconAlpha,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
