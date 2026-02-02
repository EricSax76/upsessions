import 'package:flutter/material.dart';

import '../../models/event_entity.dart';
import 'event_cards.dart';

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
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return EventCard(
                  event: events[index],
                  onSelect: onSelect,
                  onViewDetails: onViewDetails,
                );
              },
              childCount: events.length,
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: EventCard(
                  event: events[index],
                  onSelect: onSelect,
                  onViewDetails: onViewDetails,
                ),
              );
            },
            childCount: events.length,
          ),
        );
      },
    );
  }
}
