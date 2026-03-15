import * as functions from 'firebase-functions';

import { admin } from '../firebase';
import { SCENARIO_KEYS } from '../notifications/scenarioKeys';
import { sendPushToUser } from '../notifications/sendPush';
import { region } from '../region';
import {
  shouldSyncStudioProjection,
  syncVenueProjectionToJamSessions,
  venuePayloadFromStudio,
} from './projections';
import { validateVenueData } from './validators';

function stringOrEmpty(value: unknown): string {
  return typeof value === 'string' ? value.trim() : '';
}

function scenarioKeyForJamSession(
  jamSession: Record<string, unknown>,
): typeof SCENARIO_KEYS[keyof typeof SCENARIO_KEYS] {
  if (jamSession.isCanceled === true) {
    return SCENARIO_KEYS.venueJamSessionCancelled;
  }
  if (jamSession.isPublic === false) {
    return SCENARIO_KEYS.venueJamSessionPrivate;
  }
  return SCENARIO_KEYS.venueJamSessionScheduled;
}

async function ensureUpdatedAt(
  ref: admin.firestore.DocumentReference,
  updatedAt: unknown,
): Promise<void> {
  if (updatedAt instanceof admin.firestore.Timestamp) {
    return;
  }
  await ref.set(
    { updatedAt: admin.firestore.FieldValue.serverTimestamp() },
    { merge: true },
  );
}

export const onVenueCreated = region.firestore
  .document('venues/{venueId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data() as Record<string, unknown> | undefined;
    if (!data) return;

    const validation = validateVenueData(data);
    if (!validation.valid) {
      await snapshot.ref.delete();
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Venue validation failed on create: ${validation.errors.join('; ')}`,
      );
    }

    await ensureUpdatedAt(snapshot.ref, data.updatedAt);
  });

export const onVenueUpdated = region.firestore
  .document('venues/{venueId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data() as Record<string, unknown> | undefined;
    const after = change.after.data() as Record<string, unknown> | undefined;
    if (!before || !after) return;

    const validation = validateVenueData(after);
    if (!validation.valid) {
      await change.after.ref.set(before);
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Venue validation failed on update: ${validation.errors.join('; ')}`,
      );
    }

    await ensureUpdatedAt(change.after.ref, after.updatedAt);
    await syncVenueProjectionToJamSessions(context.params.venueId, after);
  });

export const onStudioWriteSyncVenueProjection = region.firestore
  .document('studios/{studioId}')
  .onWrite(async (change, context) => {
    const studioId = String(context.params.studioId ?? '').trim();
    if (!studioId) return;

    const venueRef = admin.firestore().collection('venues').doc(studioId);
    if (!change.after.exists) {
      await venueRef.set(
        {
          isActive: false,
          sourceType: 'studio',
          sourceId: studioId,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      return;
    }

    const beforeData = change.before.exists
      ? (change.before.data() as Record<string, unknown> | undefined)
      : undefined;
    const afterData = change.after.data() as Record<string, unknown> | undefined;
    if (!afterData) return;
    if (!shouldSyncStudioProjection(beforeData, afterData)) {
      return;
    }

    const payload = venuePayloadFromStudio(studioId, afterData);
    const setPayload = {
      ...payload,
      createdAt: change.before.exists
        ? change.before.get('createdAt')
        : admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await venueRef.set(setPayload, { merge: true });
  });

export const onJamSessionCreated = region.firestore
  .document('jam_sessions/{sessionId}')
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data() as Record<string, unknown> | undefined;
    if (!data) return;

    const venueId = stringOrEmpty(data.venueId);
    if (!venueId) return;

    const db = admin.firestore();
    const venueSnap = await db.collection('venues').doc(venueId).get();
    const ownerId = stringOrEmpty(venueSnap.get('ownerId'));
    if (!ownerId) return;

    const sessionId = stringOrEmpty(context.params.sessionId);
    if (!sessionId) return;

    const title = stringOrEmpty(data.title) || 'Jam session';
    const scenarioKey = scenarioKeyForJamSession(data);

    await sendPushToUser({
      db,
      uid: ownerId,
      eventId: sessionId,
      scenarioKey,
      title: 'Actividad en tu venue',
      body: `Nueva jam session: ${title}`,
      data: {
        type: 'jam_session',
        sessionId,
        venueId,
      },
    });
  });
