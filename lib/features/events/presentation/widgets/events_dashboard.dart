import 'package:flutter/material.dart';

import '../../domain/event_entity.dart';
import 'event_cards.dart';
import 'event_planner_section.dart';
import 'events_header.dart';

class EventsDashboard extends StatelessWidget {
  const EventsDashboard({
    super.key,
    required this.events,
    required this.preview,
    required this.loading,
    required this.eventsCount,
    required this.thisWeekCount,
    required this.totalCapacity,
    required this.onRefresh,
    required this.onGenerateDraft,
    required this.onSelectForPreview,
    required this.onViewDetails,
    required this.ownerId,
  });

  final List<EventEntity> events;
  final EventEntity? preview;
  final bool loading;
  final int eventsCount;
  final int thisWeekCount;
  final int totalCapacity;
  final Future<void> Function() onRefresh;
  final ValueChanged<EventEntity> onGenerateDraft;
  final ValueChanged<EventEntity> onSelectForPreview;
  final ValueChanged<EventEntity> onViewDetails;
  final String? ownerId;

  @override
  Widget build(BuildContext context) {
    final content = events.isEmpty && loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                EventsHeader(
                  eventsCount: eventsCount,
                  thisWeekCount: thisWeekCount,
                  totalCapacity: totalCapacity,
                ),
                const SizedBox(height: 24),
                if (events.isNotEmpty)
                  EventHighlightCard(
                    event: events.first,
                    onSelect: onSelectForPreview,
                    onViewDetails: onViewDetails,
                  ),
                if (events.isNotEmpty) const SizedBox(height: 32),
                if (events.isNotEmpty)
                  EventList(
                    events: events.skip(1).toList(),
                    onSelect: onSelectForPreview,
                    onViewDetails: onViewDetails,
                  ),
                if (events.isNotEmpty) const SizedBox(height: 32),
                EventPlannerSection(
                  preview: preview,
                  onGenerateDraft: onGenerateDraft,
                  ownerId: ownerId,
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
