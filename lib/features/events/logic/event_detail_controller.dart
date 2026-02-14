import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/event_entity.dart';
import '../repositories/events_repository.dart';
import '../services/image_upload_service.dart';

/// Possible side-effects the UI should react to after a controller action.
enum EventDetailEffect {
  bannerUpdated,
  bannerCancelled,
  templateCopied,
  shareComingSoon,
}

class EventDetailController extends ChangeNotifier {
  EventDetailController({
    required EventEntity event,
    required EventsRepository repository,
    ImageUploadService? imageUploadService,
  })  : _currentEvent = event,
        _repository = repository,
        _imageUploadService = imageUploadService ?? ImageUploadService();

  final EventsRepository _repository;
  final ImageUploadService _imageUploadService;

  bool _isDisposed = false;

  // ── State ──────────────────────────────────────
  EventEntity _currentEvent;
  bool _isUploadingBanner = false;
  EventDetailEffect? _lastEffect;
  Object? _lastError;

  EventEntity get currentEvent => _currentEvent;
  bool get isUploadingBanner => _isUploadingBanner;

  /// Consumable side-effect. Read once, then cleared.
  EventDetailEffect? consumeEffect() {
    final effect = _lastEffect;
    _lastEffect = null;
    return effect;
  }

  /// Consumable error. Read once, then cleared.
  Object? consumeError() {
    final error = _lastError;
    _lastError = null;
    return error;
  }

  // ── Actions ────────────────────────────────────

  Future<void> uploadBanner() async {
    debugPrint('🎯 [EventDetail] Iniciando proceso de subida de banner');
    _isUploadingBanner = true;
    _safeNotify();

    try {
      debugPrint(
        '📸 [EventDetail] Llamando a uploadEventBanner con ID: ${_currentEvent.id}',
      );
      final imageUrl = await _imageUploadService.uploadEventBanner(
        _currentEvent.id,
      );

      if (imageUrl != null) {
        debugPrint('✅ [EventDetail] URL recibida: $imageUrl');
        debugPrint(
          '💾 [EventDetail] Guardando evento actualizado en Firestore',
        );

        final updatedEvent = _currentEvent.copyWith(bannerImageUrl: imageUrl);
        final savedEvent = await _repository.saveDraft(updatedEvent);

        _currentEvent = savedEvent;
        _isUploadingBanner = false;
        _lastEffect = EventDetailEffect.bannerUpdated;
        debugPrint('🎉 [EventDetail] Banner actualizado exitosamente');
      } else {
        debugPrint('⚠️ [EventDetail] No se recibió URL (usuario canceló)');
        _isUploadingBanner = false;
        _lastEffect = EventDetailEffect.bannerCancelled;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [EventDetail] Error al subir banner: $e');
      debugPrint('Stack trace: $stackTrace');
      _isUploadingBanner = false;
      _lastError = e;
    }

    _safeNotify();
  }

  /// Copies the event template to clipboard.
  /// [templateBuilder] converts the current event into the localized text
  /// (requires BuildContext, so the UI provides it).
  Future<void> copyEventTemplate(String Function(EventEntity) templateBuilder) async {
    final template = templateBuilder(_currentEvent);
    await Clipboard.setData(ClipboardData(text: template));
    _lastEffect = EventDetailEffect.templateCopied;
    _safeNotify();
  }

  void shareEvent() {
    _lastEffect = EventDetailEffect.shareComingSoon;
    _safeNotify();
  }

  // ── Internal ───────────────────────────────────

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
