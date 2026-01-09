import 'package:flutter/material.dart';

import '../../../events/domain/event_entity.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agenda de $label',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          Text(
            'No hay eventos en este mes, pero puedes registrar uno desde la sección de eventos.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          Column(
            children: [
              for (final event in events)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EventTile(event: event, onViewEvent: onViewEvent),
                ),
            ],
          ),
      ],
    );
  }
}
