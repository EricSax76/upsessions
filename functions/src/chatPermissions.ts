import { admin } from './firebase';
import { region } from './region';

type ChatPermissionPair = {
  managerId: string;
  musicianId: string;
};

function stringOrEmpty(value: unknown): string {
  return typeof value === 'string' ? value.trim() : '';
}

function pairDocId(pair: ChatPermissionPair): string {
  return `${pair.managerId}_${pair.musicianId}`;
}

function pairFromData(data: unknown): ChatPermissionPair | null {
  if (data == null || typeof data !== 'object' || Array.isArray(data)) {
    return null;
  }

  const raw = data as Record<string, unknown>;
  const managerId = stringOrEmpty(raw.managerId);
  const musicianId = stringOrEmpty(raw.musicianId);

  if (!managerId || !musicianId || managerId === musicianId) {
    return null;
  }

  return { managerId, musicianId };
}

async function syncPairPermission(pair: ChatPermissionPair): Promise<void> {
  const db = admin.firestore();
  const permissionRef = db.collection('chat_permissions').doc(pairDocId(pair));

  const acceptedSnapshot = await db
    .collection('musician_requests')
    .where('managerId', '==', pair.managerId)
    .where('musicianId', '==', pair.musicianId)
    .where('status', '==', 'accepted')
    .limit(1)
    .get();

  if (!acceptedSnapshot.empty) {
    const permissionSnapshot = await permissionRef.get();
    const payload: Record<string, unknown> = {
      managerId: pair.managerId,
      musicianId: pair.musicianId,
      source: 'musician_requests',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    if (!permissionSnapshot.exists) {
      payload.grantedAt = admin.firestore.FieldValue.serverTimestamp();
    }
    await permissionRef.set(payload, { merge: true });
    return;
  }

  await permissionRef.delete().catch(() => null);
}

type ChatPermissionBackfillStats = {
  acceptedPairs: number;
  upsertedPermissions: number;
  deletedPermissions: number;
};

async function reconcileChatPermissionsFromRequests(
): Promise<ChatPermissionBackfillStats> {
  const db = admin.firestore();

  const [acceptedSnapshot, permissionsSnapshot] = await Promise.all([
    db.collection('musician_requests').where('status', '==', 'accepted').get(),
    db
      .collection('chat_permissions')
      .where('source', '==', 'musician_requests')
      .get(),
  ]);

  const acceptedPairs = new Map<string, ChatPermissionPair>();
  for (const doc of acceptedSnapshot.docs) {
    const pair = pairFromData(doc.data());
    if (pair == null) continue;
    acceptedPairs.set(pairDocId(pair), pair);
  }

  const existingPermissions = new Map<
    string,
    FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>
  >();
  for (const doc of permissionsSnapshot.docs) {
    existingPermissions.set(doc.id, doc);
  }

  const writer = db.bulkWriter();
  let upsertedPermissions = 0;
  let deletedPermissions = 0;

  for (const [id, pair] of acceptedPairs.entries()) {
    const existing = existingPermissions.get(id)?.data() ?? {};
    const needsUpsert =
      stringOrEmpty(existing.managerId) !== pair.managerId
      || stringOrEmpty(existing.musicianId) !== pair.musicianId
      || stringOrEmpty(existing.source) !== 'musician_requests'
      || existing.grantedAt == null;

    if (!needsUpsert) {
      continue;
    }

    const payload: Record<string, unknown> = {
      managerId: pair.managerId,
      musicianId: pair.musicianId,
      source: 'musician_requests',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    if (!existingPermissions.has(id)) {
      payload.grantedAt = admin.firestore.FieldValue.serverTimestamp();
    } else if (existing.grantedAt == null) {
      payload.grantedAt = admin.firestore.FieldValue.serverTimestamp();
    }

    writer.set(db.collection('chat_permissions').doc(id), payload, {
      merge: true,
    });
    upsertedPermissions += 1;
  }

  for (const doc of permissionsSnapshot.docs) {
    if (acceptedPairs.has(doc.id)) {
      continue;
    }
    writer.delete(doc.ref);
    deletedPermissions += 1;
  }

  await writer.close();

  return {
    acceptedPairs: acceptedPairs.size,
    upsertedPermissions,
    deletedPermissions,
  };
}

export const onMusicianRequestWriteSyncChatPermission = region.firestore
  .document('musician_requests/{requestId}')
  .onWrite(async (change) => {
    const pairs = new Map<string, ChatPermissionPair>();

    const beforePair = pairFromData(change.before.data());
    const afterPair = pairFromData(change.after.data());

    if (beforePair != null) {
      pairs.set(pairDocId(beforePair), beforePair);
    }
    if (afterPair != null) {
      pairs.set(pairDocId(afterPair), afterPair);
    }

    if (!pairs.size) {
      return;
    }

    await Promise.all(
      Array.from(pairs.values()).map((pair) => syncPairPermission(pair)),
    );
  });

export const backfillChatPermissionsFromRequests = region.pubsub
  .schedule('every day 03:00')
  .timeZone('Europe/Madrid')
  .onRun(async () => {
    const stats = await reconcileChatPermissionsFromRequests();
    console.log(
      '[chatPermissions backfill] acceptedPairs=%d upserted=%d deleted=%d',
      stats.acceptedPairs,
      stats.upsertedPermissions,
      stats.deletedPermissions,
    );
    return null;
  });
