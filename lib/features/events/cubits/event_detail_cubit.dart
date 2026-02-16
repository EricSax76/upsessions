import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/event_entity.dart';
import '../repositories/events_repository.dart';
import '../services/image_upload_service.dart';
import 'event_detail_state.dart';

class EventDetailCubit extends Cubit<EventDetailState> {
  EventDetailCubit({
    required EventEntity event,
    required EventsRepository repository,
    required ImageUploadService imageUploadService,
  })  : _repository = repository,
        _imageUploadService = imageUploadService,
        super(EventDetailState(event: event));

  final EventsRepository _repository;
  final ImageUploadService _imageUploadService;

  Future<void> uploadBanner() async {
    debugPrint('🎯 [EventDetailCubit] Iniciando proceso de subida de banner');
    emit(state.copyWith(status: EventDetailStatus.uploadingBanner));

    try {
      final imageUrl = await _imageUploadService.uploadEventBanner(
        state.event.id,
      );

      if (isClosed) return;

      if (imageUrl != null) {
        debugPrint('✅ [EventDetailCubit] URL recibida: $imageUrl');
        final updatedEvent = state.event.copyWith(bannerImageUrl: imageUrl);
        final savedEvent = await _repository.saveDraft(updatedEvent);

        if (isClosed) return;
        emit(state.copyWith(
          event: savedEvent,
          status: EventDetailStatus.idle,
          effect: EventDetailEffect.bannerUpdated,
        ));
      } else {
        debugPrint('⚠️ [EventDetailCubit] Usuario canceló');
        emit(state.copyWith(
          status: EventDetailStatus.idle,
          effect: EventDetailEffect.bannerCancelled,
        ));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [EventDetailCubit] Error al subir banner: $e');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      if (!isClosed) {
        emit(state.copyWith(
          status: EventDetailStatus.idle,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> copyEventTemplate(
    String Function(EventEntity) templateBuilder,
  ) async {
    final template = templateBuilder(state.event);
    await Clipboard.setData(ClipboardData(text: template));
    if (!isClosed) {
      emit(state.copyWith(effect: EventDetailEffect.templateCopied));
    }
  }

  void shareEvent() {
    emit(state.copyWith(effect: EventDetailEffect.shareComingSoon));
  }

  /// Clear effect after the UI has consumed it.
  void clearEffect() {
    emit(state.copyWith());
  }
}
