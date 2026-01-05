import 'package:flutter/material.dart';

import '../../../models/announcement_model.dart';

class NewAnnouncementsSection extends StatelessWidget {
  const NewAnnouncementsSection({
    super.key,
    required this.announcements,
    required this.builder,
  });

  final List<AnnouncementModel> announcements;
  final Widget Function(AnnouncementModel announcement) builder;

  @override
  Widget build(BuildContext context) {
    return Column(children: announcements.map(builder).toList());
  }
}
