import 'package:flutter/material.dart';

import '../../../../modules/announcements/models/announcement_entity.dart';

class NewAnnouncementsSection extends StatelessWidget {
  const NewAnnouncementsSection({
    super.key,
    required this.announcements,
    required this.builder,
  });

  final List<AnnouncementEntity> announcements;
  final Widget Function(AnnouncementEntity announcement) builder;

  @override
  Widget build(BuildContext context) {
    return Column(children: announcements.map(builder).toList());
  }
}
