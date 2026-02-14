import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/locator/locator.dart';

import '../../../../core/widgets/empty_state_card.dart';
import '../../repositories/events_repository.dart';
import '../../services/image_upload_service.dart';
import '../../models/event_entity.dart';
import '../widgets/event_text_template_card.dart';

part '../widgets/event_detail_body.dart';
part '../widgets/event_detail_models.dart';
part '../widgets/event_detail_logic.dart';
part '../widgets/event_detail_banner.dart';
part '../widgets/event_detail_components.dart';
part '../widgets/event_detail_sections.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.event});

  final EventEntity event;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late EventEntity _currentEvent;
  bool _isUploadingBanner = false;
  final ImageUploadService _imageUploadService = ImageUploadService();
  final EventsRepository _eventsRepository = locate<EventsRepository>();

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
  }

  Future<void> _copyEventTemplate(EventEntity event) async {
    final template = buildEventTextTemplate(context, event);
    await Clipboard.setData(ClipboardData(text: template));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ficha copiada al portapapeles')),
    );
  }

  void _showShareComingSoon() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Compartir: próximamente')));
  }

  Future<void> _uploadBanner() async {
    debugPrint('🎯 [EventDetail] Iniciando proceso de subida de banner');

    setState(() {
      _isUploadingBanner = true;
    });

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
        final savedEvent = await _eventsRepository.saveDraft(updatedEvent);

        setState(() {
          _currentEvent = savedEvent;
          _isUploadingBanner = false;
        });

        debugPrint('🎉 [EventDetail] Banner actualizado exitosamente');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Banner actualizado exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        debugPrint('⚠️ [EventDetail] No se recibió URL (usuario canceló)');
        setState(() {
          _isUploadingBanner = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [EventDetail] Error al subir banner: $e');
      debugPrint('Stack trace: $stackTrace');

      setState(() {
        _isUploadingBanner = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al subir el banner: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Ver detalles',
              textColor: Colors.white,
              onPressed: () {
                debugPrint('Detalles del error: $stackTrace');
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _EventDetailBody(
      event: _currentEvent,
      isUploadingBanner: _isUploadingBanner,
      onUploadBanner: _uploadBanner,
      onCopyTemplate: () => _copyEventTemplate(_currentEvent),
      onShare: _showShareComingSoon,
    );
  }
}
