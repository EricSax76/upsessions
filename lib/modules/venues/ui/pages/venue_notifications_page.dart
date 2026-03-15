import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../notifications/models/venue_activity_notification_entity.dart';
import '../../repositories/venue_notifications_repository.dart';

class VenueNotificationsPage extends StatefulWidget {
  const VenueNotificationsPage({super.key, required this.repository});

  final VenueNotificationsRepository repository;

  @override
  State<VenueNotificationsPage> createState() => _VenueNotificationsPageState();
}

class _VenueNotificationsPageState extends State<VenueNotificationsPage> {
  StreamSubscription<List<VenueActivityNotificationEntity>>? _sub;
  List<VenueActivityNotificationEntity> _sessions = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sub = widget.repository.watchVenueActivity().listen(
      (sessions) {
        if (mounted) {
          setState(() {
            _sessions = sessions;
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

    if (_sessions.isEmpty) {
      return Center(
        child: Text(
          'No hay actividad en tus locales.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final dateFmt = DateFormat('dd MMM yyyy', 'es');

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      itemCount: _sessions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final session = _sessions[i];
        final dateLabel = session.date != null
            ? dateFmt.format(session.date!)
            : '-';
        final trailing = session.isCanceled
            ? const Chip(
                label: Text('Cancelada', style: TextStyle(fontSize: 11)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              )
            : session.isPublic
            ? null
            : const Chip(
                label: Text('Privada', style: TextStyle(fontSize: 11)),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              );
        return Card(
          child: ListTile(
            leading: const Icon(Icons.music_note_outlined),
            title: Text(session.title.isEmpty ? 'Jam session' : session.title),
            subtitle: Text('$dateLabel · ${session.city}'),
            trailing: trailing,
          ),
        );
      },
    );
  }
}
