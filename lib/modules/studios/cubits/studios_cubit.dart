import 'package:bloc/bloc.dart';

import '../models/studio_entity.dart';
import '../models/booking_entity.dart';
import '../models/room_entity.dart';
import '../repositories/studios_repository.dart';
import '../services/studio_image_service.dart';
import 'studios_state.dart';

class StudiosCubit extends Cubit<StudiosState> {
  StudiosCubit({
    required StudiosRepository repository,
    required StudioImageService imageService,
  }) : _repository = repository,
       _imageService = imageService,
       super(const StudiosState());

  final StudiosRepository _repository;
  final StudioImageService _imageService;
  static const _studiosPageSize = 20;

  void _safeEmit(StudiosState newState) {
    if (isClosed) return;
    emit(newState);
  }

  Future<void> loadAllStudios({bool refresh = false}) async {
    if (!refresh && (state.isLoadingStudiosMore || !state.hasMoreStudios)) {
      return;
    }
    final isInitialLoad = refresh || state.studios.isEmpty;
    _safeEmit(
      state.copyWith(
        status: isInitialLoad ? StudiosStatus.loading : state.status,
        isLoadingStudiosMore: !isInitialLoad,
        errorMessage: null,
      ),
    );
    try {
      final page = await _repository.getStudiosPage(
        cursor: isInitialLoad ? null : state.studiosCursor,
        limit: _studiosPageSize,
      );
      final studios = isInitialLoad
          ? page.items
          : <StudioEntity>[...state.studios, ...page.items];
      _safeEmit(
        state.copyWith(
          status: StudiosStatus.success,
          studios: studios,
          studiosCursor: page.nextCursor,
          hasMoreStudios: page.hasMore,
          isLoadingStudiosMore: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(
          status: isInitialLoad ? StudiosStatus.failure : state.status,
          isLoadingStudiosMore: false,
          errorMessage: e.toString(),
        ),
      );
    }
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

  Future<void> uploadMyStudioLogo(String studioId) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      final url = await _imageService.uploadStudioLogo(studioId);
      if (url != null && state.myStudio != null) {
        final updatedStudio = state.myStudio!.copyWith(logoUrl: url);
        await _repository.updateStudio(updatedStudio);
        _safeEmit(
          state.copyWith(
            status: StudiosStatus.success,
            myStudio: updatedStudio,
          ),
        );
      } else {
        _safeEmit(state.copyWith(status: StudiosStatus.success)); // No change
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

  Future<void> uploadMyStudioBanner(String studioId) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      final url = await _imageService.uploadStudioBanner(studioId);
      if (url != null && state.myStudio != null) {
        final updatedStudio = state.myStudio!.copyWith(bannerUrl: url);
        await _repository.updateStudio(updatedStudio);
        _safeEmit(
          state.copyWith(
            status: StudiosStatus.success,
            myStudio: updatedStudio,
          ),
        );
      } else {
        _safeEmit(state.copyWith(status: StudiosStatus.success)); // No change
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

  Future<void> selectStudio(String studioId) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      final studio = await _repository.getStudioById(studioId);
      if (studio != null) {
        final rooms = await _repository.getRoomsByStudio(studioId);
        _safeEmit(
          state.copyWith(
            status: StudiosStatus.success,
            selectedStudio: studio,
            myRooms: rooms,
            bookings: [], // Reset current view bookings if any
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
}
