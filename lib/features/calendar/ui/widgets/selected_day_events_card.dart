import 'package:flutter/material.dart';

import '../../../../modules/rehearsals/models/rehearsal_entity.dart';
import '../../../../core/widgets/section_card.dart';
import 'event_tile.dart';

class SelectedDayRehearsalsCard extends StatelessWidget {
  const SelectedDayRehearsalsCard({
    super.key,
    required this.selectedDay,
    required this.rehearsals,
    required this.onViewRehearsal,
  });

  final DateTime selectedDay;
  final List<RehearsalEntity> rehearsals;
  final ValueChanged<RehearsalEntity> onViewRehearsal;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final label = loc.formatFullDate(selectedDay);
    return SectionCard(
      title: 'Ensayos para $label',
      child: rehearsals.isEmpty
          ? Text(
              'No hay ensayos en esta fecha.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : Column(
              children: [
                for (final rehearsal in rehearsals)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: RehearsalTile(
                      rehearsal: rehearsal,
                      onViewRehearsal: onViewRehearsal,
                    ),
                  ),
              ],
            ),
    );
  }
}
