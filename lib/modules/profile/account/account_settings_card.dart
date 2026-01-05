import 'package:flutter/material.dart';

class AccountSettingsCard extends StatelessWidget {
  const AccountSettingsCard({
    super.key,
    required this.twoFactor,
    required this.newsletter,
    required this.onTwoFactorChanged,
    required this.onNewsletterChanged,
    required this.onSignOut,
  });

  final bool twoFactor;
  final bool newsletter;
  final ValueChanged<bool> onTwoFactorChanged;
  final ValueChanged<bool> onNewsletterChanged;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            value: twoFactor,
            title: const Text('Autenticación de dos pasos'),
            onChanged: onTwoFactorChanged,
          ),
          const Divider(height: 0),
          SwitchListTile(
            value: newsletter,
            title: const Text('Recibir boletines'),
            onChanged: onNewsletterChanged,
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: onSignOut,
          ),
        ],
      ),
    );
  }
}
