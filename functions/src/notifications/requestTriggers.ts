import { admin } from '../firebase';
import { region } from '../region';
import { SCENARIO_KEYS } from './scenarioKeys';
import { sendPushToUser } from './sendPush';

function stringOrEmpty(value: unknown): string {
  return typeof value === 'string' ? value.trim() : '';
}

function scenarioKeyForRequestStatus(status: string) {
  if (status === 'accepted') return SCENARIO_KEYS.managerRequestAccepted;
  if (status === 'rejected') return SCENARIO_KEYS.managerRequestRejected;
  return null;
}

export const onMusicianRequestStatusChanged = region.firestore
  .document('musician_requests/{requestId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() as Record<string, unknown> | undefined;
    const after = change.after.data() as Record<string, unknown> | undefined;
    if (!before || !after) return;

    const beforeStatus = stringOrEmpty(before.status);
    const afterStatus = stringOrEmpty(after.status);
    if (!afterStatus || afterStatus === beforeStatus) {
      return;
    }

    const scenarioKey = scenarioKeyForRequestStatus(afterStatus);
    if (scenarioKey == null) {
      return;
    }

    const managerId = stringOrEmpty(after.managerId);
    if (!managerId) {
      return;
    }

    const requestId = stringOrEmpty(context.params.requestId);
    if (!requestId) {
      return;
    }

    const message = stringOrEmpty(after.message);
    const title =
      afterStatus === 'accepted' ? 'Solicitud aceptada' : 'Solicitud rechazada';
    const body = message
      ? message
      : (afterStatus === 'accepted'
        ? 'Un músico aceptó tu solicitud.'
        : 'Un músico rechazó tu solicitud.');

    await sendPushToUser({
      db: admin.firestore(),
      uid: managerId,
      eventId: requestId,
      scenarioKey,
      title,
      body,
      data: {
        type: 'manager_request',
        requestId,
        status: afterStatus,
      },
    });
  });
