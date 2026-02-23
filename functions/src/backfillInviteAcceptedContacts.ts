import { admin, db } from './firebase';

function stringList(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value.map((entry) => String(entry)).filter(Boolean);
}

function stringOrEmpty(value: unknown): string {
  return typeof value === 'string' ? value : '';
}

function numberOrNull(value: unknown): number | null {
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
}

function nonNegativeInt(value: unknown): number {
  const resolved = numberOrNull(value);
  if (resolved == null) return 0;
  return Math.max(0, Math.floor(resolved));
}

function record(value: unknown): Record<string, unknown> {
  if (value == null) return {};
  if (typeof value !== 'object') return {};
  if (Array.isArray(value)) return {};
  return value as Record<string, unknown>;
}

function contactPayloadFromMusician(
  contactId: string,
  musicianData: Record<string, unknown>,
): Record<string, unknown> {
  const styles = stringList(musicianData.styles);
  const highlightStyle = stringOrEmpty(musicianData.highlightStyle);
  const resolvedHighlightStyle =
    highlightStyle || (styles.length ? styles[0] : null);
  const photoUrl = stringOrEmpty(musicianData.photoUrl);

  return {
    id: contactId,
    ownerId: stringOrEmpty(musicianData.ownerId) || contactId,
    name: stringOrEmpty(musicianData.name) || 'Musician',
    instrument: stringOrEmpty(musicianData.instrument),
    city: stringOrEmpty(musicianData.city),
    styles,
    highlightStyle: resolvedHighlightStyle,
    photoUrl: photoUrl || null,
    experienceYears: nonNegativeInt(musicianData.experienceYears),
    rating: numberOrNull(musicianData.rating),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

async function getMusicianData(
  uid: string,
  cache: Map<string, Promise<Record<string, unknown>>>,
): Promise<Record<string, unknown>> {
  const cached = cache.get(uid);
  if (cached != null) return cached;

  const pending = db
    .collection('musicians')
    .doc(uid)
    .get()
    .then((snap) => record(snap.data()))
    .catch((error) => {
      console.log(`Could not read musicians/${uid}: ${error}`);
      return {};
    });

  cache.set(uid, pending);
  return pending;
}

async function main() {
  console.log('Backfill invite accepted contacts');
  console.log(`FIRESTORE_EMULATOR_HOST=${process.env.FIRESTORE_EMULATOR_HOST ?? ''}`);
  console.log(
    `GOOGLE_CLOUD_PROJECT=${process.env.GOOGLE_CLOUD_PROJECT ?? ''} GCLOUD_PROJECT=${process.env.GCLOUD_PROJECT ?? ''}`,
  );
  console.log(`admin.projectId=${admin.app().options.projectId ?? ''}`);

  const bulkWriter = db.bulkWriter();
  bulkWriter.onWriteError((error) => {
    console.log(
      `BulkWriter error (${error.code}) at ${error.documentRef.path}: ${error.message}`,
    );
    return error.failedAttempts < 5;
  });

  const musicianCache = new Map<string, Promise<Record<string, unknown>>>();

  const pageSize = 250;
  let lastGroupId: string | null = null;
  let scannedGroups = 0;
  let scannedUsedInvites = 0;
  let processedUsedInvites = 0;
  let skippedMissingUsers = 0;
  let skippedSelfInvites = 0;
  let queuedWrites = 0;

  while (true) {
    let query: FirebaseFirestore.Query<FirebaseFirestore.DocumentData> = db
      .collection('groups')
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(pageSize);
    if (lastGroupId != null) {
      query = query.startAfter(lastGroupId);
    }

    const groupsPage = await query.get();
    if (groupsPage.empty) break;

    for (const groupDoc of groupsPage.docs) {
      scannedGroups += 1;
      const usedInvitesSnap = await groupDoc.ref
        .collection('invites')
        .where('status', '==', 'used')
        .get();

      for (const inviteDoc of usedInvitesSnap.docs) {
        scannedUsedInvites += 1;
        const invite = record(inviteDoc.data());
        const inviterUid = stringOrEmpty(invite.createdBy);
        const targetUid = stringOrEmpty(invite.targetUid);
        const usedByUid = stringOrEmpty(invite.usedBy);
        const acceptedUid = usedByUid || targetUid;

        if (!inviterUid || !acceptedUid) {
          skippedMissingUsers += 1;
          continue;
        }
        if (inviterUid === acceptedUid) {
          skippedSelfInvites += 1;
          continue;
        }

        const [inviterData, acceptedData] = await Promise.all([
          getMusicianData(inviterUid, musicianCache),
          getMusicianData(acceptedUid, musicianCache),
        ]);

        const inviterPayload = contactPayloadFromMusician(
          inviterUid,
          inviterData,
        );
        const acceptedPayload = contactPayloadFromMusician(
          acceptedUid,
          acceptedData,
        );

        bulkWriter.set(
          db
            .collection('musicians')
            .doc(inviterUid)
            .collection('contacts')
            .doc(acceptedUid),
          acceptedPayload,
          { merge: true },
        );
        bulkWriter.set(
          db
            .collection('musicians')
            .doc(acceptedUid)
            .collection('contacts')
            .doc(inviterUid),
          inviterPayload,
          { merge: true },
        );

        processedUsedInvites += 1;
        queuedWrites += 2;

        if (processedUsedInvites % 100 === 0) {
          console.log(
            `Processed ${processedUsedInvites} used invites (${queuedWrites} queued writes)...`,
          );
        }
      }
    }

    lastGroupId = groupsPage.docs[groupsPage.docs.length - 1].id;
    if (groupsPage.size < pageSize) break;
  }

  await bulkWriter.close();

  console.log(`Scanned groups: ${scannedGroups}`);
  console.log(`Used invites scanned: ${scannedUsedInvites}`);
  console.log(`Used invites processed: ${processedUsedInvites}`);
  console.log(`Skipped (missing users): ${skippedMissingUsers}`);
  console.log(`Skipped (self invites): ${skippedSelfInvites}`);
  console.log(`Contact writes queued: ${queuedWrites}`);
  console.log(`Musician docs cached: ${musicianCache.size}`);
  console.log('Backfill completed.');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
