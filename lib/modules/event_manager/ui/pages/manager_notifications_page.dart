import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../notifications/models/manager_request_notification_entity.dart';
import '../../models/musician_request_entity.dart';
import '../../repositories/manager_notifications_repository.dart';

class ManagerNotificationsPage extends StatefulWidget {
  const ManagerNotificationsPage({super.key, required this.repository});

  final ManagerNotificationsRepository repository;

  @override
  State<ManagerNotificationsPage> createState() =>
      _ManagerNotificationsPageState();
}

class _ManagerNotificationsPageState extends State<ManagerNotificationsPage> {
  StreamSubscription<List<ManagerRequestNotificationEntity>>? _sub;
  List<ManagerRequestNotificationEntity> _requests = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sub = widget.repository.watchRequests().listen(
      (requests) {
        if (mounted) {
          setState(() {
            _requests = requests;
            _loading = false;
          });
        }
      },
      onError: (Object e) {
        if (mounted) {
          setState(() {
            _error = e.toString();
            _loading = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) return Center(child: Text('Error: $_error'));

    if (_requests.isEmpty) {
      return Center(
        child: Text(
          'No hay solicitudes a músicos.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final dateFmt = DateFormat('dd MMM yyyy', 'es');

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      itemCount: _requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final req = _requests[i];
        return Card(
          child: ListTile(
            leading: Icon(
              req.read
                  ? Icons.notifications_none_outlined
                  : req.status == RequestStatus.pending
                  ? Icons.hourglass_empty_outlined
                  : req.status == RequestStatus.accepted
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              color: _statusColor(context, req.status),
            ),
            title: Text(
              req.message.isEmpty ? 'Solicitud a músico' : req.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(dateFmt.format(req.createdAt)),
            trailing: _StatusChip(status: req.status),
            onTap: req.read ? null : () => widget.repository.markRead(req.id),
          ),
        );
      },
    );
  }

  Color _statusColor(BuildContext context, RequestStatus status) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case RequestStatus.accepted:
        return cs.primary;
      case RequestStatus.rejected:
        return cs.error;
      case RequestStatus.pending:
        return cs.onSurfaceVariant;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, bg, fg) = switch (status) {
      RequestStatus.accepted => (
        'Aceptada',
        cs.primaryContainer,
        cs.onPrimaryContainer,
      ),
      RequestStatus.rejected => (
        'Rechazada',
        cs.errorContainer,
        cs.onErrorContainer,
      ),
      RequestStatus.pending => (
        'Pendiente',
        cs.secondaryContainer,
        cs.onSecondaryContainer,
      ),
    };
    return Chip(
      label: Text(label, style: TextStyle(fontSize: 11, color: fg)),
      backgroundColor: bg,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
