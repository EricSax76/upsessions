import 'package:flutter/material.dart';

import '../../../../core/locator/locator.dart';
import '../../logic/event_detail_controller.dart';
import '../../models/event_entity.dart';
import '../../repositories/events_repository.dart';
import '../widgets/event_text_template_card.dart';
import '../widgets/event_detail/event_detail_body.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({super.key, required this.event});

  final EventEntity event;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late final EventDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EventDetailController(
      event: widget.event,
      repository: locate<EventsRepository>(),
    );
    _controller.addListener(_handleControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _handleControllerUpdate() {
    final error = _controller.consumeError();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al subir el banner: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final effect = _controller.consumeEffect();
    if (effect == null) return;

    switch (effect) {
      case EventDetailEffect.bannerUpdated:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Banner actualizado exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      case EventDetailEffect.templateCopied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ficha copiada al portapapeles')),
        );
      case EventDetailEffect.shareComingSoon:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compartir: próximamente')),
        );
      case EventDetailEffect.bannerCancelled:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => EventDetailBody(
        event: _controller.currentEvent,
        isUploadingBanner: _controller.isUploadingBanner,
        onUploadBanner: _controller.uploadBanner,
        onCopyTemplate: () => _controller.copyEventTemplate(
          (event) => buildEventTextTemplate(context, event),
        ),
        onShare: _controller.shareEvent,
      ),
    );
  }
}
