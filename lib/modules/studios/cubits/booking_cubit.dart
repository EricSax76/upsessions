import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';
import 'package:upsessions/modules/studios/models/booking_entity.dart';
import 'package:upsessions/modules/studios/repositories/studios_repository.dart';
import 'package:upsessions/modules/studios/ui/consumer/studios_list_page.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit({
    required this.roomPricePerHour,
    required this.roomId,
    required this.roomName,
    required this.studioId,
    required this.studioName,
    this.rehearsalContext,
    AuthRepository? authRepository,
    StudiosRepository? studiosRepository,
    RehearsalsRepository? rehearsalsRepository,
  })  : _authRepository = authRepository ?? locate<AuthRepository>(),
        _studiosRepository = studiosRepository ?? locate<StudiosRepository>(),
        _rehearsalsRepository = rehearsalsRepository ?? locate<RehearsalsRepository>(),
        super(const BookingState()) {
    _initialize();
  }

  final double roomPricePerHour;
  final String roomId;
  final String roomName;
  final String studioId;
  final String studioName;
  final RehearsalBookingContext? rehearsalContext;

  final AuthRepository _authRepository;
  final StudiosRepository _studiosRepository;
  final RehearsalsRepository _rehearsalsRepository;

  void _initialize() {
    if (rehearsalContext != null) {
      final date = rehearsalContext!.suggestedDate;
      final time = TimeOfDay(hour: date.hour, minute: date.minute);
      int duration = 2;

      if (rehearsalContext!.suggestedEndDate != null) {
        final diff = rehearsalContext!.suggestedEndDate!.difference(date);
        duration = diff.inHours.clamp(1, 8);
      }

      emit(state.copyWith(
        selectedDate: date,
        selectedTime: time,
        durationHours: duration,
        totalPrice: roomPricePerHour * duration,
      ));
    } else {
      emit(state.copyWith(
        selectedDate: DateTime.now(),
        selectedTime: const TimeOfDay(hour: 10, minute: 0),
        durationHours: 2,
        totalPrice: roomPricePerHour * 2,
      ));
    }
  }

  void dateChanged(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void timeChanged(TimeOfDay time) {
    emit(state.copyWith(selectedTime: time));
  }

  void durationChanged(int duration) {
    emit(state.copyWith(
      durationHours: duration,
      totalPrice: roomPricePerHour * duration,
    ));
  }

  Future<void> confirmBooking() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(state.copyWith(
        status: BookingFormStatus.failure,
        errorMessage: 'Debes iniciar sesión para reservar.',
      ));
      return;
    }

    emit(state.copyWith(status: BookingFormStatus.loading));

    try {
      final date = state.selectedDate!;
      final time = state.selectedTime!;
      
      final startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      final endDateTime = startDateTime.add(Duration(hours: state.durationHours));
      final bookingId = const Uuid().v4();

      final booking = BookingEntity(
        id: bookingId,
        roomId: roomId,
        roomName: roomName,
        studioId: studioId,
        studioName: studioName,
        ownerId: user.id,
        startTime: startDateTime,
        endTime: endDateTime,
        status: BookingStatus.confirmed,
        totalPrice: state.totalPrice,
        rehearsalId: rehearsalContext?.rehearsalId,
        groupId: rehearsalContext?.groupId,
      );

      await _studiosRepository.createBooking(booking);

      if (rehearsalContext != null) {
        await _rehearsalsRepository.updateRehearsalBooking(
          groupId: rehearsalContext!.groupId,
          rehearsalId: rehearsalContext!.rehearsalId,
          bookingId: bookingId,
        );
      }

      emit(state.copyWith(status: BookingFormStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: BookingFormStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
