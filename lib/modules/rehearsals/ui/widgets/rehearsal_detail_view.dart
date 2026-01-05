import 'package:flutter/material.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/setlist_repository.dart';

import '../../../../core/locator/locator.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../cubits/rehearsal_entity.dart';
import '../../cubits/setlist_item_entity.dart';
import 'rehearsal_detail_widgets.dart';
import '../../controllers/setlist_actions.dart';

class RehearsalDetailView extends StatelessWidget {
  const RehearsalDetailView({
    super.key,
    required this.groupId,
    required this.rehearsalId,
    this.rehearsalsRepository,
    this.setlistRepository,
  });

  final String groupId;
  final String rehearsalId;
  final RehearsalsRepository? rehearsalsRepository;
  final SetlistRepository? setlistRepository;

  @override
  Widget build(BuildContext context) {
    final rehearsalsRepository =
        this.rehearsalsRepository ?? locate<RehearsalsRepository>();
    final setlistRepository =
        this.setlistRepository ?? locate<SetlistRepository>();

    return StreamBuilder<RehearsalEntity?>(
      stream: rehearsalsRepository.watchRehearsal(
        groupId: groupId,
        rehearsalId: rehearsalId,
      ),
      builder: (context, rehearsalSnapshot) {
        if (rehearsalSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        if (rehearsalSnapshot.hasError) {
          return Center(child: Text('Error: ${rehearsalSnapshot.error}'));
        }
        final rehearsal = rehearsalSnapshot.data;
        if (rehearsal == null) {
          return const Center(child: Text('Ensayo no encontrado.'));
        }

        return StreamBuilder<List<SetlistItemEntity>>(
          stream: setlistRepository.watchSetlist(
            groupId: groupId,
            rehearsalId: rehearsalId,
          ),
          builder: (context, setlistSnapshot) {
            if (setlistSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            }
            if (setlistSnapshot.hasError) {
              return Center(child: Text('Error: ${setlistSnapshot.error}'));
            }
            final setlist = setlistSnapshot.data ?? const [];
            return _RehearsalDetailContent(
              rehearsal: rehearsal,
              setlist: setlist,
              onCopyFromLast: () => copySetlistFromLastRehearsal(
                context: context,
                rehearsalsRepository: rehearsalsRepository,
                setlistRepository: setlistRepository,
                groupId: groupId,
                currentRehearsal: rehearsal,
                currentSetlist: setlist,
              ),
              onAddSong: () => addSetlistItem(
                context: context,
                repository: setlistRepository,
                groupId: groupId,
                rehearsalId: rehearsalId,
                current: setlist,
              ),
              onEditSong: (item) => editSetlistItem(
                context: context,
                repository: setlistRepository,
                groupId: groupId,
                rehearsalId: rehearsalId,
                item: item,
              ),
              onDeleteSong: (item) => confirmDeleteSetlistItem(
                context: context,
                repository: setlistRepository,
                groupId: groupId,
                rehearsalId: rehearsalId,
                item: item,
              ),
              onReorderSetlist: (itemIdsInOrder) async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await setlistRepository.setSetlistOrders(
                    groupId: groupId,
                    rehearsalId: rehearsalId,
                    itemIdsInOrder: itemIdsInOrder,
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('No se pudo reordenar el setlist: $error'),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}

class _RehearsalDetailContent extends StatelessWidget {
  const _RehearsalDetailContent({
    required this.rehearsal,
    required this.setlist,
    required this.onCopyFromLast,
    required this.onAddSong,
    required this.onEditSong,
    required this.onDeleteSong,
    required this.onReorderSetlist,
  });

  final RehearsalEntity rehearsal;
  final List<SetlistItemEntity> setlist;
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
                  ],
                ),
                const SizedBox(height: 16),
                RehearsalInfoCard(rehearsal: rehearsal),
                const SizedBox(height: 20),
                SetlistHeader(
                  count: setlist.length,
                  onAddSong: onAddSong,
                  onCopyFromLast: onCopyFromLast,
                ),
                const SizedBox(height: 12),
                _SetlistItems(
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

class _SetlistItems extends StatefulWidget {
  const _SetlistItems({
    required this.setlist,
    required this.onEditSong,
    required this.onDeleteSong,
    required this.onReorderSetlist,
  });

  final List<SetlistItemEntity> setlist;
  final ValueChanged<SetlistItemEntity> onEditSong;
  final ValueChanged<SetlistItemEntity> onDeleteSong;
  final ValueChanged<List<String>> onReorderSetlist;

  @override
  State<_SetlistItems> createState() => _SetlistItemsState();
}

class _SetlistItemsState extends State<_SetlistItems> {
  late List<SetlistItemEntity> _items;

  @override
  void initState() {
    super.initState();
    _items = [...widget.setlist]..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  void didUpdateWidget(covariant _SetlistItems oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isSameOrder(oldWidget.setlist, widget.setlist)) return;
    _items = [...widget.setlist]..sort((a, b) => a.order.compareTo(b.order));
  }

  bool _isSameOrder(List<SetlistItemEntity> a, List<SetlistItemEntity> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].order != b[i].order) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final setlist = _items;
    if (setlist.isEmpty) {
      return const EmptyStateCard(
        icon: Icons.queue_music_outlined,
        title: 'Todavía no hay canciones',
        subtitle: 'Agrega la primera para armar el setlist.',
      );
    }
    final scheme = Theme.of(context).colorScheme;
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: setlist.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
        widget.onReorderSetlist(_items.map((e) => e.id).toList());
      },
      itemBuilder: (context, index) {
        final item = setlist[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey(item.id),
          index: index,
          child: SetlistItemCard(
            item: item,
            subtitle: setlistSubtitleFor(context, item),
            onTap: () => widget.onEditSong(item),
            onDelete: () => widget.onDeleteSong(item),
            trailing: ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.drag_handle, color: scheme.onSurfaceVariant),
              ),
            ),
          ),
        );
      },
    );
  }
}
