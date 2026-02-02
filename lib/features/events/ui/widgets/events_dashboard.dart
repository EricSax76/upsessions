import 'package:flutter/material.dart';

import '../../models/event_entity.dart';
import 'event_cards.dart';

import 'events_hero_section.dart';

class EventsDashboard extends StatelessWidget {
  const EventsDashboard({
    super.key,
    required this.events,
    required this.loading,
    required this.eventsCount,
    required this.thisWeekCount,
    required this.totalCapacity,
    required this.onRefresh,
    required this.onSelectForPreview,
    required this.onViewDetails,
    required this.onCreateEvent,
    required this.ownerId,
  });

  final List<EventEntity> events;
  final bool loading;
  final int eventsCount;
  final int thisWeekCount;
  final int totalCapacity;
  final Future<void> Function() onRefresh;
  final ValueChanged<EventEntity> onSelectForPreview;
  final ValueChanged<EventEntity> onViewDetails;
  final VoidCallback onCreateEvent;
  final String? ownerId;

  @override
  Widget build(BuildContext context) {
    final content = events.isEmpty && loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                   padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                   sliver: SliverToBoxAdapter(
                      child: EventsHeroSection(
                        eventsCount: eventsCount,
                        thisWeekCount: thisWeekCount,
                        onCreateEvent: onCreateEvent,
                      ),
                   ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                if (events.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    sliver: SliverEventList(
                      events: events,
                      onSelect: onSelectForPreview,
                      onViewDetails: onViewDetails,
                    ),
                  ),
              ],
            ),
          );

    return SafeArea(
      child: Stack(
        children: [
          content,
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AnimatedOpacity(
              opacity: loading ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: loading
                  ? const LinearProgressIndicator(minHeight: 3)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
