import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class NoStudioEmptyState extends StatelessWidget {
  const NoStudioEmptyState({super.key, required this.onRegister});

  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            loc.studioEmptyNoStudioTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            loc.studioEmptyNoStudioSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onRegister,
            icon: const Icon(Icons.add),
            label: Text(loc.studioEmptyNoStudioAction),
          ),
        ],
      ),
    );
  }
}
