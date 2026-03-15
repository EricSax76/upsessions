import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class ManagerVenuesErrorState extends StatelessWidget {
  const ManagerVenuesErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: Text(localizations.venueRetry),
            ),
          ],
        ),
      ),
    );
  }
}
