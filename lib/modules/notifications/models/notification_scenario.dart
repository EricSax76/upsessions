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

  /// Wire-stable key persisted in Firestore and FCM payloads.
  /// Never rename — change UI labels instead.
  /// Must stay in sync with SCENARIO_KEYS in functions/src/notifications/scenarioKeys.ts.
  String get wireKey => switch (this) {
    NotificationScenario.musicianGroupInvite => 'musician_group_invite',
    NotificationScenario.musicianUnreadMessage => 'musician_unread_message',
    NotificationScenario.studioBookingPending => 'studio_booking_pending',
    NotificationScenario.studioBookingConfirmed => 'studio_booking_confirmed',
    NotificationScenario.studioBookingCancelled => 'studio_booking_cancelled',
    NotificationScenario.managerRequestPending => 'manager_request_pending',
    NotificationScenario.managerRequestAccepted => 'manager_request_accepted',
    NotificationScenario.managerRequestRejected => 'manager_request_rejected',
    NotificationScenario.venueJamSessionScheduled =>
      'venue_jam_session_scheduled',
    NotificationScenario.venueJamSessionCancelled =>
      'venue_jam_session_cancelled',
    NotificationScenario.venueJamSessionPrivate => 'venue_jam_session_private',
  };
}

/// Parses a wire key back to its enum value.
/// Returns null for unknown keys — callers must handle forward-compatibility.
NotificationScenario? notificationScenarioFromWireKey(String key) =>
    switch (key) {
      'musician_group_invite' => NotificationScenario.musicianGroupInvite,
      'musician_unread_message' => NotificationScenario.musicianUnreadMessage,
      'studio_booking_pending' => NotificationScenario.studioBookingPending,
      'studio_booking_confirmed' => NotificationScenario.studioBookingConfirmed,
      'studio_booking_cancelled' => NotificationScenario.studioBookingCancelled,
      'manager_request_pending' => NotificationScenario.managerRequestPending,
      'manager_request_accepted' => NotificationScenario.managerRequestAccepted,
      'manager_request_rejected' => NotificationScenario.managerRequestRejected,
      'venue_jam_session_scheduled' =>
        NotificationScenario.venueJamSessionScheduled,
      'venue_jam_session_cancelled' =>
        NotificationScenario.venueJamSessionCancelled,
      'venue_jam_session_private' => NotificationScenario.venueJamSessionPrivate,
      _ => null,
    };
