import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../cubits/studios_cubit.dart';

import '../../models/room_entity.dart';
import '../../models/booking_entity.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../../../core/locator/locator.dart';
import '../../../rehearsals/repositories/rehearsals_repository.dart';
import 'studios_list_page.dart';

class RoomDetailPage extends StatelessWidget {
  const RoomDetailPage({
    super.key,
    required this.room,
    required this.studioName,
    this.rehearsalContext,
  });

  final RoomEntity room;
  final String studioName;
  final RehearsalBookingContext? rehearsalContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(room.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for image
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: room.photos.isNotEmpty
                  ? Image.network(room.photos.first, fit: BoxFit.cover)
                  : const Icon(Icons.image, size: 50, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(room.name, style: Theme.of(context).textTheme.headlineMedium),
            Text(
              '${room.pricePerHour}€ / hour',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.people, 'Capacity: ${room.capacity} people'),
            _buildInfoRow(Icons.square_foot, 'Size: ${room.size}'),
            const SizedBox(height: 24),
            Text('Equipment', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: room.equipment
                  .map((e) => Chip(label: Text(e)))
                  .toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _showBookingDialog(context),
                child: Text(rehearsalContext != null
                    ? 'Reservar para Ensayo'
                    : 'Book Room'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    final cubit = context.read<StudiosCubit>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: cubit, // Pass the cubit to dialog
        child: _BookingDialog(
          room: room,
          studioName: studioName,
          rehearsalContext: rehearsalContext,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

class _BookingDialog extends StatefulWidget {
  const _BookingDialog({
    required this.room,
    required this.studioName,
    this.rehearsalContext,
  });

  final RoomEntity room;
  final String studioName;
  final RehearsalBookingContext? rehearsalContext;

  @override
  State<_BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<_BookingDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _durationHours;

  @override
  void initState() {
    super.initState();
    // If coming from rehearsal, use rehearsal date/time
    if (widget.rehearsalContext != null) {
      final rehearsalDate = widget.rehearsalContext!.suggestedDate;
      _selectedDate = DateTime(
        rehearsalDate.year,
        rehearsalDate.month,
        rehearsalDate.day,
      );
      _selectedTime = TimeOfDay(
        hour: rehearsalDate.hour,
        minute: rehearsalDate.minute,
      );
      // Calculate duration if end date is provided
      if (widget.rehearsalContext!.suggestedEndDate != null) {
        final diff = widget.rehearsalContext!.suggestedEndDate!
            .difference(rehearsalDate);
        _durationHours = diff.inHours.clamp(1, 8);
      } else {
        _durationHours = 2;
      }
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = const TimeOfDay(hour: 10, minute: 0);
      _durationHours = 2;
    }
  }

  double get _totalPrice => widget.room.pricePerHour * _durationHours;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _confirmBooking() async {
    final authRepo = locate<AuthRepository>();
    final user = authRepo.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to book a room')),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final endDateTime = startDateTime.add(Duration(hours: _durationHours));
    final bookingId = const Uuid().v4();

    final booking = BookingEntity(
      id: bookingId,
      roomId: widget.room.id,
      roomName: widget.room.name,
      studioId: widget.room.studioId,
      studioName: widget.studioName,
      ownerId: user.id,
      startTime: startDateTime,
      endTime: endDateTime,
      status: BookingStatus.confirmed, // Auto-confirm for MVP
      totalPrice: _totalPrice,
      rehearsalId: widget.rehearsalContext?.rehearsalId,
      groupId: widget.rehearsalContext?.groupId,
    );

    context.read<StudiosCubit>().createBooking(booking);

    // If booking from rehearsal, update the rehearsal with the booking ID
    if (widget.rehearsalContext != null) {
      try {
        final rehearsalsRepo = locate<RehearsalsRepository>();
        await rehearsalsRepo.updateRehearsalBooking(
          groupId: widget.rehearsalContext!.groupId,
          rehearsalId: widget.rehearsalContext!.rehearsalId,
          bookingId: bookingId,
        );
      } catch (e) {
        debugPrint('Failed to update rehearsal with booking: $e');
      }
    }

    if (!mounted) return;
    Navigator.pop(context); // Close dialog

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.rehearsalContext != null
            ? '¡Sala reservada para el ensayo por ${_totalPrice.toStringAsFixed(2)}€!'
            : 'Booking confirmed for ${_totalPrice.toStringAsFixed(2)}€!'),
      ),
    );

    // If from rehearsal context, pop back to rehearsal detail
    if (widget.rehearsalContext != null) {
      // Pop studios list and rooms page to return to rehearsal
      Navigator.of(context).popUntil((route) => route.isFirst || 
          (route.settings.name?.contains('rehearsal') ?? false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFromRehearsal = widget.rehearsalContext != null;
    
    return AlertDialog(
      title: Text(isFromRehearsal ? 'Reservar para Ensayo' : 'Book Room'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFromRehearsal)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fecha y hora pre-rellenadas desde el ensayo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('EEE, MMM d, y').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            const SizedBox(height: 16),
            Text(
              'Duration: $_durationHours hours',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Slider(
              value: _durationHours.toDouble(),
              min: 1,
              max: 8,
              divisions: 7,
              label: '$_durationHours h',
              onChanged: (val) => setState(() => _durationHours = val.toInt()),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Price:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${_totalPrice.toStringAsFixed(2)}€',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _confirmBooking,
          child: Text(isFromRehearsal ? 'Confirmar Reserva' : 'Confirm Booking'),
        ),
      ],
    );
  }
}
