import { admin, db } from './firebase';

type CliOptions = {
  dryRun: boolean;
  groupsPageSize: number;
  rehearsalsPageSize: number;
  maxGroups: number | null;
};

type Counters = {
  groupsScanned: number;
  rehearsalsScanned: number;
  alreadyCorrect: number;
  missingGroupId: number;
  mismatchedGroupId: number;
  needsUpdate: number;
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
  let groupsPageSize = 250;
  let rehearsalsPageSize = 250;
  let maxGroups: number | null = null;

  for (const arg of argv) {
    if (arg === '--dry-run') {
      dryRun = true;
      continue;
    }
    if (arg.startsWith('--groups-page-size=')) {
      groupsPageSize = parsePositiveInt(
        arg.slice('--groups-page-size='.length),
        groupsPageSize,
      );
      continue;
    }
    if (arg.startsWith('--rehearsals-page-size=')) {
      rehearsalsPageSize = parsePositiveInt(
        arg.slice('--rehearsals-page-size='.length),
        rehearsalsPageSize,
      );
      continue;
    }
    if (arg.startsWith('--max-groups=')) {
      maxGroups = parsePositiveInt(arg.slice('--max-groups='.length), 1);
      continue;
    }
  }

  return {
    dryRun,
    groupsPageSize,
    rehearsalsPageSize,
    maxGroups,
  };
}

function groupIdFromValue(value: unknown): string {
  return typeof value === 'string' ? value.trim() : '';
}

async function processGroupRehearsals({
  groupId,
  groupRef,
  options,
  counters,
  bulkWriter,
}: {
  groupId: string;
  groupRef: FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>;
  options: CliOptions;
  counters: Counters;
  bulkWriter: FirebaseFirestore.BulkWriter;
}): Promise<void> {
  let lastRehearsalId: string | null = null;

  while (true) {
    let query = groupRef
      .collection('rehearsals')
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(options.rehearsalsPageSize);

    if (lastRehearsalId != null) {
      query = query.startAfter(lastRehearsalId);
    }

    const rehearsalsPage = await query.get();
    if (rehearsalsPage.empty) break;

    for (const rehearsalDoc of rehearsalsPage.docs) {
      counters.rehearsalsScanned += 1;
      const data = rehearsalDoc.data();
      const existingGroupId = groupIdFromValue(data.groupId);

      if (existingGroupId == groupId) {
        counters.alreadyCorrect += 1;
        continue;
      }

      counters.needsUpdate += 1;
      if (existingGroupId.length === 0) {
        counters.missingGroupId += 1;
      } else {
        counters.mismatchedGroupId += 1;
      }

      if (options.dryRun) {
        continue;
      }

      bulkWriter.set(
        rehearsalDoc.ref,
        {
          groupId,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      counters.writesQueued += 1;
    }

    lastRehearsalId = rehearsalsPage.docs[rehearsalsPage.docs.length - 1].id;
    if (rehearsalsPage.size < options.rehearsalsPageSize) break;
  }
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  console.log('Backfill rehearsals.groupId from parent group path');
  console.log(`dryRun=${options.dryRun}`);
  console.log(
    `groupsPageSize=${options.groupsPageSize} rehearsalsPageSize=${options.rehearsalsPageSize}`,
  );
  console.log(
    `maxGroups=${options.maxGroups == null ? 'unbounded' : options.maxGroups}`,
  );
  console.log(
    `FIRESTORE_EMULATOR_HOST=${process.env.FIRESTORE_EMULATOR_HOST ?? ''}`,
  );
  console.log(
    `GOOGLE_CLOUD_PROJECT=${process.env.GOOGLE_CLOUD_PROJECT ?? ''} GCLOUD_PROJECT=${process.env.GCLOUD_PROJECT ?? ''}`,
  );
  console.log(`admin.projectId=${admin.app().options.projectId ?? ''}`);

  const counters: Counters = {
    groupsScanned: 0,
    rehearsalsScanned: 0,
    alreadyCorrect: 0,
    missingGroupId: 0,
    mismatchedGroupId: 0,
    needsUpdate: 0,
    writesQueued: 0,
  };

  const bulkWriter = db.bulkWriter();
  bulkWriter.onWriteError((error) => {
    console.log(
      `BulkWriter error (${error.code}) at ${error.documentRef.path}: ${error.message}`,
    );
    return error.failedAttempts < 5;
  });

  let lastGroupId: string | null = null;

  while (true) {
    if (options.maxGroups != null && counters.groupsScanned >= options.maxGroups) {
      break;
    }

    let query = db
      .collection('groups')
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(options.groupsPageSize);

    if (lastGroupId != null) {
      query = query.startAfter(lastGroupId);
    }

    const groupsPage = await query.get();
    if (groupsPage.empty) break;

    for (const groupDoc of groupsPage.docs) {
      if (options.maxGroups != null && counters.groupsScanned >= options.maxGroups) {
        break;
      }

      counters.groupsScanned += 1;
      await processGroupRehearsals({
        groupId: groupDoc.id,
        groupRef: groupDoc.ref,
        options,
        counters,
        bulkWriter,
      });

      if (counters.groupsScanned % 100 == 0) {
        console.log(
          `Progress groups=${counters.groupsScanned} rehearsals=${counters.rehearsalsScanned} needsUpdate=${counters.needsUpdate} queuedWrites=${counters.writesQueued}`,
        );
      }
    }

    lastGroupId = groupsPage.docs[groupsPage.docs.length - 1].id;
    if (groupsPage.size < options.groupsPageSize) break;
  }

  if (!options.dryRun) {
    await bulkWriter.close();
  } else {
    await bulkWriter.close();
  }

  console.log(`Groups scanned: ${counters.groupsScanned}`);
  console.log(`Rehearsals scanned: ${counters.rehearsalsScanned}`);
  console.log(`Already correct: ${counters.alreadyCorrect}`);
  console.log(`Missing groupId: ${counters.missingGroupId}`);
  console.log(`Mismatched groupId: ${counters.mismatchedGroupId}`);
  console.log(`Needs update: ${counters.needsUpdate}`);
  console.log(`Writes queued: ${counters.writesQueued}`);
  console.log(options.dryRun ? 'Dry run completed.' : 'Backfill completed.');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
