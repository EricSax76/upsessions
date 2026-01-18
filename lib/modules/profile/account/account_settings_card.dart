import 'package:flutter/material.dart';

class AccountSettingsCard extends StatelessWidget {
  const AccountSettingsCard({
    super.key,
    required this.twoFactor,
    required this.newsletter,
    required this.onTwoFactorChanged,
    required this.onNewsletterChanged,
    this.onSignOut,
  });

  final bool twoFactor;
  final bool newsletter;
  final ValueChanged<bool> onTwoFactorChanged;
  final ValueChanged<bool> onNewsletterChanged;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Ajustes de la cuenta',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            value: twoFactor,
            title: const Text('Autenticación de dos pasos'),
            subtitle: const Text('Añade una capa extra de seguridad'),
            onChanged: onTwoFactorChanged,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          SwitchListTile(
            value: newsletter,
            title: const Text('Recibir boletines'),
            subtitle: const Text('Entérate de las últimas novedades'),
            onChanged: onNewsletterChanged,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          ),
          if (onSignOut != null) ...[
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600),
              ),
              onTap: onSignOut,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ],
        ],
      ),
    );
  }
}

