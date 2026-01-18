import 'package:flutter/material.dart';

import '../../../cubits/rehearsal_entity.dart';
import '../../../cubits/setlist_item_entity.dart';
import 'rehearsal_info_card.dart';
import 'setlist_header.dart';
import 'setlist_items_list.dart';

class RehearsalDetailContent extends StatelessWidget {
  const RehearsalDetailContent({
    super.key,
    required this.rehearsal,
    required this.setlist,
    required this.onEditRehearsal,
    this.onDeleteRehearsal,
    required this.onCopyFromLast,
    required this.onAddSong,
    required this.onEditSong,
    required this.onDeleteSong,
    required this.onReorderSetlist,
  });

  final RehearsalEntity rehearsal;
  final List<SetlistItemEntity> setlist;
  final VoidCallback onEditRehearsal;
  final VoidCallback? onDeleteRehearsal;
  final VoidCallback onCopyFromLast;
  final VoidCallback onAddSong;
  final ValueChanged<SetlistItemEntity> onEditSong;
  final ValueChanged<SetlistItemEntity> onDeleteSong;
  final ValueChanged<List<String>> onReorderSetlist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 420
            ? 16.0
            : (constraints.maxWidth < 720 ? 20.0 : 24.0);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                88,
              ),
              children: [
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.event_available_outlined,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ensayo', style: theme.textTheme.headlineSmall),
                          const SizedBox(height: 2),
                          Text(
                            'Detalles y setlist',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onDeleteRehearsal != null)
                      IconButton(
                        tooltip: 'Eliminar ensayo',
                        icon: Icon(Icons.delete_outline, color: scheme.error),
                        onPressed: onDeleteRehearsal,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                RehearsalInfoCard(rehearsal: rehearsal, onTap: onEditRehearsal),
                const SizedBox(height: 20),
                SetlistHeader(
                  count: setlist.length,
                  onAddSong: onAddSong,
                  onCopyFromLast: onCopyFromLast,
                ),
                const SizedBox(height: 12),
                SetlistItemsList(
                  setlist: setlist,
                  onEditSong: onEditSong,
                  onDeleteSong: onDeleteSong,
                  onReorderSetlist: onReorderSetlist,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
