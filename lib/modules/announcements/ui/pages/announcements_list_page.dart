import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../core/widgets/announcement_card.dart';

import '../../../../core/widgets/layout/searchable_list_page.dart';
import '../../repositories/announcements_repository.dart';
import '../../models/announcement_entity.dart';
import '../widgets/announcement_filter_panel.dart';
import '../widgets/announcements_hero_section.dart';

class AnnouncementsListPage extends StatefulWidget {
  const AnnouncementsListPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<AnnouncementsListPage> createState() => _AnnouncementsListPageState();
}

class _AnnouncementsListPageState extends State<AnnouncementsListPage> {
  final AnnouncementsRepository _repository = locate();
  List<AnnouncementEntity> _announcements = const [];
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _nextCursor;
  String? _errorMessage;
  String? _loadMoreErrorMessage;
  AnnouncementUiFilter _selectedFilter = AnnouncementUiFilter.all;

  static const _pageSize = 24;

  @override
  void initState() {
    super.initState();
    _load(refresh: true);
  }

  Future<void> _load({required bool refresh}) async {
    if (refresh) {
      if (_loading) return;
      setState(() {
        _loading = true;
        _loadingMore = false;
        _errorMessage = null;
        _loadMoreErrorMessage = null;
      });
    } else {
      if (_loading || _loadingMore || !_hasMore) return;
      setState(() {
        _loadingMore = true;
        _loadMoreErrorMessage = null;
      });
    }

    try {
      final page = await _repository.fetchPage(
        filter: _mapFilter(_selectedFilter),
        cursor: refresh ? null : _nextCursor,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _announcements = refresh
            ? page.items
            : <AnnouncementEntity>[..._announcements, ...page.items];
        _nextCursor = page.nextCursor;
        _hasMore = page.hasMore;
        _loading = false;
        _loadingMore = false;
        _errorMessage = null;
        _loadMoreErrorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        if (refresh || _announcements.isEmpty) {
          _errorMessage = 'No se pudieron cargar los anuncios.';
          _loadMoreErrorMessage = null;
        } else {
          _loadMoreErrorMessage = 'No se pudieron cargar más anuncios.';
        }
      });
    }
  }

  void _openForm() async {
    await context.push(AppRoutes.announcementForm);
    if (!mounted) return;
    _load(refresh: true);
  }

  Future<void> _loadMore() async {
    await _load(refresh: false);
  }

  void _onFilterChanged(AnnouncementUiFilter filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
      _nextCursor = null;
      _hasMore = true;
    });
    _load(refresh: true);
  }

  AnnouncementFeedFilter _mapFilter(AnnouncementUiFilter filter) {
    switch (filter) {
      case AnnouncementUiFilter.nearby:
        return AnnouncementFeedFilter.nearby;
      case AnnouncementUiFilter.urgent:
        return AnnouncementFeedFilter.urgent;
      case AnnouncementUiFilter.all:
        return AnnouncementFeedFilter.all;
    }
  }

  Widget _buildFooter(BuildContext context) {
    if (_loading || (_errorMessage != null && _announcements.isEmpty)) {
      return const SizedBox.shrink();
    }
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadMoreErrorMessage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _loadMoreErrorMessage!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loadMore,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      );
    }
    if (!_hasMore) {
      return const SizedBox.shrink();
    }
    return Center(
      child: OutlinedButton.icon(
        onPressed: _loadMore,
        icon: const Icon(Icons.expand_more),
        label: const Text('Cargar más'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listContent = SearchableListPage<AnnouncementEntity>(
      items: _announcements,
      isLoading: _loading,
      errorMessage: _announcements.isEmpty ? _errorMessage : null,
      onRetry: () => _load(refresh: true),
      onRefresh: () => _load(refresh: true),
      searchEnabled: false,
      gridLayout: true,
      gridSpacing: 24,
      emptyIcon: Icons.campaign_outlined,
      emptyTitle: 'No hay anuncios',
      emptySubtitle: 'Crea el primero o vuelve más tarde.',
      headerBuilder: !widget.showAppBar
          ? (_, _, _) => AnnouncementsHeroSection(onNewAnnouncement: _openForm)
          : null,
      filterBuilder: (_) =>
          AnnouncementFilterPanel(onChanged: _onFilterChanged),
      footerBuilder: _buildFooter,
      itemBuilder: (announcement, index) => AnnouncementCard(
        title: announcement.title,
        subtitle: '${announcement.city} · ${announcement.author}',
        dateText:
            '${announcement.publishedAt.day}/${announcement.publishedAt.month}',
        onTap: () => context.push(
          AppRoutes.announcementDetailPath(announcement.id),
          extra: announcement,
        ),
      ),
    );

    if (!widget.showAppBar) {
      return SafeArea(child: listContent);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anuncios'),
        actions: [
          IconButton(
            onPressed: _openForm,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: listContent,
    );
  }
}
