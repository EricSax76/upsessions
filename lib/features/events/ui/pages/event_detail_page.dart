import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/event_detail_cubit.dart';
import '../../cubits/event_detail_state.dart';
import '../../models/event_entity.dart';
import '../../repositories/events_repository.dart';
import '../widgets/event_text_template_card.dart';
import '../widgets/event_detail/event_detail_body.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({
    super.key,
    required this.event,
    required this.eventsRepository,
  });

  final EventEntity event;
  final EventsRepository eventsRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventDetailCubit(
        event: event,
        repository: eventsRepository,
      ),
      child: BlocListener<EventDetailCubit, EventDetailState>(
        listenWhen: (previous, current) =>
            current.effect != null || current.errorMessage != null,
        listener: (context, state) {
          final error = state.errorMessage;
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error al subir el banner: $error'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
            context.read<EventDetailCubit>().clearEffect();
            return;
          }

          final effect = state.effect;
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
                const SnackBar(
                    content: Text('Ficha copiada al portapapeles')),
              );
            case EventDetailEffect.shareComingSoon:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Compartir: próximamente')),
              );
            case EventDetailEffect.bannerCancelled:
              break;
          }

          context.read<EventDetailCubit>().clearEffect();
        },
        child: BlocBuilder<EventDetailCubit, EventDetailState>(
          builder: (context, state) {
            final cubit = context.read<EventDetailCubit>();
            return EventDetailBody(
              event: state.event,
              isUploadingBanner: state.isUploadingBanner,
              onUploadBanner: cubit.uploadBanner,
              onCopyTemplate: () => cubit.copyEventTemplate(
                (event) => buildEventTextTemplate(context, event),
              ),
              onShare: cubit.shareEvent,
            );
          },
        ),
      ),
    );
  }
}
