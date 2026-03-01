import 'package:flutter/material.dart';

import '../../../../features/events/models/event_entity.dart';
import '../../../../features/events/ui/pages/event_detail_page.dart';
import '../../../../core/locator/locator.dart';
import '../../../../features/events/repositories/events_repository.dart';
import '../../repositories/manager_events_repository.dart';

class ManagerEventDetailPage extends StatelessWidget {
  const ManagerEventDetailPage({super.key, required this.eventId});
  
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EventEntity?>(
      future: locate<ManagerEventsRepository>().findById(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final event = snapshot.data;
        if (event == null) {
          return const Scaffold(
            body: Center(child: Text('Evento no encontrado')),
          );
        }

        // Reuse the core EventDetailPage which requires EventsRepository
        return EventDetailPage(
          event: event,
          eventsRepository: locate<EventsRepository>(),
        );
      },
    );
  }
}
