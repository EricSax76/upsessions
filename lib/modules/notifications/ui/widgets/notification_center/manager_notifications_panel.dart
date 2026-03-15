import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../event_manager/models/musician_request_entity.dart';
import '../../../../event_manager/repositories/manager_notifications_repository.dart';
import 'notification_center_empty_state.dart';
import 'notification_center_error_view.dart';
import 'notification_center_status_chips.dart';

class ManagerNotificationsPanel extends StatelessWidget {
  const ManagerNotificationsPanel({super.key, required this.repository});

  final ManagerNotificationsRepository repository;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy', 'es');

    return StreamBuilder(
      stream: repository.watchRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return NotificationCenterErrorView(
            message: snapshot.error.toString(),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!;
        if (requests.isEmpty) {
          return const NotificationCenterEmptyState(
            icon: Icons.assignment_turned_in_outlined,
            title: 'Sin solicitudes nuevas',
            description: 'Las respuestas de contratación aparecerán aquí.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Solicitudes recientes',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            for (final request in requests) ...[
              Card(
                child: ListTile(
                  leading: Icon(
                    request.read
                        ? Icons.notifications_none_outlined
                        : request.status == RequestStatus.pending
                        ? Icons.hourglass_empty_outlined
                        : request.status == RequestStatus.accepted
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color: _statusColor(context, request.status),
                  ),
                  title: Text(
                    request.message.isEmpty
                        ? 'Solicitud sin mensaje'
                        : request.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(dateFmt.format(request.createdAt)),
                  trailing: ManagerStatusChip(status: request.status),
                  onTap: request.read
                      ? null
                      : () => repository.markRead(request.id),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }

  Color _statusColor(BuildContext context, RequestStatus status) {
    final colors = Theme.of(context).colorScheme;
    switch (status) {
      case RequestStatus.accepted:
        return colors.primary;
      case RequestStatus.rejected:
        return colors.error;
      case RequestStatus.pending:
        return colors.onSurfaceVariant;
    }
  }
}
