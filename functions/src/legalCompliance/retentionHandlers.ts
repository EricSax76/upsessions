import * as functions from 'firebase-functions';

import { admin } from '../firebase';
import { region } from '../region';

import {
  RETENTION_PURGE_BATCH_SIZE,
  RETENTION_PURGE_MAX_BATCHES,
} from './constants';
import { record } from './shared';

async function purgeUsersPastRetention(now: admin.firestore.Timestamp): Promise<number> {
  const db = admin.firestore();
  const usersToPurge = await db
    .collection('users')
    .where('purgeAt', '<=', now)
    .limit(RETENTION_PURGE_BATCH_SIZE)
    .get();

  if (usersToPurge.empty) {
    return 0;
  }

  let removed = 0;
  for (const doc of usersToPurge.docs) {
    const data = record(doc.data());
    if (data.deletedAt == null) {
      await doc.ref.set(
        {
          purgeAt: null,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      continue;
    }
    await db.recursiveDelete(doc.ref);
    removed += 1;
  }

  return removed;
}

async function purgeExpiredEvidenceBatch(
  collectionId: 'policy_acceptances' | 'privacy_requests',
  now: admin.firestore.Timestamp,
): Promise<number> {
  const db = admin.firestore();
  const expiredDocs = await db
    .collectionGroup(collectionId)
    .where('evidencePurgeAt', '<=', now)
    .limit(RETENTION_PURGE_BATCH_SIZE)
    .get();

  if (expiredDocs.empty) {
    return 0;
  }

  const batch = db.batch();
  for (const doc of expiredDocs.docs) {
    batch.delete(doc.ref);
  }
  await batch.commit();
  return expiredDocs.size;
}

async function runRetentionInBatches(
  purgeBatch: () => Promise<number>,
): Promise<{ deleted: number; reachedCap: boolean }> {
  let total = 0;
  let reachedCap = false;

  for (let i = 0; i < RETENTION_PURGE_MAX_BATCHES; i += 1) {
    const deleted = await purgeBatch();
    total += deleted;
    if (deleted < RETENTION_PURGE_BATCH_SIZE) {
      return { deleted: total, reachedCap: false };
    }
    if (i === RETENTION_PURGE_MAX_BATCHES - 1) {
      reachedCap = true;
    }
  }

  return { deleted: total, reachedCap };
}

export const purgeExpiredComplianceData = region.pubsub
  .schedule('15 3 * * *')
  .timeZone('Etc/UTC')
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();
    const users = await runRetentionInBatches(() => purgeUsersPastRetention(now));
    const policyAcceptances = await runRetentionInBatches(() =>
      purgeExpiredEvidenceBatch('policy_acceptances', now),
    );
    const privacyRequests = await runRetentionInBatches(() =>
      purgeExpiredEvidenceBatch('privacy_requests', now),
    );

    functions.logger.info('Compliance retention job completed', {
      usersPurged: users.deleted,
      usersReachedCap: users.reachedCap,
      policyAcceptancesPurged: policyAcceptances.deleted,
      policyAcceptancesReachedCap: policyAcceptances.reachedCap,
      privacyRequestsPurged: privacyRequests.deleted,
      privacyRequestsReachedCap: privacyRequests.reachedCap,
      retentionBatchSize: RETENTION_PURGE_BATCH_SIZE,
      retentionMaxBatches: RETENTION_PURGE_MAX_BATCHES,
      executedAt: new Date().toISOString(),
    });

    return null;
  });
