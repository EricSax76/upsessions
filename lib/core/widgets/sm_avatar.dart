import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SmAvatar extends StatelessWidget {
  const SmAvatar({
    super.key,
    required this.radius,
    this.imageUrl,
    this.initials,
    this.fallbackIcon,
    this.backgroundColor,
    this.foregroundColor,
  });

  final double radius;
  final String? imageUrl;
  final String? initials;
  final IconData? fallbackIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  bool _isValidImageUrl(String? url) {
    if (url == null) return false;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;
    return uri.hasAbsolutePath &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Widget _fallback(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fg = foregroundColor ?? colorScheme.onPrimaryContainer;
    if (fallbackIcon != null) {
      return Icon(fallbackIcon, color: fg, size: radius);
    }
    if ((initials ?? '').trim().isEmpty) {
      return Icon(Icons.person, color: fg, size: radius);
    }
    return Text(
      initials!.trim(),
      style: theme.textTheme.titleMedium?.copyWith(
        color: fg,
        fontWeight: FontWeight.w700,
      ),
      maxLines: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bg = backgroundColor ?? colorScheme.primaryContainer;
    final hasUrl = _isValidImageUrl(imageUrl);

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: ClipOval(
        child: DecoratedBox(
          decoration: BoxDecoration(color: bg),
          child: hasUrl
              ? Image.network(
                  imageUrl!.trim(),
                  fit: BoxFit.cover,
                  webHtmlElementStrategy: kIsWeb
                      ? WebHtmlElementStrategy.prefer
                      : WebHtmlElementStrategy.never,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: _fallback(context)),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: radius * 0.9,
                        height: radius * 0.9,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                )
              : Center(child: _fallback(context)),
        ),
      ),
    );
  }
}
