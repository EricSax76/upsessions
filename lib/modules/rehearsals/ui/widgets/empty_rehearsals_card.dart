import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state_card.dart';

class EmptyRehearsalsCard extends StatelessWidget {
  const EmptyRehearsalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateCard(
      icon: Icons.event_available_outlined,
      title: 'Todavía no hay ensayos',
      subtitle: 'Crea el primero para empezar a armar el setlist.',
    );
  }
}
