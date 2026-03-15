import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class PublicVenuesHeader extends StatelessWidget {
  const PublicVenuesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        localizations.venuePublicListTitle,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
