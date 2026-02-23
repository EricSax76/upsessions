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
          _repository.getBookingsByStudio(studio.id),
        ]);
        final rooms = results[0] as List<RoomEntity>;
        final bookings = results[1] as List<BookingEntity>;
        _safeEmit(
          state.copyWith(
            status: StudiosStatus.success,
            myStudio: studio,
            myRooms: rooms,
            studioBookings: bookings,
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
}
