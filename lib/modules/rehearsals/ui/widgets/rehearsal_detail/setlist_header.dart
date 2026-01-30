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
                icon: const Icon(Icons.copy_all_outlined, size: 20),
                label: const Text('Copiar'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44), // Slightly taller
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  foregroundColor: theme.colorScheme.onSurface,
                ),
              );

        final addButton = FilledButton.icon(
          onPressed: onAddSong,
          icon: const Icon(Icons.playlist_add, size: 20),
          label: const Text('Agregar canción'),
          style: FilledButton.styleFrom(
             minimumSize: const Size(0, 44),
             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
             elevation: 0,
             backgroundColor: theme.colorScheme.primary, // Explicit primary
             foregroundColor: theme.colorScheme.onPrimary,
             textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [title, const Spacer(), countLabel]),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 12,
                children: [if (copyButton != null) copyButton, addButton],
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: title),
            const SizedBox(width: 16),
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  countLabel,
                  if (copyButton != null) copyButton,
                  addButton,
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
