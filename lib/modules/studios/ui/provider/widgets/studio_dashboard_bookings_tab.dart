import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../cubits/my_studio_cubit.dart';
import '../../../cubits/studios_state.dart';
import '../../widgets/empty_states/no_bookings_empty_state.dart';

class StudioDashboardBookingsTab extends StatelessWidget {
  const StudioDashboardBookingsTab({super.key, required this.state});

  final StudiosState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bookings = state.studioBookings;
    final showFooter =
        state.isLoadingStudioBookingsMore || state.hasMoreStudioBookings;
    final loc = AppLocalizations.of(context);

    if (bookings.isEmpty && !showFooter) {
      return const NoBookingsEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: bookings.length + 1,
      itemBuilder: (context, index) {
        if (index == bookings.length) {
          if (state.isLoadingStudioBookingsMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (state.hasMoreStudioBookings) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      context.read<MyStudioCubit>().loadMoreStudioBookings(),
                  icon: const Icon(Icons.expand_more),
                  label: Text(loc.studioDashboardLoadMoreBookings),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final booking = bookings[index];
        final materialLoc = MaterialLocalizations.of(context);
        final startDate = materialLoc.formatShortDate(booking.startTime);
        final startTime = materialLoc.formatTimeOfDay(
          TimeOfDay.fromDateTime(booking.startTime),
          alwaysUse24HourFormat: true,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.calendar_today, color: colorScheme.tertiary),
            ),
            title: Text(
              booking.roomName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('$startDate - $startTime'),
                Text(
                  loc.studioDashboardBookingTotal(
                    booking.totalPrice.toStringAsFixed(0),
                  ),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: Chip(
              label: Text(
                booking.status.name,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 12,
                ),
              ),
              backgroundColor: colorScheme.primaryContainer,
              side: BorderSide.none,
            ),
          ),
        );
      },
    );
  }
}
