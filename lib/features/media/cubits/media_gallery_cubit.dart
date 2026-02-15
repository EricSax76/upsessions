import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/media_repository.dart';
import 'media_gallery_state.dart';

class MediaGalleryCubit extends Cubit<MediaGalleryState> {
  MediaGalleryCubit({required MediaRepository repository})
      : _repository = repository,
        super(const MediaGalleryState());

  final MediaRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: MediaGalleryStatus.loading));
    try {
      final items = await _repository.fetchMedia();
      if (isClosed) return;
      emit(state.copyWith(
        status: MediaGalleryStatus.loaded,
        items: items,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: MediaGalleryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
