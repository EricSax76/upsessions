import 'package:flutter/material.dart';

import '../../domain/announcement_entity.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.announcement, this.onTap});

  final AnnouncementEntity announcement;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(announcement.title),
        subtitle: Text('${announcement.city} · ${announcement.author}'),
        trailing: Text('${announcement.publishedAt.day}/${announcement.publishedAt.month}'),
        onTap: onTap,
      ),
    );
  }
}
