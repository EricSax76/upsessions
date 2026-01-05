import 'package:flutter/material.dart';

import '../../../../modules/events/models/event_entity.dart';

class EventTile extends StatelessWidget {
  const EventTile({super.key, required this.event, required this.onViewEvent});

  final EventEntity event;
  final ValueChanged<EventEntity> onViewEvent;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final startTime = loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start));
    final endTime = loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.end));
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      tileColor: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        event.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '${loc.formatMediumDate(event.start)} · $startTime - $endTime · ${event.venue}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.open_in_new),
        tooltip: 'Ver detalles',
        onPressed: () => onViewEvent(event),
      ),
      onTap: () => onViewEvent(event),
    );
  }
}
