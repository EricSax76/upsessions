import 'package:bloc/bloc.dart';

import '../models/studio_entity.dart';
import '../repositories/studios_repository.dart';
import 'studios_list_state.dart';
import 'studios_status.dart';

class StudiosListCubit extends Cubit<StudiosListState> {
  StudiosListCubit({required StudiosRepository repository})
    : _repository = repository,
      super(const StudiosListState());

  final StudiosRepository _repository;
  static const _studiosPageSize = 20;

  void _safeEmit(StudiosListState newState) {
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
            selectedStudioRooms: rooms,
            errorMessage: null,
          ),
        );
      } else {
        _safeEmit(
          state.copyWith(
            status: StudiosStatus.failure,
            errorMessage: 'No se encontro el estudio solicitado.',
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
