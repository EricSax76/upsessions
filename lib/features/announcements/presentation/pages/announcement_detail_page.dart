import 'package:flutter/material.dart';

import '../../domain/announcement_entity.dart';

class AnnouncementDetailPage extends StatelessWidget {
  const AnnouncementDetailPage({super.key, required this.announcement});

  final AnnouncementEntity announcement;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(announcement.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${announcement.city} · ${announcement.author}'),
            const SizedBox(height: 8),
            Text(
              '${announcement.province} · ${announcement.instrument}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (announcement.styles.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: announcement.styles.map((s) => Chip(label: Text(s))).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Text(announcement.body),
            const Spacer(),
            FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.message), label: const Text('Contactar autor')),
          ],
        ),
      ),
    );
  }
}
