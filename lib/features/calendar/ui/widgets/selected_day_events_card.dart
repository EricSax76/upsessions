import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../events/domain/event_entity.dart';
import 'event_tile.dart';

class SelectedDayEventsCard extends StatelessWidget {
  const SelectedDayEventsCard({
    super.key,
    required this.selectedDay,
    required this.events,
    required this.onViewEvent,
  });

  final DateTime selectedDay;
  final List<EventEntity> events;
  final ValueChanged<EventEntity> onViewEvent;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final label = loc.formatFullDate(selectedDay);
    final appLoc = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLoc.eventsForDate(label),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
              Text(
                appLoc.noEventsOnDate,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Column(
                children: [
                  for (final event in events)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: EventTile(event: event, onViewEvent: onViewEvent),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
