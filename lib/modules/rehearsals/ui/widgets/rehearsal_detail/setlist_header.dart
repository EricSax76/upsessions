import 'package:flutter/material.dart';

class SetlistHeader extends StatelessWidget {
  const SetlistHeader({
    super.key,
    required this.count,
    this.onAddSong,
    this.onCopyFromLast,
  });

  final int count;
  final VoidCallback? onAddSong;
  final VoidCallback? onCopyFromLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countLabel = Text('$count canciones');

    return LayoutBuilder(
      builder: (context, constraints) {
        final onAddSong = this.onAddSong;
        final hasAction = onAddSong != null;
        final isCompact = constraints.maxWidth < 420;

        final title = Text('Setlist', style: theme.textTheme.titleLarge);
        final onCopyFromLast = this.onCopyFromLast;

        if (!hasAction) {
          return Row(children: [title, const Spacer(), countLabel]);
        }

        final copyButton = (onCopyFromLast == null)
            ? null
            : OutlinedButton.icon(
                onPressed: onCopyFromLast,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Copiar'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              );

        final addButton = FilledButton.icon(
          onPressed: onAddSong,
          icon: const Icon(Icons.playlist_add),
          label: const Text('Agregar canción'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [title, const Spacer(), countLabel]),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [if (copyButton != null) copyButton, addButton],
              ),
            ],
          );
        }

        return Row(
          children: [
            title,
            const Spacer(),
            countLabel,
            const SizedBox(width: 12),
            if (copyButton != null) ...[copyButton, const SizedBox(width: 8)],
            addButton,
          ],
        );
      },
    );
  }
}
