import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/widgets/section_card.dart';
import '../../../../../features/events/models/event_entity.dart';
import '../events/manager_event_card.dart';

class UpcomingEventsCard extends StatelessWidget {
  const UpcomingEventsCard({super.key, required this.events});

  final List<EventEntity> events;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Próximos Eventos',
      action: TextButton(
        onPressed: () => context.go(AppRoutes.eventManagerEvents),
        child: const Text('Ver todos'),
      ),
      child: events.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text('No tienes eventos próximos.'),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length > 3 ? 3 : events.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final event = events[index];
                return ManagerEventCard(event: event);
              },
            ),
    );
  }
}
