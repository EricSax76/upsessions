import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../models/home_event_model.dart';

class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({super.key, required this.events});

  final List<HomeEventModel> events;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (events.isEmpty) {
      return _EventsEmptyState(
        message: loc.eventsEmptyMessage,
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
                child: _EventCard(event: event, isCompact: isCompact),
              );
            },
          ),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.isCompact});

  final HomeEventModel event;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final materialLoc = MaterialLocalizations.of(context);
    final dateLabel = materialLoc.formatMediumDate(event.start);
    final timeLabel =
        materialLoc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start));
    
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: InkWell(
        onTap: () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: isCompact ? 100 : 120,
              child: _EventBannerPreview(
                imageUrl: event.bannerImageUrl,
                height: double.infinity,
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

class _EventBannerPreview extends StatelessWidget {
  const _EventBannerPreview({
    required this.imageUrl,
    required this.height,
  });

  final String? imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: hasImage
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.network(imageUrl!, fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        colorScheme.primary.withValues(alpha: 0.24),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.32),
                    colorScheme.secondary.withValues(alpha: 0.18),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.event_note_outlined,
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ),
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
