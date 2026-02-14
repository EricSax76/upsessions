import 'package:flutter/material.dart';
import 'package:upsessions/core/widgets/section_card.dart';

import 'announcement_detail_shared.dart';

class AnnouncementStylesCard extends StatelessWidget {
  const AnnouncementStylesCard({super.key, required this.styles});

  final List<String> styles;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Estilos',
      child: AnnouncementChipWrap(values: styles),
    );
  }
}
