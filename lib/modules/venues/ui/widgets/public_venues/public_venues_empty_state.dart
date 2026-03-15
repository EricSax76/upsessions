import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class PublicVenuesEmptyState extends StatelessWidget {
  const PublicVenuesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Text(
        localizations.venuePublicEmpty,
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
