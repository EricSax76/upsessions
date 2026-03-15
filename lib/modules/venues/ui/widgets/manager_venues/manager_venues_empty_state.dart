import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class ManagerVenuesEmptyState extends StatelessWidget {
  const ManagerVenuesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.place_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.venueManagerEmpty,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
