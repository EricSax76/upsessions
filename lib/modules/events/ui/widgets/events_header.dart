import 'package:flutter/material.dart';

import '../../models/event_entity.dart';

class EventsHeader extends StatelessWidget {
  const EventsHeader({super.key, required this.events});

  final List<EventEntity> events;

  @override
  Widget build(BuildContext context) {
    final totalCapacity = events.fold<int>(
      0,
      (sum, event) => sum + event.capacity,
    );
    final weekLimit = DateTime.now().add(const Duration(days: 7));
    final thisWeek = events
        .where((event) => event.start.isBefore(weekLimit))
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Eventos y showcases',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Planifica tus sesiones. Genera una ficha en formato texto para compartirla por correo o chat.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SummaryChip(
              label: 'Eventos activos',
              value: events.length.toString(),
              icon: Icons.event_available,
            ),
            SummaryChip(
              label: 'Esta semana',
              value: thisWeek.toString(),
              icon: Icons.calendar_month,
            ),
            SummaryChip(
              label: 'Capacidad total',
              value: '$totalCapacity personas',
              icon: Icons.people_alt_outlined,
            ),
          ],
        ),
      ],
    );
  }
}

class SummaryChip extends StatelessWidget {
  const SummaryChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label),
            ],
          ),
        ],
      ),
    );
  }
}
