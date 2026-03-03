import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/widgets/empty_state_card.dart';
import 'package:upsessions/core/widgets/event_banner_preview.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../models/home_event_model.dart';

class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({
    super.key,
    required this.events,
    this.onEventTap,
  });

  final List<HomeEventModel> events;
  final ValueChanged<HomeEventModel>? onEventTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (events.isEmpty) {
      return EmptyStateCard(
        icon: Icons.event_busy_outlined,
        title: loc.eventsEmptyTitle,
        subtitle: loc.eventsEmptyMessage,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final listHeight = isCompact ? 160.0 : 130.0;
        final availableWidth = constraints.maxWidth == double.infinity
            ? 320.0
            : constraints.maxWidth;
        final cardWidth = isCompact
            ? (availableWidth * 0.85).clamp(220.0, 320.0)
            : 320.0;

        return SizedBox(
          height: listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            separatorBuilder: (context, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final event = events[index];
              return SizedBox(
                width: cardWidth,
                child: _EventCard(
                  event: event,
                  isCompact: isCompact,
                  onTap: onEventTap == null ? null : () => onEventTap!(event),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.isCompact, this.onTap});

  final HomeEventModel event;
  final bool isCompact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final materialLoc = MaterialLocalizations.of(context);
    final dateLabel = materialLoc.formatMediumDate(event.start);
    final timeLabel = materialLoc.formatTimeOfDay(
      TimeOfDay.fromDateTime(event.start),
    );

    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () => context.push(AppRoutes.eventDetailPath(event.id)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: isCompact ? 100 : 120,
              child: EventBannerPreview(
                imageUrl: event.bannerImageUrl,
                height: double.infinity,
                overlayAlpha: 0.24,
                fallbackSecondaryAlpha: 0.18,
                fallbackIcon: Icons.event_note_outlined,
                fallbackIconAlpha: 0.8,
                fallbackIconPadding: 8,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dateLabel · $timeLabel',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isCompact ? 14 : 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${event.venue} · ${event.city}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
