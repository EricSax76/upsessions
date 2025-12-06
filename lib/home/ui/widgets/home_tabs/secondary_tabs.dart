import 'package:flutter/material.dart';

import 'package:upsessions/features/announcements/presentation/pages/announcements_list_page.dart';
import 'package:upsessions/features/messaging/presentation/pages/chat_page.dart';
import 'package:upsessions/modules/musicians/ui/pages/musician_search_page.dart';

class MusiciansTab extends StatelessWidget {
  const MusiciansTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const MusicianSearchPage(showAppBar: false);
  }
}

class AnnouncementsTab extends StatelessWidget {
  const AnnouncementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnouncementsListPage(showAppBar: false);
  }
}

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatPage(showAppBar: false);
  }
}

class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonCard(
      title: 'Eventos',
      description:
          'Pronto podrás encontrar y organizar conciertos, ensayos y shows en tu ciudad.',
      icon: Icons.event_available,
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 64, color: colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                FilledButton(onPressed: null, child: const Text('Muy pronto')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
