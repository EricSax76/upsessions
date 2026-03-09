import { admin, db } from './firebase';

type CliOptions = {
  dryRun: boolean;
  threadsPageSize: number;
  maxThreads: number | null;
};

type Counters = {
  threadsScanned: number;
  alreadyHydrated: number;
  missingLastMessage: number;
  malformedLastMessage: number;
  needsUpdate: number;
  threadsWithoutMessages: number;
  writesQueued: number;
};

function parsePositiveInt(value: string, fallback: number): number {
  const parsed = Number.parseInt(value, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return fallback;
  }
  return parsed;
}

function parseArgs(argv: string[]): CliOptions {
  let dryRun = false;
  let threadsPageSize = 250;
  let maxThreads: number | null = null;

  for (const arg of argv) {
    if (arg === '--dry-run') {
      dryRun = true;
      continue;
    }
    if (arg.startsWith('--threads-page-size=')) {
      threadsPageSize = parsePositiveInt(
        arg.slice('--threads-page-size='.length),
        threadsPageSize,
      );
      continue;
    }
    if (arg.startsWith('--max-threads=')) {
      maxThreads = parsePositiveInt(arg.slice('--max-threads='.length), 1);
      continue;
    }
  }

  return {
    dryRun,
    threadsPageSize,
    maxThreads,
  };
}

function record(value: unknown): Record<string, unknown> {
  if (value == null) return {};
  if (typeof value !== 'object') return {};
  if (Array.isArray(value)) return {};
  return value as Record<string, unknown>;
}

function stringOrEmpty(value: unknown): string {
  return typeof value === 'string' ? value : '';
}

function timestampOrNull(value: unknown): FirebaseFirestore.Timestamp | null {
  if (value instanceof admin.firestore.Timestamp) {
    return value;
  }
  if (value instanceof Date && Number.isFinite(value.valueOf())) {
    return admin.firestore.Timestamp.fromDate(value);
  }
  if (typeof value === 'number' && Number.isFinite(value)) {
    return admin.firestore.Timestamp.fromMillis(value);
  }
  if (typeof value === 'string') {
    const parsed = Date.parse(value);
    if (Number.isFinite(parsed)) {
      return admin.firestore.Timestamp.fromMillis(parsed);
    }
  }
  return null;
}

function classifyLastMessage(value: unknown): 'missing' | 'valid' | 'malformed' {
  const payload = record(value);
  if (Object.keys(payload).length === 0) {
    return 'missing';
  }

  const sentAt = timestampOrNull(payload.sentAt);
  const body = payload.body;
  if (sentAt == null || typeof body !== 'string') {
    return 'malformed';
  }

  return 'valid';
}

function lastMessagePayloadFromDoc(
  doc: FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>,
): { lastMessage: Record<string, unknown>; lastMessageAt: FirebaseFirestore.Timestamp } {
  const data = record(doc.data());
  const sentAt = timestampOrNull(data.sentAt) ?? admin.firestore.Timestamp.now();
  const body =
    typeof data.body === 'string'
      ? data.body
      : data.body == null
        ? ''
        : String(data.body);

  const lastMessage: Record<string, unknown> = {
    id: doc.id,
    sender: stringOrEmpty(data.sender),
    senderId: stringOrEmpty(data.senderId),
    senderEmail: stringOrEmpty(data.senderEmail),
    body,
    sentAt,
  };

  return {
    lastMessage,
    lastMessageAt: sentAt,
  };
}

async function processThread({
  threadDoc,
  options,
  counters,
  bulkWriter,
}: {
  threadDoc: FirebaseFirestore.QueryDocumentSnapshot<FirebaseFirestore.DocumentData>;
  options: CliOptions;
  counters: Counters;
  bulkWriter: FirebaseFirestore.BulkWriter;
}): Promise<void> {
  const status = classifyLastMessage(threadDoc.data().lastMessage);
  if (status === 'valid') {
    counters.alreadyHydrated += 1;
    return;
  }

  if (status === 'missing') {
    counters.missingLastMessage += 1;
  } else {
    counters.malformedLastMessage += 1;
  }
  counters.needsUpdate += 1;

  const latestMessageSnap = await threadDoc.ref
    .collection('messages')
    .orderBy('sentAt', 'desc')
    .limit(1)
    .get();

  if (latestMessageSnap.empty) {
    counters.threadsWithoutMessages += 1;
    return;
  }

  const payload = lastMessagePayloadFromDoc(latestMessageSnap.docs[0]);
  if (options.dryRun) {
    return;
  }

  bulkWriter.set(threadDoc.ref, payload, { merge: true });
  counters.writesQueued += 1;
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  console.log('Backfill chat_threads.lastMessage from latest message');
  console.log(`dryRun=${options.dryRun}`);
  console.log(`threadsPageSize=${options.threadsPageSize}`);
  console.log(
    `maxThreads=${options.maxThreads == null ? 'unbounded' : options.maxThreads}`,
  );
  console.log(
    `FIRESTORE_EMULATOR_HOST=${process.env.FIRESTORE_EMULATOR_HOST ?? ''}`,
  );
  console.log(
    `GOOGLE_CLOUD_PROJECT=${process.env.GOOGLE_CLOUD_PROJECT ?? ''} GCLOUD_PROJECT=${process.env.GCLOUD_PROJECT ?? ''}`,
  );
  console.log(`admin.projectId=${admin.app().options.projectId ?? ''}`);

  const counters: Counters = {
    threadsScanned: 0,
    alreadyHydrated: 0,
    missingLastMessage: 0,
    malformedLastMessage: 0,
    needsUpdate: 0,
    threadsWithoutMessages: 0,
    writesQueued: 0,
  };

  const bulkWriter = db.bulkWriter();
  bulkWriter.onWriteError((error) => {
    console.log(
      `BulkWriter error (${error.code}) at ${error.documentRef.path}: ${error.message}`,
    );
    return error.failedAttempts < 5;
  });

  let lastThreadId: string | null = null;

  while (true) {
    if (options.maxThreads != null && counters.threadsScanned >= options.maxThreads) {
      break;
    }

    let query: FirebaseFirestore.Query<FirebaseFirestore.DocumentData> = db
      .collection('chat_threads')
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(options.threadsPageSize);
    if (lastThreadId != null) {
      query = query.startAfter(lastThreadId);
    }

    const page = await query.get();
    if (page.empty) break;

    for (const threadDoc of page.docs) {
      if (options.maxThreads != null && counters.threadsScanned >= options.maxThreads) {
        break;
      }

      counters.threadsScanned += 1;
      await processThread({
        threadDoc,
        options,
        counters,
        bulkWriter,
      });

      if (counters.threadsScanned % 100 === 0) {
        console.log(
          `Progress threads=${counters.threadsScanned} needsUpdate=${counters.needsUpdate} queuedWrites=${counters.writesQueued} noMessages=${counters.threadsWithoutMessages}`,
        );
      }
    }

    lastThreadId = page.docs[page.docs.length - 1].id;
    if (page.size < options.threadsPageSize) break;
  }

  await bulkWriter.close();

  console.log(`Threads scanned: ${counters.threadsScanned}`);
  console.log(`Already hydrated: ${counters.alreadyHydrated}`);
  console.log(`Missing lastMessage: ${counters.missingLastMessage}`);
  console.log(`Malformed lastMessage: ${counters.malformedLastMessage}`);
  console.log(`Needs update: ${counters.needsUpdate}`);
  console.log(`Threads without messages: ${counters.threadsWithoutMessages}`);
  console.log(`Writes queued: ${counters.writesQueued}`);
  console.log(options.dryRun ? 'Dry run completed.' : 'Backfill completed.');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
