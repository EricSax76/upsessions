import 'package:bloc/bloc.dart';

import '../models/booking_entity.dart';
import '../repositories/studios_repository.dart';
import 'studios_state.dart';

class BookingsCubit extends Cubit<StudiosState> {
  BookingsCubit({required StudiosRepository repository})
    : _repository = repository,
      super(const StudiosState());

  final StudiosRepository _repository;

  void _safeEmit(StudiosState newState) {
    if (isClosed) return;
    emit(newState);
  }

  Future<void> createBooking(BookingEntity booking) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      await _repository.createBooking(booking);
      _safeEmit(state.copyWith(status: StudiosStatus.success));
    } catch (e) {
      _safeEmit(
        state.copyWith(
          status: StudiosStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadMyBookings(String userId) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      final bookings = await _repository.getBookingsByUser(userId);
      final now = DateTime.now();
      final sortedBookings = List<BookingEntity>.from(bookings)
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
      final upcoming =
          sortedBookings
              .where((booking) => !booking.startTime.isBefore(now))
              .toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));
      final past = sortedBookings
          .where((booking) => booking.startTime.isBefore(now))
          .toList();
      _safeEmit(
        state.copyWith(
          status: StudiosStatus.success,
          myBookings: sortedBookings,
          upcomingMyBookings: upcoming,
          pastMyBookings: past,
          errorMessage: null,
        ),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(
          status: StudiosStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadStudioBookings(String studioId) async {
    try {
      final bookings = await _repository.getBookingsByStudio(studioId);
      _safeEmit(
        state.copyWith(
          status: StudiosStatus.success,
          studioBookings: bookings,
          errorMessage: null,
        ),
      );
    } catch (e) {
      _safeEmit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
