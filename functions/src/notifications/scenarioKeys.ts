/**
 * Wire-stable string IDs for each notification scenario.
 *
 * These keys are persisted in Firestore (notificationPreferences,
 * notificationDispatches) and in FCM data payloads. Never rename them —
 * rename the human-readable labels in the UI layer instead.
 *
 * Must stay in sync with NotificationScenario.wireKey in Dart.
 */
export const SCENARIO_KEYS = {
  musicianGroupInvite: 'musician_group_invite',
  musicianUnreadMessage: 'musician_unread_message',
  studioBookingPending: 'studio_booking_pending',
  studioBookingConfirmed: 'studio_booking_confirmed',
  studioBookingCancelled: 'studio_booking_cancelled',
  managerRequestPending: 'manager_request_pending',
  managerRequestAccepted: 'manager_request_accepted',
  managerRequestRejected: 'manager_request_rejected',
  venueJamSessionScheduled: 'venue_jam_session_scheduled',
  venueJamSessionCancelled: 'venue_jam_session_cancelled',
  venueJamSessionPrivate: 'venue_jam_session_private',
} as const;

export type ScenarioKey = typeof SCENARIO_KEYS[keyof typeof SCENARIO_KEYS];

export const ALL_SCENARIO_KEYS: ReadonlyArray<ScenarioKey> =
  Object.values(SCENARIO_KEYS);

/**
 * Scenarios that support push delivery.
 *
 * Must stay in sync with NotificationScenario.metadata.channels in Dart.
 * If a scenario is missing here, sendPushToUser will refuse dispatch.
 */
export const PUSH_CAPABLE_SCENARIO_KEYS: ReadonlySet<ScenarioKey> = new Set([
  SCENARIO_KEYS.musicianGroupInvite,
  SCENARIO_KEYS.musicianUnreadMessage,
  SCENARIO_KEYS.studioBookingPending,
  SCENARIO_KEYS.managerRequestAccepted,
  SCENARIO_KEYS.managerRequestRejected,
  SCENARIO_KEYS.venueJamSessionScheduled,
  SCENARIO_KEYS.venueJamSessionCancelled,
  SCENARIO_KEYS.venueJamSessionPrivate,
]);
