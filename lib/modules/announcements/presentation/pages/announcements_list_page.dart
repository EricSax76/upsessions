import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../core/widgets/announcement_card.dart';
import '../../../../core/widgets/layout/page_header.dart';
import '../../../../core/widgets/layout/searchable_list_page.dart';
import '../../data/announcements_repository.dart';
import '../../domain/announcement_entity.dart';
import '../widgets/announcement_filter_panel.dart';
import 'announcement_form_page.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _announcements = await _repository.fetchAll();
    setState(() => _loading = false);
  }

  void _openForm() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnnouncementFormPage(repository: _repository),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final listContent = SearchableListPage<AnnouncementEntity>(
      items: _announcements,
      isLoading: _loading,
      onRefresh: _load,
      searchEnabled: false,
      emptyIcon: Icons.campaign_outlined,
      emptyTitle: 'No hay anuncios',
      emptySubtitle: 'Crea el primero o vuelve más tarde.',
      filterBuilder: (_) => AnnouncementFilterPanel(onChanged: (_) => _load()),
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
      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'Anuncios',
              subtitle: 'Explora oportunidades y comparte las tuyas.',
              actions: [
                FilledButton.icon(
                  onPressed: _openForm,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Nuevo'),
                ),
              ],
            ),
            const Divider(height: 1),
            Expanded(child: listContent),
          ],
        ),
      );
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
