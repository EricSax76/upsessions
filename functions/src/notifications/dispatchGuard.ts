import { admin } from '../firebase';
import type { ScenarioKey } from './scenarioKeys';


export interface DispatchCoords {
  /** Source document id — the event that caused this notification. */
  eventId: string;
  /** Recipient uid. */
  uid: string;
  /** Wire-stable scenario key from SCENARIO_KEYS. */
  scenarioKey: ScenarioKey;
}

/** Converts coords to a safe Firestore document id (no slashes or dots). */
export function buildDispatchDocId({
  eventId,
  uid,
  scenarioKey,
}: DispatchCoords): string {
  // Replace any character that is not alphanumeric, dash, or underscore.
  const safe = (s: string) => s.replace(/[^a-zA-Z0-9_-]/g, '_');
  return `${safe(scenarioKey)}_${safe(uid)}_${safe(eventId)}`;
}

/**
 * Attempts to claim the dispatch slot for this event × recipient × scenario.
 *
 * @returns true  → first dispatch; caller SHOULD send the push.
 * @returns false → already dispatched; caller MUST NOT send (duplicate).
 * @throws        on unexpected Firestore errors (let the Function retry).
 */
export async function claimDispatch(coords: DispatchCoords): Promise<boolean> {
  const db = admin.firestore();
  const docRef = db
    .collection('notificationDispatches')
    .doc(buildDispatchDocId(coords));

  let claimed = false;

  try {
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(docRef);
      if (snap.exists) {
        // Sentinel: abort without throwing a retriable error.
        return;
      }
      tx.create(docRef, {
        eventId: coords.eventId,
        uid: coords.uid,
        scenarioKey: coords.scenarioKey,
        dispatchedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      claimed = true;
    });
  } catch (err: unknown) {
    
    const msg = err instanceof Error ? err.message : String(err);
    if (
      msg.includes('ALREADY_EXISTS') ||
      msg.includes('already exists') ||
      msg.includes('6 ALREADY_EXISTS')
    ) {
      return false;
    }
    throw err;
  }

  return claimed;
}
