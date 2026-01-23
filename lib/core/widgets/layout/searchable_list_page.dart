import 'package:flutter/material.dart';

import '../empty_state_card.dart';
import '../feedback/error_card.dart';
import '../forms/search_field.dart';
import '../loading_indicator.dart';
import 'animated_list_item.dart';

/// Página genérica con búsqueda, filtros y lista de resultados.
class SearchableListPage<T> extends StatefulWidget {
  const SearchableListPage({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.searchEnabled = true,
    this.searchController,
    this.searchHint = 'Buscar...',
    this.searchLabel,
    this.searchMatcher,
    this.sortComparator,
    this.filterBuilder,
    this.headerBuilder,
    this.emptyBuilder,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'No hay elementos',
    this.emptySubtitle,
    this.errorMessage,
    this.onRetry,
    this.onRefresh,
    this.isLoading = false,
    this.animateItems = true,
    this.padding = const EdgeInsets.all(16),
  });

  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;

  // Search
  final bool searchEnabled;
  final TextEditingController? searchController;
  final String searchHint;
  final String? searchLabel;
  final bool Function(T item, String query)? searchMatcher;
  final int Function(T a, T b)? sortComparator;

  // Filters
  final Widget Function(BuildContext context)? filterBuilder;

  // Header
  final Widget Function(BuildContext context, int totalCount, int visibleCount)?
      headerBuilder;

  // Empty state
  final Widget Function(BuildContext context, bool isSearchEmpty)? emptyBuilder;
  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptySubtitle;

  // Error
  final String? errorMessage;
  final VoidCallback? onRetry;

  // Refresh
  final Future<void> Function()? onRefresh;

  // Loading
  final bool isLoading;

  // Animation
  final bool animateItems;

  // Layout
  final EdgeInsetsGeometry padding;

  @override
  State<SearchableListPage<T>> createState() => _SearchableListPageState<T>();
}

class _SearchableListPageState<T> extends State<SearchableListPage<T>> {
  late final TextEditingController _internalController;
  bool get _ownsController => widget.searchController == null;

  TextEditingController get _controller =>
      widget.searchController ?? _internalController;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    _controller.addListener(_handleQueryChange);
    _query = _controller.text;
  }

  @override
  void didUpdateWidget(covariant SearchableListPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchController != widget.searchController) {
      oldWidget.searchController?.removeListener(_handleQueryChange);
      _controller.addListener(_handleQueryChange);
      _query = _controller.text;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleQueryChange);
    if (_ownsController) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _handleQueryChange() {
    final next = _controller.text;
    if (next == _query) return;
    setState(() => _query = next);
  }

  List<T> _buildVisibleItems() {
    var visible = List<T>.from(widget.items);
    final trimmed = _query.trim();
    if (widget.searchEnabled &&
        trimmed.isNotEmpty &&
        widget.searchMatcher != null) {
      visible = visible
          .where((item) => widget.searchMatcher!(item, trimmed))
          .toList();
    }
    if (widget.sortComparator != null) {
      visible.sort(widget.sortComparator);
    }
    return visible;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (widget.errorMessage != null) {
      return Center(
        child: ErrorCard(
          message: widget.errorMessage!,
          onRetry: widget.onRetry,
        ),
      );
    }

    final visibleItems = _buildVisibleItems();
    final isSearchEmpty =
        widget.items.isNotEmpty && widget.searchEnabled && visibleItems.isEmpty;

    final content = ListView(
      padding: widget.padding,
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (widget.headerBuilder != null)
          widget.headerBuilder!(
            context,
            widget.items.length,
            visibleItems.length,
          ),
        if (widget.searchEnabled) ...[
          const SizedBox(height: 16),
          SearchField(
            controller: _controller,
            hintText: widget.searchHint,
            labelText: widget.searchLabel,
          ),
        ],
        if (widget.filterBuilder != null) ...[
          const SizedBox(height: 16),
          widget.filterBuilder!(context),
        ],
        const SizedBox(height: 16),
        if (visibleItems.isEmpty)
          widget.emptyBuilder?.call(context, isSearchEmpty) ??
              EmptyStateCard(
                icon: widget.emptyIcon,
                title: widget.emptyTitle,
                subtitle: widget.emptySubtitle,
              )
        else
          ...visibleItems.asMap().entries.map((entry) {
            final item = widget.itemBuilder(entry.value, entry.key);
            if (!widget.animateItems) return item;
            return AnimatedListItem(
              key: ValueKey(entry.key),
              index: entry.key,
              child: item,
            );
          }),
      ],
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: content,
      );
    }

    return content;
  }
}
