import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utilidad para abrir URLs externas de forma segura, validando esquemas
/// y solicitando confirmación al usuario para mitigar riesgos de phishing o intents no deseados.
class UrlLauncherUtils {
  static const List<String> _allowedSchemes = [
    'http',
    'https',
    'mailto',
    'tel',
  ];

  static Future<void> launchSafeUrl(
    BuildContext context,
    String urlString,
  ) async {
    final String trimmedUrl = urlString.trim();
    if (trimmedUrl.isEmpty) return;

    final Uri? uri = Uri.tryParse(trimmedUrl);

    // 1. Validación básica y de esquema
    if (uri == null || !uri.hasScheme || uri.scheme.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('URL inválida o sin esquema (ej. https://)'),
          ),
        );
      }
      return;
    }

    // 2. Allowlist de esquemas
    if (!_allowedSchemes.contains(uri.scheme.toLowerCase())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Por seguridad, no se permite el esquema: ${uri.scheme}',
            ),
          ),
        );
      }
      return;
    }

    // 3. Confirmación de UI antes de salir de la app
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abrir enlace externo'),
        content: Text(
          'Vas a salir de la aplicación para abrir:\n\n$trimmedUrl\n\n¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Abrir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No se pudo abrir el enlace.')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al intentar abrir el enlace.')),
          );
        }
      }
    }
  }
}
