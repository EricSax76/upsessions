import * as functions from 'firebase-functions';

import { admin } from '../firebase';
import { region } from '../region';

import { PRIVACY_REQUEST_RETENTION_DAYS } from './constants';
import { normalizeSource, record, sanitizeReason, timestampPlusDays } from './shared';
import type { ConsentSource, PrivacyRequestStatus, PrivacyRequestType } from './types';

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

export const requestDataExport = region.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
  }

  const body = record(data);
  const source = normalizeSource(body.source);
  const reason = sanitizeReason(body.reason);
  const uid = context.auth.uid;

  const { requestId } = await createPrivacyRequest({
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
  const timestamp = admin.firestore.FieldValue.serverTimestamp();

  const { requestId } = await createPrivacyRequest({
    uid,
    requestType: 'account_deletion',
    reason,
    source,
  });

  await admin.firestore().collection('users').doc(uid).set(
    {
      deletionRequestedAt: timestamp,
      updatedAt: timestamp,
    },
    { merge: true },
  );

  return {
    ok: true,
    uid,
    requestId,
    requestType: 'account_deletion',
  };
});
