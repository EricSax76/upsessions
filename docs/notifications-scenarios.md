# Notifications scenarios by authenticated session

## Scope
- Context analyzed: `musician`, `studio`, `event_manager`, `venue`.
- Current implementation already had pages/repositories by role, but only one
  explicit notification model (`InviteNotificationEntity`).
- This update introduces a shared scenario catalog and role-specific
  notification entities so each session has a clear and extensible contract.

## Industry-standard principles applied
- Domain taxonomy first:
  - Each notification maps to a `NotificationScenario`.
  - Each scenario defines audience, severity, channels and actionability.
- Explicit read state:
  - Read acknowledgement is persisted (`read`, `readByOwner`, `readByManager`)
    when the data model/rules allow it.
- Stable feed queries:
  - Ordered by server time (`createdAt` / `date`) and bounded (`limit`) for
    predictable UX and lower realtime costs.
- Backward-safe parsing:
  - New entities parse missing/legacy fields defensively.

## Scenario matrix

### Musician
- `musicianUnreadMessage`
  - Trigger: unread chat thread.
  - Priority: info.
  - Action: open thread.
- `musicianGroupInvite`
  - Trigger: group invite creation.
  - Priority: info.
  - Action: open invite and accept/reject.

### Studio
- `studioBookingPending`
  - Trigger: booking in `pending` state for a studio owned by current user.
  - Priority: warning.
  - Action: review booking.
- `studioBookingConfirmed`
  - Trigger: booking transitions to `confirmed`.
  - Priority: success.
  - Action: optional.
- `studioBookingCancelled`
  - Trigger: booking transitions to `cancelled`/`refunded`.
  - Priority: warning.
  - Action: optional.

### Event manager
- `managerRequestPending`
  - Trigger: outgoing musician request remains pending.
  - Priority: info.
  - Action: optional.
- `managerRequestAccepted`
  - Trigger: musician request accepted.
  - Priority: success.
  - Action: optional (follow-up workflow).
- `managerRequestRejected`
  - Trigger: musician request rejected/cancelled.
  - Priority: warning.
  - Action: optional.

### Venue
- `venueJamSessionScheduled`
  - Trigger: active jam session linked to venue.
  - Priority: info.
  - Action: optional.
- `venueJamSessionCancelled`
  - Trigger: jam session marked cancelled.
  - Priority: warning.
  - Action: optional.
- `venueJamSessionPrivate`
  - Trigger: jam session linked to venue but private.
  - Priority: info.
  - Action: optional.

## Pending backlog (recommended)
- Add migration clean-up job for legacy tokens still stored in
  `musicians/{uid}/fcmTokens` once all active clients are updated.
- Introduce user-scoped notification inbox collections for immutable
  event history and per-user read state without mutating source documents.
- Add notification preference center (channels, categories, quiet hours).
- Add delivery telemetry (sent/opened/clicked/failure) for observability.
