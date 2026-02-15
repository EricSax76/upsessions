import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../cubits/booking_cubit.dart';
import '../../models/room_entity.dart';
import '../../../../core/constants/app_routes.dart';
import 'studios_list_page.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../repositories/studios_repository.dart';
import '../../../rehearsals/repositories/rehearsals_repository.dart';
import '../../../../core/locator/locator.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for image
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: room.photos.isNotEmpty
                    ? Image.network(
                        room.photos.first,
                        fit: BoxFit.cover,
                        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.broken_image_outlined,
                              size: 50,
                              color: Colors.grey,
                            ),
                      )
                    : const Icon(Icons.image, size: 50, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Text(
                room.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
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
                  child: Text(
                    rehearsalContext != null
                        ? 'Reservar para Ensayo'
                        : 'Book Room',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (context) => BookingCubit(
          roomPricePerHour: room.pricePerHour,
          roomId: room.id,
          roomName: room.name,
          studioId: room.studioId,
          studioName: studioName,
          rehearsalContext: rehearsalContext,
          authRepository: locate<AuthRepository>(),
          studiosRepository: locate<StudiosRepository>(),
          rehearsalsRepository: locate<RehearsalsRepository>(),
        ),
        child: const _BookingDialog(),
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

class _BookingDialog extends StatelessWidget {
  const _BookingDialog();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingCubit>();
    final isFromRehearsal = cubit.rehearsalContext != null;

    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state.status == BookingFormStatus.success) {
          Navigator.pop(context); // Close dialog

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFromRehearsal
                    ? '¡Sala reservada para el ensayo por ${state.totalPrice.toStringAsFixed(2)}€!'
                    : 'Booking confirmed for ${state.totalPrice.toStringAsFixed(2)}€!',
              ),
            ),
          );

          if (isFromRehearsal) {
             context.go(
              AppRoutes.rehearsalDetail(
                groupId: cubit.rehearsalContext!.groupId,
                rehearsalId: cubit.rehearsalContext!.rehearsalId,
              ),
            );
          }
        } else if (state.status == BookingFormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Error booking room')),
          );
        }
      },
      child: AlertDialog(
        title: Text(isFromRehearsal ? 'Reservar para Ensayo' : 'Book Room'),
        content: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            if (state.status == BookingFormStatus.loading) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   if (isFromRehearsal)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                    subtitle: Text(
                      state.selectedDate != null
                          ? DateFormat('EEE, MMM d, y').format(state.selectedDate!)
                          : 'Select Date',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        if (!context.mounted) return;
                        context.read<BookingCubit>().dateChanged(picked);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(
                      state.selectedTime?.format(context) ?? 'Select Time',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: state.selectedTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        if (!context.mounted) return;
                        context.read<BookingCubit>().timeChanged(picked);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Duration: ${state.durationHours} hours',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Slider(
                    value: state.durationHours.toDouble(),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    label: '${state.durationHours} h',
                    onChanged: (val) => context
                        .read<BookingCubit>()
                        .durationChanged(val.toInt()),
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
                          '${state.totalPrice.toStringAsFixed(2)}€',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              return FilledButton(
                onPressed: state.status == BookingFormStatus.loading
                    ? null
                    : () => context.read<BookingCubit>().confirmBooking(),
                child: Text(
                  isFromRehearsal ? 'Confirmar Reserva' : 'Confirm Booking',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
