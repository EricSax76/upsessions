import 'package:flutter/material.dart';

import 'package:upsessions/locator.dart';
import '../../data/announcements_repository.dart';
import '../../domain/announcement_entity.dart';
import '../widgets/announcement_card.dart';
import '../widgets/announcement_filter_panel.dart';
import 'announcement_detail_page.dart';
import 'announcement_form_page.dart';

class AnnouncementsListPage extends StatefulWidget {
  const AnnouncementsListPage({super.key});

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
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AnnouncementFormPage(repository: _repository)));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anuncios'),
        actions: [IconButton(onPressed: _openForm, icon: const Icon(Icons.add_circle_outline))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AnnouncementFilterPanel(onChanged: (_) => _load()),
                  const SizedBox(height: 16),
                  for (final announcement in _announcements)
                    AnnouncementCard(
                      announcement: announcement,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AnnouncementDetailPage(announcement: announcement),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
