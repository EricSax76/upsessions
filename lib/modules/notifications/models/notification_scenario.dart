enum NotificationAudience { musician, studio, eventManager, venue }

enum NotificationSeverity { info, success, warning, critical }

enum NotificationChannel { inApp, push, email }

enum NotificationScenario {
  musicianGroupInvite,
  musicianUnreadMessage,
  studioBookingPending,
  studioBookingConfirmed,
  studioBookingCancelled,
  managerRequestPending,
  managerRequestAccepted,
  managerRequestRejected,
  venueJamSessionScheduled,
  venueJamSessionCancelled,
  venueJamSessionPrivate,
}

class NotificationScenarioMetadata {
  const NotificationScenarioMetadata({
    required this.scenario,
    required this.audience,
    required this.severity,
    required this.actionable,
    required this.channels,
  });

  final NotificationScenario scenario;
  final NotificationAudience audience;
  final NotificationSeverity severity;
  final bool actionable;
  final List<NotificationChannel> channels;
}

NotificationScenarioMetadata scenarioMetadata(NotificationScenario scenario) {
  return switch (scenario) {
    NotificationScenario.musicianGroupInvite =>
      const NotificationScenarioMetadata(
        scenario: NotificationScenario.musicianGroupInvite,
        audience: NotificationAudience.musician,
        severity: NotificationSeverity.info,
        actionable: true,
        channels: [NotificationChannel.inApp, NotificationChannel.push],
      ),
    NotificationScenario.musicianUnreadMessage =>
      const NotificationScenarioMetadata(
        scenario: NotificationScenario.musicianUnreadMessage,
        audience: NotificationAudience.musician,
        severity: NotificationSeverity.info,
        actionable: true,
        channels: [NotificationChannel.inApp, NotificationChannel.push],
      ),
    NotificationScenario.studioBookingPending =>
      const NotificationScenarioMetadata(
        scenario: NotificationScenario.studioBookingPending,
        audience: NotificationAudience.studio,
        severity: NotificationSeverity.warning,
        actionable: true,
        channels: [
          NotificationChannel.inApp,
          NotificationChannel.push,
          NotificationChannel.email,
        ],
      ),
    NotificationScenario.studioBookingConfirmed =>
      const NotificationScenarioMetadata(
        scenario: NotificationScenario.studioBookingConfirmed,
        audience: NotificationAudience.studio,
        severity: NotificationSeverity.success,
        actionable: false,
        channels: [NotificationChannel.inApp],
      ),
    NotificationScenario.studioBookingCancelled =>
      const NotificationScenarioMetadata(
        scenario: NotificationScenario.studioBookingCancelled,
        audience: NotificationAudience.studio,
        severity: NotificationSeverity.warning,
        actionable: false,
        channels: [NotificationChannel.inApp, NotificationChannel.email],
      ),
    NotificationScenario.managerRequestPending =>
      const NotificationScenarioMetadata(
        scenario: NotificationScenario.managerRequestPending,
        audience: NotificationAudience.eventManager,
        severity: NotificationSeverity.info,
        actionable: false,
        channels: [NotificationChannel.inApp],
      ),
    NotificationScenario.managerRequestAccepted =>
      const NotificationScenarioMetadata(
        scenario: NotificationScenario.managerRequestAccepted,
        audience: NotificationAudience.eventManager,
        severity: NotificationSeverity.success,
        actionable: false,
        channels: [NotificationChannel.inApp, NotificationChannel.push],
      ),
    NotificationScenario.managerRequestRejected =>
      const NotificationScenarioMetadata(
        scenario: NotificationScenario.managerRequestRejected,
        audience: NotificationAudience.eventManager,
        severity: NotificationSeverity.warning,
        actionable: false,
        channels: [NotificationChannel.inApp, NotificationChannel.push],
      ),
    NotificationScenario.venueJamSessionScheduled =>
      const NotificationScenarioMetadata(
        scenario: NotificationScenario.venueJamSessionScheduled,
        audience: NotificationAudience.venue,
        severity: NotificationSeverity.info,
        actionable: false,
        channels: [NotificationChannel.inApp],
      ),
    NotificationScenario.venueJamSessionCancelled =>
      const NotificationScenarioMetadata(
        scenario: NotificationScenario.venueJamSessionCancelled,
        audience: NotificationAudience.venue,
        severity: NotificationSeverity.warning,
        actionable: false,
        channels: [NotificationChannel.inApp, NotificationChannel.email],
      ),
    NotificationScenario.venueJamSessionPrivate =>
      const NotificationScenarioMetadata(
        scenario: NotificationScenario.venueJamSessionPrivate,
        audience: NotificationAudience.venue,
        severity: NotificationSeverity.info,
        actionable: false,
        channels: [NotificationChannel.inApp],
      ),
  };
}

List<NotificationScenario> scenariosForAudience(NotificationAudience audience) {
  return switch (audience) {
    NotificationAudience.musician => const [
      NotificationScenario.musicianUnreadMessage,
      NotificationScenario.musicianGroupInvite,
    ],
    NotificationAudience.studio => const [
      NotificationScenario.studioBookingPending,
      NotificationScenario.studioBookingConfirmed,
      NotificationScenario.studioBookingCancelled,
    ],
    NotificationAudience.eventManager => const [
      NotificationScenario.managerRequestPending,
      NotificationScenario.managerRequestAccepted,
      NotificationScenario.managerRequestRejected,
    ],
    NotificationAudience.venue => const [
      NotificationScenario.venueJamSessionScheduled,
      NotificationScenario.venueJamSessionCancelled,
      NotificationScenario.venueJamSessionPrivate,
    ],
  };
}

extension NotificationScenarioX on NotificationScenario {
  NotificationScenarioMetadata get metadata => scenarioMetadata(this);
}
