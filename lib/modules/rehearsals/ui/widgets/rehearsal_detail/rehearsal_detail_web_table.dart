import 'package:flutter/material.dart';
import '../../../models/setlist_item_entity.dart';

export 'rehearsal_detail_web_widgets.dart';

class SetlistWebTable extends StatefulWidget {
  const SetlistWebTable({
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
  State<SetlistWebTable> createState() => _SetlistWebTableState();
}

class _SetlistWebTableState extends State<SetlistWebTable> {
  late List<SetlistItemEntity> _items;

  @override
  void initState() {
    super.initState();
    _items = [...widget.setlist]..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  void didUpdateWidget(covariant SetlistWebTable oldWidget) {
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
          songTitle: items[i].songTitle, // Using existing entity structure
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = 600.0;
        final shouldScroll = constraints.maxWidth < minWidth;
        final useShrinkWrapFallback = !constraints.hasBoundedHeight;

        final tableContent = Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  SizedBox(
                    width: 40,
                    child: Text('#', style: _headerStyle(theme)),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text('Título', style: _headerStyle(theme)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Tonalidad', style: _headerStyle(theme)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('BPM', style: _headerStyle(theme)),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text('Notas', style: _headerStyle(theme)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1),
            if (useShrinkWrapFallback)
              _buildReorderableList(
                theme: theme,
                scheme: scheme,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              )
            else
              Expanded(
                child: _buildReorderableList(
                  theme: theme,
                  scheme: scheme,
                  shrinkWrap: false,
                ),
              ),
          ],
        );

        if (shouldScroll) {
          if (useShrinkWrapFallback) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: minWidth, child: tableContent),
            );
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: minWidth,
              height: constraints.maxHeight,
              child: tableContent,
            ),
          );
        }

        return tableContent;
      },
    );
  }

  Widget _buildReorderableList({
    required ThemeData theme,
    required ColorScheme scheme,
    required bool shrinkWrap,
    ScrollPhysics? physics,
  }) {
    return ReorderableListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: EdgeInsets.zero,
      primary: false,
      buildDefaultDragHandles: false,
      itemCount: _items.length,
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
        final item = _items[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey(item.id),
          index: index,
          child: _SetlistWebRow(
            item: item,
            index: index,
            onEdit: () => widget.onEditSong(item),
            onDelete: () => widget.onDeleteSong(item),
            theme: theme,
            scheme: scheme,
          ),
        );
      },
    );
  }

  TextStyle? _headerStyle(ThemeData theme) {
    return theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.bold,
    );
  }
}

class _SetlistWebRow extends StatefulWidget {
  const _SetlistWebRow({
    required this.item,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.theme,
    required this.scheme,
  });

  final SetlistItemEntity item;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ThemeData theme;
  final ColorScheme scheme;

  @override
  State<_SetlistWebRow> createState() => _SetlistWebRowState();
}

class _SetlistWebRowState extends State<_SetlistWebRow> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!mounted || _isHovering) return;
        setState(() => _isHovering = true);
      },
      onExit: (_) {
        if (!mounted || !_isHovering) return;
        setState(() => _isHovering = false);
      },
      child: Container(
        color: _isHovering
            ? widget.scheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : Colors.transparent,
        child: InkWell(
          onTap: widget.onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: widget.index,
                  child: Icon(
                    Icons.drag_indicator,
                    color: widget.scheme.outline,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${widget.item.order + 1}',
                    style: widget.theme.textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    widget.item.songTitle ?? 'Sin título',
                    style: widget.theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: widget.item.keySignature.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: widget.scheme.secondaryContainer.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.item.keySignature,
                            style: widget.theme.textTheme.bodySmall?.copyWith(
                              color: widget.scheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.item.tempoBpm != null
                        ? '${widget.item.tempoBpm} BPM'
                        : '-',
                    style: widget.theme.textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    widget.item.notes,
                    style: widget.theme.textTheme.bodySmall?.copyWith(
                      color: widget.scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: _isHovering
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: widget.scheme.error,
                          onPressed: widget.onDelete,
                          tooltip: 'Quitar del setlist',
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Re-export other widgets
