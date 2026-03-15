import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../cubits/bookings_cubit.dart';
import '../../cubits/musician_bookings_state.dart';
import '../../cubits/studios_status.dart';
import 'widgets/booking_card.dart';
import '../../repositories/studios_repository.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../../../core/locator/locator.dart';

class MusicianBookingsPage extends StatefulWidget {
  const MusicianBookingsPage({super.key});

  @override
  State<MusicianBookingsPage> createState() => _MusicianBookingsPageState();
}

class _MusicianBookingsPageState extends State<MusicianBookingsPage> {
  late final String? _userId;
  BookingsCubit? _cubit;

  @override
  void initState() {
    super.initState();
    final authRepo = locate<AuthRepository>();
    _userId = authRepo.currentUser?.id;
    final userId = _userId;
    if (userId != null) {
      _cubit = BookingsCubit(repository: locate<StudiosRepository>())
        ..loadMyBookings(userId);
    }
  }

  @override
  void dispose() {
    _cubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final userId = _userId;
    if (userId == null) {
      return Center(child: Text(loc.musicianBookingsLoginRequired));
    }

    return BlocProvider.value(
      value: _cubit!,
      child: BlocBuilder<BookingsCubit, MusicianBookingsState>(
        builder: (context, state) {
          if (state.status == StudiosStatus.loading ||
              (state.status == StudiosStatus.initial &&
                  state.myBookings.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == StudiosStatus.failure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(loc.musicianBookingsLoadError),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<BookingsCubit>().loadMyBookings(userId),
                    icon: const Icon(Icons.refresh),
                    label: Text(loc.musicianBookingsRetry),
                  ),
                ],
              ),
            );
          }
          if (state.myBookings.isEmpty &&
              !state.isLoadingMyBookingsMore &&
              !state.hasMoreMyBookings) {
            return Center(child: Text(loc.musicianBookingsEmpty));
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
                    loc.musicianBookingsTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (upcoming.isNotEmpty) ...[
                    _buildSectionTitle(context, loc.musicianBookingsUpcoming),
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
                    _buildSectionTitle(context, loc.musicianBookingsHistory),
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
                  const SizedBox(height: 8),
                  if (state.isLoadingMyBookingsMore)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (state.hasMoreMyBookings)
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () => context
                            .read<BookingsCubit>()
                            .loadMoreMyBookings(userId),
                        icon: const Icon(Icons.expand_more),
                        label: Text(loc.musicianBookingsLoadMore),
                      ),
                    ),
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
