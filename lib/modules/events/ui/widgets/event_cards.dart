import 'package:flutter/material.dart';

import '../../models/event_entity.dart';

class EventHighlightCard extends StatelessWidget {
  const EventHighlightCard({
    super.key,
    required this.event,
    required this.onSelect,
    required this.onViewDetails,
  });

  final EventEntity event;
  final ValueChanged<EventEntity> onSelect;
  final ValueChanged<EventEntity> onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);
    final startTime = loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start));
    final endTime = loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.end));

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${loc.formatFullDate(event.start)} · $startTime - $endTime',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              '${event.venue} · ${event.city}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: event.tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: theme.colorScheme.surface,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(event.description),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => onSelect(event),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Ver ficha en texto'),
                ),
                TextButton.icon(
                  onPressed: () => onSelect(event),
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text('Copiar formato'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onViewDetails(event),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ver detalles'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventList extends StatelessWidget {
  const EventList({
    super.key,
    required this.events,
    required this.onSelect,
    required this.onViewDetails,
  });

  final List<EventEntity> events;
  final ValueChanged<EventEntity> onSelect;
  final ValueChanged<EventEntity> onViewDetails;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Otros eventos programados',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            for (final event in events) ...[
              EventCard(
                event: event,
                onSelect: onSelect,
                onViewDetails: onViewDetails,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onSelect,
    required this.onViewDetails,
  });

  final EventEntity event;
  final ValueChanged<EventEntity> onSelect;
  final ValueChanged<EventEntity> onViewDetails;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final duration =
        '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start))} · ${event.venue}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.12,
                  ),
                  child: Icon(Icons.event, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${loc.formatMediumDate(event.start)} · $duration'),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copiar ficha',
                  onPressed: () => onSelect(event),
                  icon: const Icon(Icons.description),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoChip(
                  icon: Icons.group_outlined,
                  label: '${event.capacity} personas',
                ),
                InfoChip(
                  icon: Icons.local_offer_outlined,
                  label: event.ticketInfo,
                ),
                InfoChip(icon: Icons.call_outlined, label: event.contactPhone),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => onViewDetails(event),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ver detalles'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  const InfoChip({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}
