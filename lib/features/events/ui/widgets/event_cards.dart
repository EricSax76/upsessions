import 'package:flutter/material.dart';
import 'package:upsessions/core/widgets/event_banner_preview.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../models/event_entity.dart';

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
    final materialLoc = MaterialLocalizations.of(context);
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final duration =
        '${materialLoc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start))} · ${event.venue}';

    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EventBannerPreview(imageUrl: event.bannerImageUrl, height: 120),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                      child: Icon(Icons.event, color: colorScheme.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${materialLoc.formatMediumDate(event.start)} · $duration',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: loc.eventsCopySheetTooltip,
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
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoChip(
                      icon: Icons.group_outlined,
                      label: loc.eventsPeopleCount(event.capacity),
                    ),
                    InfoChip(
                      icon: Icons.local_offer_outlined,
                      label: event.ticketInfo,
                    ),
                    InfoChip(
                      icon: Icons.call_outlined,
                      label: event.contactPhone,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => onViewDetails(event),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(loc.eventsViewDetails),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class SliverEventList extends StatelessWidget {
  const SliverEventList({
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
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.crossAxisExtent > 600;
        if (isWide) {
          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.1,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return EventCard(
                event: events[index],
                onSelect: onSelect,
                onViewDetails: onViewDetails,
              );
            }, childCount: events.length),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: EventCard(
                event: events[index],
                onSelect: onSelect,
                onViewDetails: onViewDetails,
              ),
            );
          }, childCount: events.length),
        );
      },
    );
  }
}
