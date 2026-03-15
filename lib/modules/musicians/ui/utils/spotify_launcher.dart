import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyLauncher {
  static Future<void> launch(BuildContext context, String? spotifyUrl) async {
    final uri = Uri.tryParse(spotifyUrl?.trim() ?? '');
    if (uri == null) {
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

  static void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo abrir el enlace de Spotify.')),
    );
  }
}
