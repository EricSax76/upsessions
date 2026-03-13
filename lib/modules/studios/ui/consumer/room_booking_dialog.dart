import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_routes.dart';
import '../../cubits/booking_cubit.dart';
import '../../models/booking_entity.dart';

class RoomBookingDialog extends StatelessWidget {
  const RoomBookingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BookingCubit>();
    final isFromRehearsal = cubit.rehearsalContext != null;
    final loc = AppLocalizations.of(context);
    final materialLoc = MaterialLocalizations.of(context);

    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state.status == BookingFormStatus.success) {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isFromRehearsal
                    ? loc.roomDetailBookingSuccessForRehearsal(
                        state.totalPrice.toStringAsFixed(2),
                      )
                    : loc.roomDetailBookingSuccess(
                        state.totalPrice.toStringAsFixed(2),
                      ),
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
            SnackBar(
              content: Text(state.errorMessage ?? loc.roomDetailBookingError),
            ),
          );
        }
      },
      child: AlertDialog(
        title: Text(
          isFromRehearsal
              ? loc.roomDetailBookForRehearsal
              : loc.roomDetailBookRoom,
        ),
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
                              loc.roomDetailPrefilledFromRehearsal,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ListTile(
                    title: Text(loc.roomDetailDateLabel),
                    subtitle: Text(
                      state.selectedDate != null
                          ? materialLoc.formatMediumDate(state.selectedDate!)
                          : loc.roomDetailSelectDate,
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
                    title: Text(loc.roomDetailStartTimeLabel),
                    subtitle: Text(
                      state.selectedTime?.format(context) ??
                          loc.roomDetailSelectTime,
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
                    loc.roomDetailDurationHours(state.durationHours),
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
                  const SizedBox(height: 8),
                  DropdownButtonFormField<BookingPaymentMethod>(
                    initialValue: state.paymentMethod,
                    decoration: InputDecoration(
                      labelText: loc.roomDetailPaymentMethodLabel,
                    ),
                    items: BookingPaymentMethod.values
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(_paymentMethodLabel(m, loc)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        context
                            .read<BookingCubit>()
                            .paymentMethodChanged(v);
                      }
                    },
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.roomDetailTotalPriceLabel,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${state.totalPrice.toStringAsFixed(2)}€',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.roomDetailVatLabel,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${(state.totalPrice * 0.21).toStringAsFixed(2)}€',
                          style: Theme.of(context).textTheme.bodyMedium,
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
            child: Text(loc.cancel),
          ),
          BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              return FilledButton(
                onPressed: state.status == BookingFormStatus.loading
                    ? null
                    : () => context.read<BookingCubit>().confirmBooking(),
                child: Text(
                  isFromRehearsal
                      ? loc.roomDetailConfirmBookingForRehearsal
                      : loc.roomDetailConfirmBooking,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static String _paymentMethodLabel(
    BookingPaymentMethod method,
    AppLocalizations loc,
  ) {
    switch (method) {
      case BookingPaymentMethod.card:
        return loc.paymentMethodCard;
      case BookingPaymentMethod.transfer:
        return loc.paymentMethodTransfer;
      case BookingPaymentMethod.cash:
        return loc.paymentMethodCash;
      case BookingPaymentMethod.bizum:
        return loc.paymentMethodBizum;
    }
  }
}
