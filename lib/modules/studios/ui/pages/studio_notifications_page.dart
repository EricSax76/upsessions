import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../notifications/models/studio_booking_notification_entity.dart';
import '../../repositories/studio_notifications_repository.dart';

class StudioNotificationsPage extends StatefulWidget {
  const StudioNotificationsPage({super.key, required this.repository});

  final StudioNotificationsRepository repository;

  @override
  State<StudioNotificationsPage> createState() =>
      _StudioNotificationsPageState();
}

class _StudioNotificationsPageState extends State<StudioNotificationsPage> {
  StreamSubscription<List<StudioBookingNotificationEntity>>? _sub;
  List<StudioBookingNotificationEntity> _bookings = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sub = widget.repository.watchPendingBookings().listen(
      (bookings) {
        if (mounted) {
          setState(() {
            _bookings = bookings;
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_bookings.isEmpty) {
      return Center(
        child: Text(
          'No hay reservas pendientes.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final dateFmt = DateFormat('dd MMM yyyy, HH:mm', 'es');

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      itemCount: _bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final booking = _bookings[i];
        final startLabel = booking.startTime != null
            ? dateFmt.format(booking.startTime!)
            : 'Sin fecha';
        return Card(
          child: ListTile(
            leading: Icon(
              booking.read
                  ? Icons.notifications_none_outlined
                  : Icons.notifications_active_outlined,
            ),
            title: Text(booking.roomName.isEmpty ? 'Sala' : booking.roomName),
            subtitle: Text(
              '$startLabel · ${booking.totalPrice.toStringAsFixed(2)} €',
            ),
            trailing: _StatusChip(status: booking.status),
            onTap: () => widget.repository.markRead(booking.bookingId),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch (status) {
      'confirmed' => (
        'Confirmada',
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
      ),
      'cancelled' || 'refunded' => (
        'Cancelada',
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),
      _ => (
        'Pendiente',
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
    };

    return Chip(
      label: Text(label, style: TextStyle(fontSize: 11, color: foreground)),
      backgroundColor: background,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
