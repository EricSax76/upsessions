import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/studios_cubit.dart';
import '../../cubits/studios_state.dart';
import 'widgets/booking_card.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../../../core/locator/locator.dart';

class MusicianBookingsPage extends StatefulWidget {
  const MusicianBookingsPage({super.key});

  @override
  State<MusicianBookingsPage> createState() => _MusicianBookingsPageState();
}

class _MusicianBookingsPageState extends State<MusicianBookingsPage> {
  late final String? _userId;
  StudiosCubit? _cubit;

  @override
  void initState() {
    super.initState();
    final authRepo = locate<AuthRepository>();
    _userId = authRepo.currentUser?.id;
    final userId = _userId;
    if (userId != null) {
      _cubit = StudiosCubit()..loadMyBookings(userId);
    }
  }

  @override
  void dispose() {
    _cubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;
    if (userId == null) {
      return const Center(child: Text('Please login to view bookings'));
    }

    return BlocProvider.value(
      value: _cubit!,
      child: BlocBuilder<StudiosCubit, StudiosState>(
        builder: (context, state) {
          if (state.status == StudiosStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == StudiosStatus.failure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudieron cargar las reservas.'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<StudiosCubit>().loadMyBookings(userId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state.myBookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }
          final upcoming = state.upcomingMyBookings;
          final past = state.pastMyBookings;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'MY BOOKINGS',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (upcoming.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Próximas Reservas'),
                    const SizedBox(height: 12),
                    ...upcoming.map(
                      (booking) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BookingCard(booking: booking),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (past.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Historial'),
                    const SizedBox(height: 12),
                    ...past.map(
                      (booking) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Opacity(
                          opacity: 0.7,
                          child: BookingCard(booking: booking),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
