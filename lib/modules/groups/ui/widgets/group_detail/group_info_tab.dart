import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/gap.dart';
import '../../../../../core/widgets/section_title.dart';
import '../../../models/group_dtos.dart';

class GroupInfoTab extends StatelessWidget {
  const GroupInfoTab({super.key, required this.group});

  final GroupDoc group;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (group.link1.isNotEmpty || group.link2.isNotEmpty) ...[
          const SectionTitle(text: 'Enlaces y Redes'),
          const VSpace(12),
          if (group.link1.isNotEmpty)
            InfoTile(icon: Icons.link, label: group.link1),
          if (group.link2.isNotEmpty)
            InfoTile(icon: Icons.link, label: group.link2),
          const VSpace(24),
        ],
        const SectionTitle(text: 'Configuración'),
        const VSpace(12),
        InfoTile(
          icon: Icons.admin_panel_settings_outlined,
          label: 'ID del grupo: ${group.id}',
        ),
      ],
    );
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(0),
      child: ListTile(
        leading: Icon(icon, size: 20),
        title: Text(label, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
