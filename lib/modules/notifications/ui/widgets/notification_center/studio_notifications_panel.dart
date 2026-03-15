import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../studios/repositories/studio_notifications_repository.dart';
import 'notification_center_empty_state.dart';
import 'notification_center_error_view.dart';
import 'notification_center_status_chips.dart';

class StudioNotificationsPanel extends StatelessWidget {
  const StudioNotificationsPanel({super.key, required this.repository});

  final StudioNotificationsRepository repository;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy, HH:mm', 'es');

    return StreamBuilder(
      stream: repository.watchPendingBookings(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return NotificationCenterErrorView(
            message: snapshot.error.toString(),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = snapshot.data!;
        if (bookings.isEmpty) {
          return const NotificationCenterEmptyState(
            icon: Icons.event_available_outlined,
            title: 'Sin reservas pendientes',
            description: 'Cuando entre una nueva reserva la verás aquí.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Reservas por revisar',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            for (final booking in bookings) ...[
              Card(
                child: ListTile(
                  leading: Icon(
                    booking.read
                        ? Icons.notifications_none_outlined
                        : Icons.notifications_active_outlined,
                  ),
                  title: Text(
                    booking.roomName.isEmpty
                        ? 'Sala sin nombre'
                        : booking.roomName,
                  ),
                  subtitle: Text(
                    '${booking.startTime != null ? dateFmt.format(booking.startTime!) : 'Sin fecha asignada'} · ${booking.totalPrice.toStringAsFixed(2)} €',
                  ),
                  trailing: StudioStatusChip(status: booking.status),
                  onTap: () {
                    repository.markRead(booking.bookingId);
                    final targetRoute = booking.studioId.trim().isEmpty
                        ? AppRoutes.studiosDashboard
                        : AppRoutes.studiosRoomsPath(booking.studioId);
                    context.go(targetRoute);
                  },
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
