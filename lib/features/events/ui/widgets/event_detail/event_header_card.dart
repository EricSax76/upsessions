import 'package:flutter/material.dart';

import '../../../models/event_entity.dart';
import 'event_detail_components.dart';
import 'event_detail_helpers.dart';

class EventHeaderCard extends StatelessWidget {
  const EventHeaderCard({
    super.key,
    required this.event,
    required this.meta,
  });

  final EventEntity event;
  final EventDetailMeta meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.event_available_outlined,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.dateLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${meta.startTime} - ${meta.endTime}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${event.venue} · ${event.city}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                EventInfoPill(
                  icon: Icons.group_outlined,
                  label: '${event.capacity} personas',
                ),
                if (event.ticketInfo.trim().isNotEmpty)
                  EventInfoPill(
                    icon: Icons.confirmation_number_outlined,
                    label: event.ticketInfo,
                  ),
                EventInfoPill(
                  icon: Icons.person_outline,
                  label: event.organizer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
