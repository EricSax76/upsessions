import { admin } from '../firebase';
import { claimDispatch } from './dispatchGuard';
import { isQuiet, parseQuietHours } from './quietHours';
import {
  PUSH_CAPABLE_SCENARIO_KEYS,
  type ScenarioKey,
} from './scenarioKeys';

function asRecord(value: unknown): Record<string, unknown> {
  if (value == null || typeof value !== 'object' || Array.isArray(value)) {
    return {};
  }
  return value as Record<string, unknown>;
}

function stringOrEmpty(value: unknown): string {
  return typeof value === 'string' ? value.trim() : '';
}

async function fetchUserPushTokens(
  db: FirebaseFirestore.Firestore,
  uid: string,
): Promise<string[]> {
  const [usersTokensSnap, legacyMusicianTokensSnap] = await Promise.all([
    db.collection('users').doc(uid).collection('fcmTokens').get(),
    db.collection('musicians').doc(uid).collection('fcmTokens').get(),
  ]);

  const tokenSet = new Set<string>();
  for (const doc of usersTokensSnap.docs) {
    const token = stringOrEmpty(doc.id);
    if (token) tokenSet.add(token);
  }
  for (const doc of legacyMusicianTokensSnap.docs) {
    const token = stringOrEmpty(doc.id);
    if (token) tokenSet.add(token);
  }
  return Array.from(tokenSet);
}

async function deleteInvalidUserPushTokens(
  db: FirebaseFirestore.Firestore,
  uid: string,
  invalidTokens: string[],
): Promise<void> {
  if (!invalidTokens.length) return;

  await Promise.all(
    invalidTokens.flatMap((token) => [
      db
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token)
        .delete()
        .catch(() => null),
      db
        .collection('musicians')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token)
        .delete()
        .catch(() => null),
    ]),
  );
}

export function isScenarioPushEnabled(
  preferences: Record<string, unknown>,
  scenarioKey: ScenarioKey,
): boolean {
  if (!PUSH_CAPABLE_SCENARIO_KEYS.has(scenarioKey)) {
    return false;
  }

  const scenarios = asRecord(preferences.scenarios);
  const scenario = asRecord(scenarios[scenarioKey]);
  const push = scenario.push;
  if (typeof push === 'boolean') return push;
  // Default opt-in when the preference is missing.
  return true;
}

export function toFcmData(
  scenarioKey: ScenarioKey,
  data: Record<string, unknown> = {},
): Record<string, string> {
  const payload: Record<string, string> = { scenarioKey };

  for (const [key, value] of Object.entries(data)) {
    if (value == null) continue;
    if (typeof value === 'string') {
      payload[key] = value;
      continue;
    }
    if (
      typeof value === 'number'
      || typeof value === 'boolean'
      || typeof value === 'bigint'
    ) {
      payload[key] = String(value);
      continue;
    }
    payload[key] = JSON.stringify(value);
  }

  return payload;
}

export interface SendPushToUserArgs {
  db: FirebaseFirestore.Firestore;
  uid: string;
  eventId: string;
  scenarioKey: ScenarioKey;
  title: string;
  body: string;
  data?: Record<string, unknown>;
}

export type SendPushResult =
  | 'sent'
  | 'duplicate'
  | 'disabled'
  | 'quiet_hours'
  | 'no_tokens';

export async function sendPushToUser(
  args: SendPushToUserArgs,
): Promise<SendPushResult> {
  const uid = stringOrEmpty(args.uid);
  const eventId = stringOrEmpty(args.eventId);
  if (!uid || !eventId) return 'disabled';
  if (!PUSH_CAPABLE_SCENARIO_KEYS.has(args.scenarioKey)) return 'disabled';

  const prefsSnap = await args.db
    .collection('users')
    .doc(uid)
    .collection('notificationPreferences')
    .doc('prefs')
    .get();
  const preferences = prefsSnap.exists ? asRecord(prefsSnap.data()) : {};

  if (!isScenarioPushEnabled(preferences, args.scenarioKey)) {
    return 'disabled';
  }

  const quietHours = parseQuietHours(preferences);
  if (quietHours != null && isQuiet(quietHours)) {
    return 'quiet_hours';
  }

  const shouldSend = await claimDispatch({
    eventId,
    uid,
    scenarioKey: args.scenarioKey,
  });
  if (!shouldSend) {
    return 'duplicate';
  }

  const tokens = await fetchUserPushTokens(args.db, uid);
  if (!tokens.length) {
    return 'no_tokens';
  }

  const payload: admin.messaging.MulticastMessage = {
    tokens,
    notification: {
      title: args.title,
      body: args.body,
    },
    data: toFcmData(args.scenarioKey, args.data),
  };

  const response = await admin.messaging().sendEachForMulticast(payload);
  const invalidTokens: string[] = [];
  response.responses.forEach((res, idx) => {
    if (res.success) return;
    const code = res.error?.code ?? '';
    if (
      code === 'messaging/invalid-registration-token'
      || code === 'messaging/registration-token-not-registered'
    ) {
      invalidTokens.push(tokens[idx]);
    }
  });

  await deleteInvalidUserPushTokens(args.db, uid, invalidTokens);
  return 'sent';
}
