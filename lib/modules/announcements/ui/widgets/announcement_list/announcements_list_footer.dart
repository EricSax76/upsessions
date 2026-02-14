import 'package:flutter/material.dart';

class AnnouncementsListFooter extends StatelessWidget {
  const AnnouncementsListFooter({
    super.key,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.isEmpty,
    required this.errorMessage,
    required this.loadMoreErrorMessage,
    required this.onRetryLoadMore,
    required this.onLoadMore,
  });

  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isEmpty;
  final String? errorMessage;
  final String? loadMoreErrorMessage;
  final VoidCallback onRetryLoadMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (isLoading || (errorMessage != null && isEmpty)) {
      return const SizedBox.shrink();
    }
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (loadMoreErrorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            loadMoreErrorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onRetryLoadMore,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      );
    }
    if (!hasMore) {
      return const SizedBox.shrink();
    }
    return Center(
      child: OutlinedButton.icon(
        onPressed: onLoadMore,
        icon: const Icon(Icons.expand_more),
        label: const Text('Cargar más'),
      ),
    );
  }
}
