import 'package:flutter/material.dart';
import '../../../models/setlist_item_entity.dart';
import '../../../../../core/widgets/empty_state_card.dart';
import 'setlist_item_card.dart';

class SetlistItemsList extends StatefulWidget {
  const SetlistItemsList({
    super.key,
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
  State<SetlistItemsList> createState() => _SetlistItemsListState();
}

class _SetlistItemsListState extends State<SetlistItemsList> {
  late List<SetlistItemEntity> _items;

  @override
  void initState() {
    super.initState();
    _items = [...widget.setlist]..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  void didUpdateWidget(covariant SetlistItemsList oldWidget) {
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

  List<SetlistItemEntity> _withLocalOrders(List<SetlistItemEntity> items) {
    return [
      for (var i = 0; i < items.length; i++)
        SetlistItemEntity(
          id: items[i].id,
          order: i,
          songId: items[i].songId,
          songTitle: items[i].songTitle,
          keySignature: items[i].keySignature,
          tempoBpm: items[i].tempoBpm,
          notes: items[i].notes,
          linkUrl: items[i].linkUrl,
          sheetUrl: items[i].sheetUrl,
          sheetPath: items[i].sheetPath,
        ),
    ];
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
          _items = _withLocalOrders(_items);
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
            displayOrder: item.order,
            // subtitle removed
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
