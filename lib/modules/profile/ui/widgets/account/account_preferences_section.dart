import 'package:flutter/material.dart';

import '../../../models/account_settings_card.dart';

class AccountPreferencesSection extends StatelessWidget {
  const AccountPreferencesSection({
    super.key,
    this.showTitle = false,
    required this.twoFactor,
    required this.newsletter,
    required this.onTwoFactorChanged,
    required this.onNewsletterChanged,
    this.onSignOut,
  });

  final bool showTitle;
  final bool twoFactor;
  final bool newsletter;
  final ValueChanged<bool> onTwoFactorChanged;
  final ValueChanged<bool> onNewsletterChanged;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle) ...[
          Text('Preferencias de la cuenta', style: titleStyle),
          const SizedBox(height: 16),
        ],
        AccountSettingsCard(
          twoFactor: twoFactor,
          newsletter: newsletter,
          onTwoFactorChanged: onTwoFactorChanged,
          onNewsletterChanged: onNewsletterChanged,
          onSignOut: onSignOut,
        ),
      ],
    );
  }
}
