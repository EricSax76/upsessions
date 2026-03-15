import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../models/setlist_item_entity.dart';

export 'rehearsal_detail_web_widgets.dart';

typedef ReorderSetlistCallback =
    Future<void> Function(List<String> itemIdsInOrder);

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
  final ReorderSetlistCallback onReorderSetlist;

  @override
  State<SetlistWebTable> createState() => _SetlistWebTableState();
}

class _SetlistWebTableState extends State<SetlistWebTable> {
  late List<SetlistItemEntity> _items;
  bool _isPersistingReorder = false;

  @override
  void initState() {
    super.initState();
    _items = _sorted(widget.setlist);
  }

  @override
  void didUpdateWidget(covariant SetlistWebTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isSameItems(oldWidget.setlist, widget.setlist)) return;
    _items = _sorted(widget.setlist);
    _isPersistingReorder = false;
  }

  List<SetlistItemEntity> _sorted(List<SetlistItemEntity> items) {
    return [...items]..sort((a, b) => a.order.compareTo(b.order));
  }

  bool _isSameItems(List<SetlistItemEntity> a, List<SetlistItemEntity> b) {
    final left = _sorted(a);
    final right = _sorted(b);

    if (identical(a, b)) return true;
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
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

  void _handleReorder(int oldIndex, int newIndex) {
    final previousItems = List<SetlistItemEntity>.from(_items);
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
      _items = _withLocalOrders(_items);
      _isPersistingReorder = true;
    });

    final itemIdsInOrder = _items.map((e) => e.id).toList(growable: false);
    unawaited(
      _persistReorder(
        previousItems: previousItems,
        itemIdsInOrder: itemIdsInOrder,
      ),
    );
  }

  Future<void> _persistReorder({
    required List<SetlistItemEntity> previousItems,
    required List<String> itemIdsInOrder,
  }) async {
    var failed = false;
    try {
      await widget.onReorderSetlist(itemIdsInOrder);
    } catch (_) {
      failed = true;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      if (failed) {
        _items = previousItems;
      }
      _isPersistingReorder = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
                    child: Text(
                      loc.setlistTableHeaderTitle,
                      style: _headerStyle(theme),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      loc.setlistTableHeaderKey,
                      style: _headerStyle(theme),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      loc.setlistTableHeaderBpm,
                      style: _headerStyle(theme),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      loc.setlistTableHeaderNotes,
                      style: _headerStyle(theme),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_isPersistingReorder)
              const LinearProgressIndicator(minHeight: 2),
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
        if (_isPersistingReorder) return;
        _handleReorder(oldIndex, newIndex);
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
    final loc = AppLocalizations.of(context);
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
                    widget.item.songTitle ?? loc.setlistTableUntitledSong,
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
                        ? '${widget.item.tempoBpm} ${loc.setlistTableBpmUnit}'
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
                          tooltip: loc.setlistTableDeleteTooltip,
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
