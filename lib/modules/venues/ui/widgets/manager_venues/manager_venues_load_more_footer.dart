import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class ManagerVenuesLoadMoreFooter extends StatelessWidget {
  const ManagerVenuesLoadMoreFooter({
    super.key,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (!hasMore) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Align(
        alignment: Alignment.center,
        child: OutlinedButton.icon(
          onPressed: isLoadingMore ? null : onLoadMore,
          icon: isLoadingMore
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.expand_more),
          label: Text(localizations.venueLoadMore),
        ),
      ),
    );
  }
}
