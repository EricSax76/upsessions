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
    this.itemKeyBuilder,
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
    this.gridLayout = false,
    this.gridSpacing = 16.0,
    this.gridCrossAxisSpacing,
    this.gridMainAxisSpacing,
  });

  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;
  /// Optional key builder for stable animations. 
  /// If null, ValueKey(index) is used (which is not stable for reorders/inserts).
  final Key Function(T item)? itemKeyBuilder;

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
  
  // Grid Layout
  final bool gridLayout;
  final double gridSpacing;
  final double? gridCrossAxisSpacing;
  final double? gridMainAxisSpacing;

  @override
  State<SearchableListPage<T>> createState() => _SearchableListPageState<T>();
}

class _SearchableListPageState<T> extends State<SearchableListPage<T>> {
  TextEditingController? _internalController;
  bool get _ownsController => widget.searchController == null;

  TextEditingController get _controller {
    if (widget.searchController != null) return widget.searchController!;
    _internalController ??= TextEditingController();
    return _internalController!;
  }

  String _query = '';
  List<T>? _cachedVisibleItems;
  
  // Cache keys for dependencies to invalidate cache
  List<T>? _lastItems;
  String? _lastQuery;
  int Function(T, T)? _lastSortComparator;

  @override
  void initState() {
    super.initState();
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
    // Invalidate cache if dependencies change
    if (oldWidget.items != widget.items ||
        oldWidget.sortComparator != widget.sortComparator) {
      _cachedVisibleItems = null;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleQueryChange);
    // Only dispose if we created it and it's still the active one
    if (_ownsController) {
      _internalController?.dispose();
    }
    super.dispose();
  }

  void _handleQueryChange() {
    final next = _controller.text;
    if (next == _query) return;
    setState(() {
      _query = next;
      _cachedVisibleItems = null;
    });
  }

  List<T> _buildVisibleItems() {
    // Return cached if valid
    if (_cachedVisibleItems != null && 
        _lastItems == widget.items && 
        _lastQuery == _query &&
        _lastSortComparator == widget.sortComparator) {
      return _cachedVisibleItems!;
    }

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

    // Update cache
    _cachedVisibleItems = visible;
    _lastItems = widget.items;
    _lastQuery = _query;
    _lastSortComparator = widget.sortComparator;
    
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

    final content = LayoutBuilder(
      builder: (context, constraints) {
        // Determinar el número de columnas según el ancho
        final isWide = constraints.maxWidth > 600;
        final gridCrossAxisCount = isWide ? 2 : 1;
        
        // Calcular espaciado
        final crossSpacing = widget.gridCrossAxisSpacing ?? widget.gridSpacing;
        final mainSpacing = widget.gridMainAxisSpacing ?? widget.gridSpacing;

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: widget.padding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
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
                ]),
              ),
            ),
            if (visibleItems.isEmpty)
              SliverPadding(
                padding: widget.padding,
                sliver: SliverToBoxAdapter(
                  child: widget.emptyBuilder?.call(context, isSearchEmpty) ??
                      EmptyStateCard(
                        icon: widget.emptyIcon,
                        title: widget.emptyTitle,
                        subtitle: widget.emptySubtitle,
                      ),
                ),
              )
            else if (widget.gridLayout)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCrossAxisCount,
                    crossAxisSpacing: crossSpacing,
                    mainAxisSpacing: mainSpacing,
                    childAspectRatio: isWide ? 1.5 : 2.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = visibleItems[index];
                      final child = widget.itemBuilder(item, index);
                      if (!widget.animateItems) return child;
                      
                      final key = widget.itemKeyBuilder != null 
                          ? widget.itemKeyBuilder!(item)
                          : ValueKey(index);
                          
                      return AnimatedListItem(
                        key: key,
                        index: index,
                        child: child,
                      );
                    },
                    childCount: visibleItems.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                       final item = visibleItems[index];
                       final child = widget.itemBuilder(item, index);
                       if (!widget.animateItems) return child;

                       final key = widget.itemKeyBuilder != null 
                          ? widget.itemKeyBuilder!(item)
                          : ValueKey(index);

                      return AnimatedListItem(
                        key: key,
                        index: index,
                        child: child,
                      );
                    },
                    childCount: visibleItems.length,
                  ),
                ),
              ),
          ],
        );
      },
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
