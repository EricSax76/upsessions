import 'package:flutter/material.dart';

import '../../../events/domain/event_entity.dart';
import '../../../../core/widgets/section_card.dart';
import 'event_tile.dart';

class MonthEventList extends StatelessWidget {
  const MonthEventList({
    super.key,
    required this.month,
    required this.events,
    required this.onViewEvent,
  });

  final DateTime month;
  final List<EventEntity> events;
  final ValueChanged<EventEntity> onViewEvent;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final label = loc.formatMonthYear(month);
    return SectionCard(
      title: 'Agenda de $label',
      child: events.isEmpty
          ? Text(
              'No hay eventos en este mes, pero puedes registrar uno desde la sección de eventos.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : Column(
              children: [
                for (final event in events)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EventTile(event: event, onViewEvent: onViewEvent),
                  ),
              ],
            ),
    );
  }
}
