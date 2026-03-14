import * as functions from 'firebase-functions';

import { admin } from '../firebase';
import { region } from '../region';

import { PRIVACY_REQUEST_RETENTION_DAYS } from './constants';
import { resolveRoles, tokenRole } from './roles';
import {
  extractClientIp,
  extractUserAgent,
  hashOrNull,
  normalizeSource,
  record,
  sanitizeReason,
  stringOrEmpty,
  timestampPlusDays,
} from './shared';
import type { PrivacyRequestStatus } from './types';

const PRIVACY_REQUEST_STATUSES: readonly PrivacyRequestStatus[] = [
  'pending',
  'in_progress',
  'completed',
  'rejected',
];

const ALLOWED_STATUS_TRANSITIONS: Readonly<
  Record<PrivacyRequestStatus, readonly PrivacyRequestStatus[]>
> = {
  pending: ['in_progress', 'completed', 'rejected'],
  in_progress: ['pending', 'completed', 'rejected'],
  completed: [],
  rejected: ['pending', 'in_progress'],
};

function isPrivacyRequestStatus(value: string): value is PrivacyRequestStatus {
  return (PRIVACY_REQUEST_STATUSES as readonly string[]).includes(value);
}

function normalizeStatus(value: unknown): PrivacyRequestStatus | null {
  const normalized = stringOrEmpty(value).trim().toLowerCase();
  return isPrivacyRequestStatus(normalized) ? normalized : null;
}

function timestampToIso(value: unknown): string | null {
  if (value instanceof admin.firestore.Timestamp) {
    return value.toDate().toISOString();
  }
  return null;
}

function requestOwnerUid(
  doc: admin.firestore.QueryDocumentSnapshot,
): string {
  const ownerRef = doc.ref.parent.parent;
  return ownerRef?.id ?? '';
}

async function assertAdminOrThrow(
  context: functions.https.CallableContext,
): Promise<{ uid: string; roles: string[] }> {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
  }

  const uid = context.auth.uid;
  const resolvedRoles = await resolveRoles(uid, tokenRole(context));
  if (!resolvedRoles.includes('admin')) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Admin role required for privacy backoffice actions.',
    );
  }

  return { uid, roles: resolvedRoles };
}

export const listPrivacyRequestsBackoffice = region.https.onCall(
  async (data, context) => {
    await assertAdminOrThrow(context);

    const body = record(data);
    const requestedStatus = normalizeStatus(body.status);
    if (body.status != null && requestedStatus == null) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `status must be one of: ${PRIVACY_REQUEST_STATUSES.join(', ')}`,
      );
    }

    const rawLimit = typeof body.limit === 'number' ? Math.floor(body.limit) : 50;
    const limit = Math.max(1, Math.min(100, rawLimit));

    let query: admin.firestore.Query = admin
      .firestore()
      .collectionGroup('privacy_requests');

    if (requestedStatus != null) {
      query = query.where('status', '==', requestedStatus);
    }

    const snapshot = await query.orderBy('createdAt', 'desc').limit(limit).get();

    const items = snapshot.docs.map((doc) => {
      const payload = record(doc.data());
      return {
        userId: requestOwnerUid(doc),
        requestId: doc.id,
        requestType: stringOrEmpty(payload.requestType),
        status: stringOrEmpty(payload.status),
        reason: payload.reason == null ? null : stringOrEmpty(payload.reason),
        source: stringOrEmpty(payload.source),
        createdAt: timestampToIso(payload.createdAt),
        updatedAt: timestampToIso(payload.updatedAt),
        statusUpdatedAt: timestampToIso(payload.statusUpdatedAt),
        statusUpdatedBy: payload.statusUpdatedBy == null
            ? null
            : stringOrEmpty(payload.statusUpdatedBy),
        statusReason: payload.statusReason == null
            ? null
            : stringOrEmpty(payload.statusReason),
      };
    });

    return {
      ok: true,
      count: items.length,
      items,
    };
  },
);

export const updatePrivacyRequestStatusBackoffice = region.https.onCall(
  async (data, context) => {
    const { uid: actorUid, roles: actorRoles } = await assertAdminOrThrow(context);

    const body = record(data);
    const userId = stringOrEmpty(body.userId).trim();
    const requestId = stringOrEmpty(body.requestId).trim();
    if (!userId || !requestId) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'userId and requestId are required.',
      );
    }

    const nextStatus = normalizeStatus(body.nextStatus);
    if (nextStatus == null) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `nextStatus must be one of: ${PRIVACY_REQUEST_STATUSES.join(', ')}`,
      );
    }

    const source = normalizeSource(body.source);
    const statusReason = sanitizeReason(body.statusReason);
    const ipHash = hashOrNull(extractClientIp(context));
    const userAgentHash = hashOrNull(extractUserAgent(context));

    const db = admin.firestore();
    const userRef = db.collection('users').doc(userId);
    const requestRef = userRef.collection('privacy_requests').doc(requestId);

    let previousStatus: PrivacyRequestStatus | null = null;

    await db.runTransaction(async (transaction) => {
      const requestSnapshot = await transaction.get(requestRef);
      if (!requestSnapshot.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'Privacy request not found.',
        );
      }

      const current = record(requestSnapshot.data());
      const currentStatus = normalizeStatus(current.status);
      if (currentStatus == null) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Current request status is invalid.',
        );
      }

      if (currentStatus == nextStatus) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Request is already in the target status.',
        );
      }

      const allowedNext = ALLOWED_STATUS_TRANSITIONS[currentStatus] ?? [];
      if (!allowedNext.includes(nextStatus)) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          `Transition ${currentStatus} -> ${nextStatus} is not allowed.`,
        );
      }

      previousStatus = currentStatus;
      const timestamp = admin.firestore.FieldValue.serverTimestamp();

      transaction.set(
        requestRef,
        {
          status: nextStatus,
          statusUpdatedAt: timestamp,
          statusUpdatedBy: actorUid,
          statusReason,
          updatedAt: timestamp,
        },
        { merge: true },
      );

      const auditRef = requestRef.collection('status_audit').doc();
      transaction.set(auditRef, {
        previousStatus: currentStatus,
        nextStatus,
        statusReason,
        changedBy: actorUid,
        changedByRoles: actorRoles,
        source,
        ipHash,
        userAgentHash,
        evidenceRetentionDays: PRIVACY_REQUEST_RETENTION_DAYS,
        evidencePurgeAt: timestampPlusDays(PRIVACY_REQUEST_RETENTION_DAYS),
        createdAt: timestamp,
      });

      transaction.set(
        userRef,
        {
          lastPrivacyRequestStatusUpdateAt: timestamp,
          updatedAt: timestamp,
        },
        { merge: true },
      );
    });

    return {
      ok: true,
      userId,
      requestId,
      previousStatus,
      nextStatus,
      updatedBy: actorUid,
    };
  },
);
