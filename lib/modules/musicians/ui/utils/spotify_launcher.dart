import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyLauncher {
  static bool canLaunch(String? spotifyUrl) =>
      _parseSpotifyUri(spotifyUrl) != null;

  static Future<void> launch(BuildContext context, String? spotifyUrl) async {
    final uri = _parseSpotifyUri(spotifyUrl);
    if (uri == null) {
      if (!context.mounted) {
        return;
      }
      _showError(context);
      return;
    }

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

      _showError(context);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showError(context);
    }
  }

  static Uri? _parseSpotifyUri(String? spotifyUrl) {
    final raw = spotifyUrl?.trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme) {
      return null;
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'spotify') {
      return uri;
    }

    if (scheme == 'http' || scheme == 'https') {
      final host = uri.host.toLowerCase();
      if (host == 'open.spotify.com' || host.endsWith('.spotify.com')) {
        return uri;
      }
    }

    return null;
  }

  static void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo abrir el enlace de Spotify.')),
    );
  }
}
