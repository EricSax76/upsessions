import 'package:flutter/material.dart';

import '../../../../../core/widgets/empty_state_card.dart';

class RehearsalsGroupsEmptyState extends StatelessWidget {
  const RehearsalsGroupsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateCard(
      icon: Icons.groups_outlined,
      title: 'Todavía no tienes grupos',
      subtitle: 'Crea uno nuevo para empezar a organizar ensayos.',
    );
  }
}
