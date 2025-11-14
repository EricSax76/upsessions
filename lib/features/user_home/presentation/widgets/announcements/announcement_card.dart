import 'package:flutter/material.dart';

import '../../../data/announcement_model.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.announcement});

  final AnnouncementModel announcement;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(announcement.title),
        subtitle: Text('${announcement.city} · ${announcement.description}'),
        trailing: Text('${announcement.date.day}/${announcement.date.month}'),
      ),
    );
  }
}
