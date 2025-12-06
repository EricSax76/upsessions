import 'package:flutter/material.dart';

import '../../../data/models/home_event_model.dart';

class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({super.key, required this.events});

  final List<HomeEventModel> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _EventsEmptyState(
        message:
            'Aún no hay eventos publicados. Sé el primero en crear uno desde la sección Eventos.',
      );
    }
    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        separatorBuilder: (context, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final event = events[index];
          return _EventCard(event: event);
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final HomeEventModel event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);
    final dateLabel = loc.formatMediumDate(event.start);
    final timeLabel = loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start));
    final tags = event.tags.take(2).toList();
    return SizedBox(
      width: 280,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.event, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$dateLabel · $timeLabel',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${event.venue} · ${event.city}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
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
                    _InfoChip(
                      icon: Icons.people_alt_outlined,
                      label: '${event.capacity} personas',
                    ),
                    _InfoChip(
                      icon: Icons.confirmation_num_outlined,
                      label: event.ticketInfo,
                    ),
                    for (final tag in tags)
                      _InfoChip(icon: Icons.sell_outlined, label: tag),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _EventsEmptyState extends StatelessWidget {
  const _EventsEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(Icons.event_busy, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
