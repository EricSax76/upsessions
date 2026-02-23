import 'package:bloc/bloc.dart';

import '../models/studio_entity.dart';
import '../repositories/studios_repository.dart';
import '../services/studio_image_service.dart';
import 'studios_state.dart';

class StudioMediaCubit extends Cubit<StudiosState> {
  StudioMediaCubit({
    required StudiosRepository repository,
    required StudioImageService imageService,
  }) : _repository = repository,
       _imageService = imageService,
       super(const StudiosState());

  final StudiosRepository _repository;
  final StudioImageService _imageService;

  void _safeEmit(StudiosState newState) {
    if (isClosed) return;
    emit(newState);
  }

  Future<void> uploadStudioLogo(StudioEntity studio) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      final url = await _imageService.uploadStudioLogo(studio.id);
      if (url == null) {
        _safeEmit(
          state.copyWith(status: StudiosStatus.success, myStudio: studio),
        );
        return;
      }
      final updatedStudio = studio.copyWith(logoUrl: url);
      await _repository.updateStudio(updatedStudio);
      _safeEmit(
        state.copyWith(status: StudiosStatus.success, myStudio: updatedStudio),
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

  Future<void> uploadStudioBanner(StudioEntity studio) async {
    _safeEmit(state.copyWith(status: StudiosStatus.loading));
    try {
      final url = await _imageService.uploadStudioBanner(studio.id);
      if (url == null) {
        _safeEmit(
          state.copyWith(status: StudiosStatus.success, myStudio: studio),
        );
        return;
      }
      final updatedStudio = studio.copyWith(bannerUrl: url);
      await _repository.updateStudio(updatedStudio);
      _safeEmit(
        state.copyWith(status: StudiosStatus.success, myStudio: updatedStudio),
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
}
