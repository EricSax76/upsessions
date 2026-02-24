import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileLinkBox extends StatelessWidget {
  const ProfileLinkBox({
    super.key,
    required this.links,
    this.onAddLink,
    this.onRemoveLink,
    this.readOnly = false,
  });

  final Map<String, String> links;
  final void Function(String title, String url)? onAddLink;
  final void Function(String key)? onRemoveLink;
  final bool readOnly;

  void _showAddLinkDialog(BuildContext context) {
    if (onAddLink == null) return;
    String title = '';
    String url = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Enlace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej. Instagram, Portfolio...',
              ),
              onChanged: (v) => title = v,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'Ej. https://instagram.com/...',
              ),
              keyboardType: TextInputType.url,
              onChanged: (v) => url = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (title.trim().isNotEmpty && url.trim().isNotEmpty) {
                onAddLink?.call(title.trim(), url.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalLinks = links.length;
    final canAddMore = !readOnly && onAddLink != null && totalLinks < 5;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                readOnly ? 'Enlaces' : 'Tus enlaces',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                readOnly ? '$totalLinks enlaces' : '$totalLinks/5',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (links.isNotEmpty) const SizedBox(height: 16),
          ...links.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withAlpha(80),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.value,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Copiar enlace',
                      color: colorScheme.onSurfaceVariant,
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: entry.value),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enlace copiado')),
                        );
                      },
                    ),
                    if (!readOnly && onRemoveLink != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: colorScheme.error,
                        tooltip: 'Eliminar enlace',
                        onPressed: () => onRemoveLink?.call(entry.key),
                      ),
                  ],
                ),
              ),
            );
          }),
          if (canAddMore) ...[
            if (links.isNotEmpty) const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _showAddLinkDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: Text('Añadir enlace ($totalLinks/5)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: BorderSide(
                  color: colorScheme.primary.withAlpha(100),
                  style: BorderStyle.solid,
                ),
                foregroundColor: colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
