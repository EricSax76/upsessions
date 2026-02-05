import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubits/studios_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../models/booking_entity.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../../../core/locator/locator.dart';

class MusicianBookingsPage extends StatelessWidget {
  const MusicianBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = locate<AuthRepository>();
    final userId = authRepo.currentUser?.id;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view bookings')),
      );
    }

    return BlocProvider(
      create: (context) => StudiosCubit()..loadMyBookings(userId),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Bookings')),
        body: BlocBuilder<StudiosCubit, StudiosState>(
          builder: (context, state) {
            if (state.status == StudiosStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.myBookings.isEmpty) {
              return const Center(child: Text('No bookings found.'));
            }

            return ListView.builder(
              itemCount: state.myBookings.length,
              itemBuilder: (context, index) {
                final booking = state.myBookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.event_available, color: Colors.blue),
                    title: Text('${booking.studioName} - ${booking.roomName}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('EEE, MMM d, y • HH:mm').format(booking.startTime)),
                        Text('Duration: ${booking.endTime.difference(booking.startTime).inHours}h • Total: ${booking.totalPrice}€'),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(booking.status.name.toUpperCase()),
                      backgroundColor: booking.status == BookingStatus.confirmed ? Colors.green.shade100 : Colors.orange.shade100,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
