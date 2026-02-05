import 'package:bloc/bloc.dart';
import 'package:upsessions/core/locator/locator.dart';
import '../models/studio_entity.dart';
import '../models/booking_entity.dart';
import '../models/room_entity.dart';
import '../repositories/studios_repository.dart';
import '../services/studio_image_service.dart';
import 'studios_state.dart';

class StudiosCubit extends Cubit<StudiosState> {
  StudiosCubit({
    StudiosRepository? repository,
    StudioImageService? imageService,
  })  : _repository = repository ?? locate<StudiosRepository>(),
        _imageService = imageService ?? locate<StudioImageService>(),
        super(const StudiosState());

  final StudiosRepository _repository;
  final StudioImageService _imageService;

  void _safeEmit(StudiosState newState) {
    if (isClosed) return;
    emit(newState);
  }

  Future<void> loadAllStudios() async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      final studios = await _repository.getAllStudios();
      _safeEmit(state.copyWith(status: StudiosStatus.success, studios: studios));
    } catch (e) {
      _safeEmit(state.copyWith(status: StudiosStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> loadMyStudio(String userId) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      final studio = await _repository.getStudioByOwner(userId);
      if (studio != null) {
        final rooms = await _repository.getRoomsByStudio(studio.id);
        _safeEmit(state.copyWith(
          status: StudiosStatus.success,
          myStudio: studio,
          myRooms: rooms,
        ));
        // Chain loading bookings
        loadStudioBookings(studio.id);
      } else {
        _safeEmit(state.copyWith(status: StudiosStatus.success, myStudio: null, myRooms: []));
      }
    } catch (e) {
      _safeEmit(state.copyWith(status: StudiosStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> createStudio(StudioEntity studio) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      await _repository.createStudio(studio);
      _safeEmit(state.copyWith(status: StudiosStatus.success, myStudio: studio));
    } catch (e) {
      _safeEmit(state.copyWith(status: StudiosStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> updateMyStudio(StudioEntity studio) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      await _repository.updateStudio(studio);
      _safeEmit(state.copyWith(status: StudiosStatus.success, myStudio: studio));
    } catch (e) {
      _safeEmit(state.copyWith(status: StudiosStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> uploadMyStudioLogo(String studioId) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      final url = await _imageService.uploadStudioLogo(studioId);
      if (url != null && state.myStudio != null) {
        final updatedStudio = state.myStudio!.copyWith(logoUrl: url);
        await _repository.updateStudio(updatedStudio);
        _safeEmit(state.copyWith(status: StudiosStatus.success, myStudio: updatedStudio));
      } else {
        _safeEmit(state.copyWith(status: StudiosStatus.success)); // No change
      }
    } catch (e) {
      _safeEmit(state.copyWith(status: StudiosStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> uploadMyStudioBanner(String studioId) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      final url = await _imageService.uploadStudioBanner(studioId);
      if (url != null && state.myStudio != null) {
        final updatedStudio = state.myStudio!.copyWith(bannerUrl: url);
        await _repository.updateStudio(updatedStudio);
        _safeEmit(state.copyWith(status: StudiosStatus.success, myStudio: updatedStudio));
      } else {
        _safeEmit(state.copyWith(status: StudiosStatus.success)); // No change
      }
    } catch (e) {
      _safeEmit(state.copyWith(status: StudiosStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> createRoom(RoomEntity room) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      await _repository.createRoom(room);
      final rooms = await _repository.getRoomsByStudio(room.studioId);
      _safeEmit(state.copyWith(status: StudiosStatus.success, myRooms: rooms));
    } catch (e) {
      _safeEmit(state.copyWith(status: StudiosStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> createBooking(BookingEntity booking) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      await _repository.createBooking(booking);
      _safeEmit(state.copyWith(status: StudiosStatus.success));
    } catch (e) {
      _safeEmit(state.copyWith(status: StudiosStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> loadMyBookings(String userId) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      final bookings = await _repository.getBookingsByUser(userId);
      _safeEmit(state.copyWith(status: StudiosStatus.success, myBookings: bookings));
    } catch (e) {
      _safeEmit(state.copyWith(status: StudiosStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> loadStudioBookings(String studioId) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      final bookings = await _repository.getBookingsByStudio(studioId);
      _safeEmit(state.copyWith(status: StudiosStatus.success, studioBookings: bookings));
    } catch (e) {
      _safeEmit(state.copyWith(status: StudiosStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> selectStudio(String studioId) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      final studio = await _repository.getStudioById(studioId);
      if (studio != null) {
        final rooms = await _repository.getRoomsByStudio(studioId);
        _safeEmit(state.copyWith(
          status: StudiosStatus.success,
          selectedStudio: studio,
          myRooms: rooms,
          bookings: [], // Reset current view bookings if any
        ));
      }
    } catch (e) {
      _safeEmit(state.copyWith(status: StudiosStatus.failure, errorMessage: e.toString()));
    }
  }
}
