import 'package:bloc/bloc.dart';

import '../models/booking_entity.dart';
import '../models/room_entity.dart';
import '../models/studio_entity.dart';
import '../repositories/studios_repository.dart';
import 'studios_state.dart';

class MyStudioCubit extends Cubit<StudiosState> {
  MyStudioCubit({required StudiosRepository repository})
    : _repository = repository,
      super(const StudiosState());

  static const int _studioBookingsPageSize = 20;

  final StudiosRepository _repository;

  void _safeEmit(StudiosState newState) {
    if (isClosed) return;
    emit(newState);
  }

  Future<void> loadMyStudio(String userId) async {
    _safeEmit(
      state.copyWith(status: StudiosStatus.loading, errorMessage: null),
    );
    try {
      final studio = await _repository.getStudioByOwner(userId);
      if (studio != null) {
        final results = await Future.wait([
          _repository.getRoomsByStudio(studio.id),
          _repository.getBookingsByStudioPage(
            studioId: studio.id,
            limit: _studioBookingsPageSize,
          ),
        ]);
        final rooms = results[0] as List<RoomEntity>;
        final bookingsPage = results[1] as BookingsPage;
        _safeEmit(
          state.copyWith(
            status: StudiosStatus.success,
            myStudio: studio,
            myRooms: rooms,
            studioBookings: _sortedBookings(bookingsPage.items),
            hasMoreStudioBookings: bookingsPage.hasMore,
            studioBookingsCursor: bookingsPage.nextCursor,
            isLoadingStudioBookingsMore: false,
            errorMessage: null,
          ),
        );
      } else {
        _safeEmit(
          state.copyWith(
            status: StudiosStatus.success,
            myStudio: null,
            myRooms: const [],
            studioBookings: const [],
            hasMoreStudioBookings: false,
            isLoadingStudioBookingsMore: false,
            studioBookingsCursor: null,
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      _safeEmit(
        state.copyWith(
          status: StudiosStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> loadMoreStudioBookings() async {
    final studio = state.myStudio;
    if (studio == null ||
        state.isLoadingStudioBookingsMore ||
        !state.hasMoreStudioBookings) {
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
        studioId: studio.id,
        cursor: cursor,
        limit: _studioBookingsPageSize,
      );
      _safeEmit(
        state.copyWith(
          status: StudiosStatus.success,
          studioBookings: _mergeBookings(state.studioBookings, page.items),
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

  Future<void> createStudio(StudioEntity studio) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      await _repository.createStudio(studio);
      _safeEmit(
        state.copyWith(status: StudiosStatus.success, myStudio: studio),
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

  Future<void> updateMyStudio(StudioEntity studio) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      await _repository.updateStudio(studio);
      _safeEmit(
        state.copyWith(status: StudiosStatus.success, myStudio: studio),
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

  Future<void> createRoom(RoomEntity room) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      await _repository.createRoom(room);
      final rooms = await _repository.getRoomsByStudio(room.studioId);
      _safeEmit(state.copyWith(status: StudiosStatus.success, myRooms: rooms));
    } catch (e) {
      _safeEmit(
        state.copyWith(
          status: StudiosStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void replaceMyStudio(StudioEntity studio) {
    _safeEmit(state.copyWith(status: StudiosStatus.success, myStudio: studio));
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
}
