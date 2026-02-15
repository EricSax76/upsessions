import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/locator/locator.dart';
import '../models/announcement_entity.dart';
import '../repositories/announcements_repository.dart';
import '../services/announcement_image_service.dart';

part 'announcement_form_state.dart';

class AnnouncementFormCubit extends Cubit<AnnouncementFormState> {
  AnnouncementFormCubit({
    AnnouncementsRepository? repository,
    AnnouncementImageService? imageService,
  })  : _repository = repository ?? locate<AnnouncementsRepository>(),
        _imageService = imageService ?? locate<AnnouncementImageService>(),
        super(const AnnouncementFormState());

  final AnnouncementsRepository _repository;
  final AnnouncementImageService _imageService;

  Future<void> submit({
    required AnnouncementEntity entity,
    required String authorId,
    required String authorName,
    XFile? pickedImage,
  }) async {
    if (state.status == AnnouncementFormStatus.submitting) return;
    emit(state.copyWith(status: AnnouncementFormStatus.submitting));

    try {
      final enriched = entity.copyWith(authorId: authorId, author: authorName);

      String? imageUrl;
      if (pickedImage != null) {
        imageUrl = await _imageService.uploadImage(pickedImage);
      }

      await _repository.create(enriched.copyWith(imageUrl: imageUrl));
      
      emit(state.copyWith(status: AnnouncementFormStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: AnnouncementFormStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
