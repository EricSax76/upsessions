import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/notification_preferences_entity.dart';
import '../../models/notification_scenario.dart';

typedef ScenarioChannelChanged =
    Future<void> Function(
      NotificationScenario scenario,
      NotificationChannel channel,
      bool enabled,
    );

class ScenarioChannelTile extends StatelessWidget {
  const ScenarioChannelTile({
    super.key,
    required this.scenario,
    required this.entity,
    required this.onChannelChanged,
  });

  final NotificationScenario scenario;
  final NotificationPreferencesEntity entity;
  final ScenarioChannelChanged onChannelChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _scenarioTitle(scenario),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              _scenarioSubtitle(scenario),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final channel in scenario.metadata.channels)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(_channelLabel(channel)),
                value: entity.isChannelEnabled(scenario, channel),
                onChanged: (enabled) {
                  unawaited(onChannelChanged(scenario, channel, enabled));
                },
              ),
          ],
        ),
      ),
    );
  }
}

String _scenarioTitle(NotificationScenario scenario) {
  return switch (scenario) {
    NotificationScenario.musicianGroupInvite => 'Invitaciones a grupos',
    NotificationScenario.musicianUnreadMessage => 'Mensajes sin leer',
    NotificationScenario.studioBookingPending => 'Reservas pendientes',
    NotificationScenario.studioBookingConfirmed => 'Reservas confirmadas',
    NotificationScenario.studioBookingCancelled => 'Reservas canceladas',
    NotificationScenario.managerRequestPending => 'Solicitudes pendientes',
    NotificationScenario.managerRequestAccepted => 'Solicitudes aceptadas',
    NotificationScenario.managerRequestRejected => 'Solicitudes rechazadas',
    NotificationScenario.venueJamSessionScheduled => 'Jam sessions programadas',
    NotificationScenario.venueJamSessionCancelled => 'Jam sessions canceladas',
    NotificationScenario.venueJamSessionPrivate => 'Jam sessions privadas',
  };
}

String _scenarioSubtitle(NotificationScenario scenario) {
  final severity = switch (scenario.metadata.severity) {
    NotificationSeverity.info => 'Informativa',
    NotificationSeverity.success => 'Éxito',
    NotificationSeverity.warning => 'Advertencia',
    NotificationSeverity.critical => 'Crítica',
  };
  return scenario.metadata.actionable
      ? '$severity · Requiere acción'
      : '$severity · Solo informativa';
}

String _channelLabel(NotificationChannel channel) {
  return switch (channel) {
    NotificationChannel.inApp => 'En la app',
    NotificationChannel.push => 'Push',
    NotificationChannel.email => 'Email',
  };
}
