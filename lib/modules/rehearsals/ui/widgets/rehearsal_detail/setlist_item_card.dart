import 'package:flutter/material.dart';

import '../../../cubits/setlist_item_entity.dart';

class SetlistItemCard extends StatelessWidget {
  const SetlistItemCard({
    super.key,
    required this.item,
    // subtitle removed, handled internally
    required this.onDelete,
    this.onTap,
    this.trailing,
  });

  final SetlistItemEntity item;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onTap = this.onTap;
    final trailing = this.trailing;

    final hasKey = item.keySignature.isNotEmpty;
    final hasTempo = item.tempoBpm != null && item.tempoBpm! > 0;
    final hasLink = item.linkUrl.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Number Circle
              Container(
                height: 36,
                width: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.order.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        item.displayTitle, 
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold
                        )
                    ),
                    
                    if (hasKey || hasTempo || hasLink) ...[
                        const SizedBox(height: 8),
                        Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                                if (hasKey)
                                    Text(
                                        'Tono: ${item.keySignature}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                        ),
                                    ),
                                if (hasTempo)
                                    Text(
                                        'Tempo: ${item.tempoBpm} bpm',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w500,
                                        ),
                                    ),
                                if (hasLink)
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, 
                                            vertical: 4
                                        ),
                                        decoration: BoxDecoration(
                                            border: Border.all(color: scheme.outline),
                                            borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                                Icon(Icons.link, size: 14, color: scheme.primary),
                                                const SizedBox(width: 4),
                                                ConstrainedBox(
                                                  constraints: const BoxConstraints(maxWidth: 150),
                                                  child: Text(
                                                      // Simple display for URL, maybe truncated
                                                      item.linkUrl.replaceFirst(RegExp(r'^https?://(www\.)?'), ''), 
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                          color: scheme.primary,
                                                          fontWeight: FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(Icons.copy, size: 12, color: scheme.onSurfaceVariant),
                                            ],
                                        ),
                                    ),
                            ],
                        ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: scheme.onSurfaceVariant,
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  if (trailing != null) trailing,
                  if (trailing == null && onTap != null)
                    Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
