import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/studios_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../models/booking_entity.dart';
import 'widgets/booking_card.dart';
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

            final now = DateTime.now();
            final sortedBookings = List<BookingEntity>.from(state.myBookings)
              ..sort(
                (a, b) => b.startTime.compareTo(a.startTime),
              ); // Newest first

            final upcoming =
                sortedBookings.where((b) => b.startTime.isAfter(now)).toList()
                  ..sort(
                    (a, b) => a.startTime.compareTo(b.startTime),
                  ); // Nearest future first

            final past = sortedBookings
                .where((b) => b.startTime.isBefore(now))
                .toList();

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    if (isWide) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: CustomScrollView(
                          slivers: [
                            if (upcoming.isNotEmpty) ...[
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child:
                                      _buildSectionTitle(context, 'Próximas Reservas'),
                                ),
                              ),
                              SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  mainAxisExtent: 180, // Adjustable height for premium card
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return BookingCard(booking: upcoming[index]);
                                  },
                                  childCount: upcoming.length,
                                ),
                              ),
                              const SliverToBoxAdapter(child: SizedBox(height: 32)),
                            ],
                            if (past.isNotEmpty) ...[
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildSectionTitle(context, 'Historial'),
                                ),
                              ),
                              SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  mainAxisExtent: 180,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return Opacity(
                                      opacity: 0.7,
                                      child: BookingCard(booking: past[index]),
                                    );
                                  },
                                  childCount: past.length,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    // Mobile Layout
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
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
                    );
                  },
                ),
              ),
            );
          },
        ),
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
