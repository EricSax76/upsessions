import 'package:bloc/bloc.dart';

import '../models/booking_entity.dart';
import '../repositories/studios_repository.dart';
import 'musician_bookings_state.dart';
import 'studios_status.dart';

class BookingsCubit extends Cubit<MusicianBookingsState> {
  BookingsCubit({required StudiosRepository repository})
    : _repository = repository,
      super(const MusicianBookingsState());

  static const int _bookingsPageSize = 20;

  final StudiosRepository _repository;

  void _safeEmit(MusicianBookingsState newState) {
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
    _safeEmit(
      state.copyWith(
        status: StudiosStatus.loading,
        isLoadingMyBookingsMore: false,
        hasMoreMyBookings: true,
        myBookingsCursor: null,
        errorMessage: null,
      ),
    );
    try {
      final page = await _repository.getBookingsByUserPage(
        userId: userId,
        limit: _bookingsPageSize,
      );
      final sortedBookings = _sortedBookings(page.items);
      final sections = _splitBookings(sortedBookings);
      _safeEmit(
        state.copyWith(
          status: StudiosStatus.success,
          myBookings: sortedBookings,
          upcomingMyBookings: sections.upcoming,
          pastMyBookings: sections.past,
          hasMoreMyBookings: page.hasMore,
          myBookingsCursor: page.nextCursor,
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

  Future<void> loadMoreMyBookings(String userId) async {
    if (state.isLoadingMyBookingsMore || !state.hasMoreMyBookings) {
      return;
    }

    final cursor = state.myBookingsCursor;
    if (cursor == null || cursor.trim().isEmpty) {
      _safeEmit(state.copyWith(hasMoreMyBookings: false));
      return;
    }

    _safeEmit(
      state.copyWith(isLoadingMyBookingsMore: true, errorMessage: null),
    );
    try {
      final page = await _repository.getBookingsByUserPage(
        userId: userId,
        cursor: cursor,
        limit: _bookingsPageSize,
      );
      final mergedBookings = _mergeBookings(state.myBookings, page.items);
      final sections = _splitBookings(mergedBookings);
      _safeEmit(
        state.copyWith(
          status: StudiosStatus.success,
          myBookings: mergedBookings,
          upcomingMyBookings: sections.upcoming,
          pastMyBookings: sections.past,
          hasMoreMyBookings: page.hasMore,
          myBookingsCursor: page.nextCursor,
          isLoadingMyBookingsMore: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(
          isLoadingMyBookingsMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadStudioBookings(String studioId) async {
    _safeEmit(
      state.copyWith(
        status: StudiosStatus.loading,
        isLoadingStudioBookingsMore: false,
        hasMoreStudioBookings: true,
        studioBookingsCursor: null,
        errorMessage: null,
      ),
    );
    try {
      final page = await _repository.getBookingsByStudioPage(
        studioId: studioId,
        limit: _bookingsPageSize,
      );
      _safeEmit(
        state.copyWith(
          status: StudiosStatus.success,
          studioBookings: _sortedBookings(page.items),
          hasMoreStudioBookings: page.hasMore,
          studioBookingsCursor: page.nextCursor,
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

  Future<void> loadMoreStudioBookings(String studioId) async {
    if (state.isLoadingStudioBookingsMore || !state.hasMoreStudioBookings) {
      return;
    }

    final cursor = state.studioBookingsCursor;
    if (cursor == null || cursor.trim().isEmpty) {
      _safeEmit(state.copyWith(hasMoreStudioBookings: false));
      return;
    }

    _safeEmit(
      state.copyWith(isLoadingStudioBookingsMore: true, errorMessage: null),
    );
    try {
      final page = await _repository.getBookingsByStudioPage(
        studioId: studioId,
        cursor: cursor,
        limit: _bookingsPageSize,
      );
      final merged = _mergeBookings(state.studioBookings, page.items);
      _safeEmit(
        state.copyWith(
          status: StudiosStatus.success,
          studioBookings: merged,
          hasMoreStudioBookings: page.hasMore,
          studioBookingsCursor: page.nextCursor,
          isLoadingStudioBookingsMore: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(
          isLoadingStudioBookingsMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  static List<BookingEntity> _sortedBookings(Iterable<BookingEntity> bookings) {
    final sorted = List<BookingEntity>.from(bookings);
    sorted.sort((a, b) {
      final byStart = b.startTime.compareTo(a.startTime);
      if (byStart != 0) return byStart;
      return b.id.compareTo(a.id);
    });
    return sorted;
  }

  static List<BookingEntity> _mergeBookings(
    List<BookingEntity> existing,
    List<BookingEntity> incoming,
  ) {
    final byId = <String, BookingEntity>{
      for (final booking in existing) booking.id: booking,
    };
    for (final booking in incoming) {
      byId[booking.id] = booking;
    }
    return _sortedBookings(byId.values);
  }

  static ({List<BookingEntity> upcoming, List<BookingEntity> past})
  _splitBookings(List<BookingEntity> sortedBookings) {
    final now = DateTime.now();
    final upcoming =
        sortedBookings
            .where((booking) => !booking.startTime.isBefore(now))
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final past = sortedBookings
        .where((booking) => booking.startTime.isBefore(now))
        .toList();
    return (upcoming: upcoming, past: past);
  }
}
