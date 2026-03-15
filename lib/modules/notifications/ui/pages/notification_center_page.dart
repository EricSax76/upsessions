import 'package:flutter/material.dart';

import '../../../event_manager/repositories/manager_notifications_repository.dart';
import '../../../musicians/repositories/musician_notifications_repository.dart';
import '../../../studios/repositories/studio_notifications_repository.dart';
import '../../../venues/repositories/venue_notifications_repository.dart';
import '../../models/notification_scenario.dart';
import '../widgets/notification_center/manager_notifications_panel.dart';
import '../widgets/notification_center/musician_notifications_panel.dart';
import '../widgets/notification_center/notification_center_error_view.dart';
import '../widgets/notification_center/studio_notifications_panel.dart';
import '../widgets/notification_center/venue_notifications_panel.dart';

class NotificationCenterPage extends StatelessWidget {
  const NotificationCenterPage({
    super.key,
    required this.audience,
    this.musicianNotificationsRepository,
    this.studioNotificationsRepository,
    this.managerNotificationsRepository,
    this.venueNotificationsRepository,
  });

  final NotificationAudience audience;
  final MusicianNotificationsRepository? musicianNotificationsRepository;
  final StudioNotificationsRepository? studioNotificationsRepository;
  final ManagerNotificationsRepository? managerNotificationsRepository;
  final VenueNotificationsRepository? venueNotificationsRepository;

  @override
  Widget build(BuildContext context) {
    final copy = _copyForAudience(audience);
    final scenarioCount = scenariosForAudience(audience).length;

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: false,
          floating: true,
          title: Text('Notificaciones'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      copy.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$scenarioCount escenarios configurados para tu rol',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([_buildAudienceSection(context)]),
          ),
        ),
      ],
    );
  }

  Widget _buildAudienceSection(BuildContext context) {
    switch (audience) {
      case NotificationAudience.musician:
        final repository = musicianNotificationsRepository;
        if (repository == null) {
          return const NotificationCenterErrorView(
            message: 'Falta el repositorio de notificaciones de músico.',
          );
        }
        return MusicianNotificationsPanel(repository: repository);
      case NotificationAudience.studio:
        final repository = studioNotificationsRepository;
        if (repository == null) {
          return const NotificationCenterErrorView(
            message: 'Falta el repositorio de notificaciones de estudio.',
          );
        }
        return StudioNotificationsPanel(repository: repository);
      case NotificationAudience.eventManager:
        final repository = managerNotificationsRepository;
        if (repository == null) {
          return const NotificationCenterErrorView(
            message: 'Falta el repositorio de notificaciones del manager.',
          );
        }
        return ManagerNotificationsPanel(repository: repository);
      case NotificationAudience.venue:
        final repository = venueNotificationsRepository;
        if (repository == null) {
          return const NotificationCenterErrorView(
            message: 'Falta el repositorio de notificaciones del local.',
          );
        }
        return VenueNotificationsPanel(repository: repository);
    }
  }
}

_NotificationCenterCopy _copyForAudience(NotificationAudience audience) {
  return switch (audience) {
    NotificationAudience.musician => const _NotificationCenterCopy(
      title: 'Actividad personal',
      description:
          'Revisa mensajes sin leer e invitaciones a grupos en un solo lugar.',
    ),
    NotificationAudience.studio => const _NotificationCenterCopy(
      title: 'Reservas del estudio',
      description:
          'Aquí encontrarás nuevas reservas y cambios importantes de estado.',
    ),
    NotificationAudience.eventManager => const _NotificationCenterCopy(
      title: 'Solicitudes a músicos',
      description:
          'Controla respuestas de contratación y novedades de tus peticiones.',
    ),
    NotificationAudience.venue => const _NotificationCenterCopy(
      title: 'Actividad en locales',
      description:
          'Sigue programación, cancelaciones y visibilidad de jam sessions.',
    ),
  };
}

class _NotificationCenterCopy {
  const _NotificationCenterCopy({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
