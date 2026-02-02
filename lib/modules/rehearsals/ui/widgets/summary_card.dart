import 'package:flutter/material.dart';

import '../../../../core/widgets/info_card.dart';
import '../../models/rehearsal_entity.dart';
import '../../utils/rehearsal_date_utils.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.totalCount,
    required this.nextRehearsal,
  });

  final int totalCount;
  final RehearsalEntity? nextRehearsal;

  @override
  Widget build(BuildContext context) {
    final totalLabel = totalCount == 1
        ? '1 ensayo programado'
        : '$totalCount ensayos programados';
    final nextLabel = nextRehearsal == null
        ? 'Sin proximo ensayo'
        : formatDateTime(nextRehearsal!.startsAt);

    return InfoCard(
      title: totalLabel,
      subtitle: 'Proximo: $nextLabel',
      icon: Icons.event_note_outlined,
    );
  }
}
