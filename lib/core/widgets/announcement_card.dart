import 'package:flutter/material.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.dateText,
    this.onTap,
    this.dense = false,
  });

  final String title;
  final String subtitle;
  final String dateText;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: dense,
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(dateText),
        onTap: onTap,
      ),
    );
  }
}
