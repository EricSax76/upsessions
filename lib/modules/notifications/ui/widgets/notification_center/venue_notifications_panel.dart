import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../venues/repositories/venue_notifications_repository.dart';
import 'notification_center_empty_state.dart';
import 'notification_center_error_view.dart';
import 'notification_center_status_chips.dart';

class VenueNotificationsPanel extends StatelessWidget {
  const VenueNotificationsPanel({super.key, required this.repository});

  final VenueNotificationsRepository repository;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy', 'es');

    return StreamBuilder(
      stream: repository.watchVenueActivity(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return NotificationCenterErrorView(
            message: snapshot.error.toString(),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final sessions = snapshot.data!;
        if (sessions.isEmpty) {
          return const NotificationCenterEmptyState(
            icon: Icons.music_off_outlined,
            title: 'Sin actividad por ahora',
            description: 'Las novedades de tus jam sessions se verán aquí.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Actividad de jam sessions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            for (final session in sessions) ...[
              Card(
                child: ListTile(
                  leading: Icon(
                    session.isCanceled
                        ? Icons.event_busy_outlined
                        : session.isPublic
                        ? Icons.music_note_outlined
                        : Icons.lock_outline,
                  ),
                  title: Text(
                    session.title.isEmpty
                        ? 'Jam session sin título'
                        : session.title,
                  ),
                  subtitle: Text(
                    '${session.date != null ? dateFmt.format(session.date!) : 'Fecha por confirmar'} · ${session.city.isEmpty ? 'Ciudad pendiente' : session.city}',
                  ),
                  trailing: VenueVisibilityChip(
                    isCanceled: session.isCanceled,
                    isPublic: session.isPublic,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}
