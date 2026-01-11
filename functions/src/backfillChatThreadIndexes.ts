import { admin, db } from './firebase';

function stringList(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value.map((entry) => String(entry)).filter(Boolean);
}

function record(value: unknown): Record<string, unknown> {
  if (value == null) return {};
  if (typeof value !== 'object') return {};
  if (Array.isArray(value)) return {};
  return value as Record<string, unknown>;
}

async function main() {
  console.log('Backfill chat thread indexes');
  console.log(`FIRESTORE_EMULATOR_HOST=${process.env.FIRESTORE_EMULATOR_HOST ?? ''}`);
  console.log(
    `GOOGLE_CLOUD_PROJECT=${process.env.GOOGLE_CLOUD_PROJECT ?? ''} GCLOUD_PROJECT=${process.env.GCLOUD_PROJECT ?? ''}`,
  );
  console.log(`admin.projectId=${admin.app().options.projectId ?? ''}`);

  try {
    const rootCollections = await db.listCollections();
    console.log(
      `Root collections: ${rootCollections.map((ref) => ref.id).join(', ') || '(none)'}`,
    );
  } catch (error) {
    console.log(
      `Could not list root collections: ${
        error instanceof Error ? error.message : String(error)
      }`,
    );
  }

  const snapshot = await db.collection('chat_threads').get();
  console.log(`Found ${snapshot.size} chat_threads docs.`);

  let processed = 0;
  for (const doc of snapshot.docs) {
    const data = doc.data() as Record<string, unknown>;
    const threadId = doc.id;
    const participants = stringList(data.participants);
    if (!participants.length) {
      continue;
    }

    const payload = {
      participants,
      participantLabels: record(data.participantLabels),
      lastMessage: record(data.lastMessage),
      lastMessageAt:
        data.lastMessageAt
          ?? data.createdAt
          ?? admin.firestore.FieldValue.serverTimestamp(),
      createdAt: data.createdAt ?? admin.firestore.FieldValue.serverTimestamp(),
      unreadCounts: record(data.unreadCounts),
    };

    await Promise.all(
      participants.map((uid) =>
        db
          .collection('musicians')
          .doc(uid)
          .collection('threads')
          .doc(threadId)
          .set(payload, { merge: true }),
      ),
    );

    processed += 1;
    if (processed % 100 === 0) {
      console.log(`Processed ${processed}/${snapshot.size} threads...`);
    }
  }

  console.log(`Done. Processed ${processed}/${snapshot.size} threads.`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
