import * as functions from 'firebase-functions';

import { admin } from '../firebase';
import { region } from '../region';

import { PRIVACY_REQUEST_RETENTION_DAYS } from './constants';
import { normalizeSource, record, sanitizeReason, timestampPlusDays } from './shared';
import type { ConsentSource, PrivacyRequestStatus, PrivacyRequestType } from './types';

const PRIVACY_REQUEST_TYPES: readonly PrivacyRequestType[] = [
  'data_export',
  'account_deletion',
  'access',
  'rectification',
  'erasure',
  'restriction',
  'portability',
  'objection',
];

function isPrivacyRequestType(value: string): value is PrivacyRequestType {
  return (PRIVACY_REQUEST_TYPES as readonly string[]).includes(value);
}

function normalizeRequestType(value: unknown): PrivacyRequestType | null {
  if (typeof value !== 'string') return null;
  const normalized = value.trim().toLowerCase();
  return isPrivacyRequestType(normalized) ? normalized : null;
}

async function createPrivacyRequest({
  uid,
  requestType,
  reason,
  source,
  status = 'pending',
}: {
  uid: string;
  requestType: PrivacyRequestType;
  reason: string | null;
  source: ConsentSource;
  status?: PrivacyRequestStatus;
}): Promise<{ requestId: string }> {
  const db = admin.firestore();
  const requestsRef = db.collection('users').doc(uid).collection('privacy_requests');
  const requestDoc = requestsRef.doc();
  const timestamp = admin.firestore.FieldValue.serverTimestamp();

  await requestDoc.set({
    requestType,
    status,
    reason,
    source,
    evidenceRetentionDays: PRIVACY_REQUEST_RETENTION_DAYS,
    evidencePurgeAt: timestampPlusDays(PRIVACY_REQUEST_RETENTION_DAYS),
    createdAt: timestamp,
    updatedAt: timestamp,
  });

  return { requestId: requestDoc.id };
}

async function createTypedPrivacyRequest({
  uid,
  requestType,
  reason,
  source,
}: {
  uid: string;
  requestType: PrivacyRequestType;
  reason: string | null;
  source: ConsentSource;
}): Promise<{ requestId: string; requestType: PrivacyRequestType }> {
  const { requestId } = await createPrivacyRequest({
    uid,
    requestType,
    reason,
    source,
  });

  if (requestType === 'account_deletion') {
    const timestamp = admin.firestore.FieldValue.serverTimestamp();
    await admin.firestore().collection('users').doc(uid).set(
      {
        deletionRequestedAt: timestamp,
        updatedAt: timestamp,
      },
      { merge: true },
    );
  }

  return { requestId, requestType };
}

export const requestPrivacyRight = region.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
  }

  const body = record(data);
  const requestType = normalizeRequestType(body.requestType);
  if (requestType == null) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `requestType must be one of: ${PRIVACY_REQUEST_TYPES.join(', ')}`,
    );
  }
  const source = normalizeSource(body.source);
  const reason = sanitizeReason(body.reason);
  const uid = context.auth.uid;

  const { requestId } = await createTypedPrivacyRequest({
    uid,
    requestType,
    reason,
    source,
  });

  return {
    ok: true,
    uid,
    requestId,
    requestType,
  };
});

export const requestDataExport = region.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
  }

  const body = record(data);
  const source = normalizeSource(body.source);
  const reason = sanitizeReason(body.reason);
  const uid = context.auth.uid;

  const { requestId } = await createTypedPrivacyRequest({
    uid,
    requestType: 'data_export',
    reason,
    source,
  });

  return {
    ok: true,
    uid,
    requestId,
    requestType: 'data_export',
  };
});

export const requestAccountDeletion = region.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
  }

  const body = record(data);
  const source = normalizeSource(body.source);
  const reason = sanitizeReason(body.reason);
  const uid = context.auth.uid;

  const { requestId } = await createTypedPrivacyRequest({
    uid,
    requestType: 'account_deletion',
    reason,
    source,
  });

  return {
    ok: true,
    uid,
    requestId,
    requestType: 'account_deletion',
  };
});
