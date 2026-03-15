/**
 * Timezone-aware quiet hours logic for notification dispatch.
 *
 * Design invariant: the same QuietHours document produces identical
 * "is quiet now?" results in Flutter and here. Both sides use the IANA
 * timezone string stored in the document and the same overnight-range
 * arithmetic. Fallback to UTC when the timezone field is absent or invalid.
 */

export interface QuietHours {
  enabled: boolean;
  /** Local start of quiet period (inclusive). Integer 0–23. */
  startHour: number;
  /** Local end of quiet period (exclusive). Integer 0–23. */
  endHour: number;
  /** IANA timezone identifier, e.g. "Europe/Madrid". Defaults to "UTC". */
  timezone: string;
}

// ---------------------------------------------------------------------------
// Parsing
// ---------------------------------------------------------------------------

function parseIntHour(value: unknown): number | null {
  if (typeof value !== 'number' || !Number.isFinite(value)) return null;
  const h = Math.floor(value);
  return h >= 0 && h <= 23 ? h : null;
}

/**
 * Parses the quietHours field from a raw Firestore document map.
 * Returns null if the field is absent or malformed.
 */
export function parseQuietHours(
  data: Record<string, unknown>,
): QuietHours | null {
  const raw = data['quietHours'];
  if (raw == null || typeof raw !== 'object' || Array.isArray(raw)) return null;

  const qh = raw as Record<string, unknown>;

  if (typeof qh['enabled'] !== 'boolean') return null;

  const startHour = parseIntHour(qh['startHour']);
  const endHour = parseIntHour(qh['endHour']);
  if (startHour === null || endHour === null) return null;

  const rawTz = qh['timezone'];
  const timezone =
    typeof rawTz === 'string' && rawTz.trim().length > 0
      ? rawTz.trim()
      : 'UTC';

  return { enabled: qh['enabled'], startHour, endHour, timezone };
}

// ---------------------------------------------------------------------------
// Quiet-hours check
// ---------------------------------------------------------------------------

/**
 * Returns the current local hour (0–23) in the given IANA timezone.
 * Falls back to UTC if the timezone identifier is unrecognised.
 */
function localHour(timezone: string, now: Date): number {
  try {
    // Intl.DateTimeFormat is available in Node ≥ 13 (Firebase Functions Node 20).
    const formatter = new Intl.DateTimeFormat('en-US', {
      hour: 'numeric',
      hour12: false,
      timeZone: timezone,
    });
    const raw = formatter.format(now);
    // hour12:false with 'numeric' can produce "24" for midnight in some locales.
    const h = parseInt(raw, 10) % 24;
    return Number.isFinite(h) ? h : now.getUTCHours();
  } catch {
    return now.getUTCHours();
  }
}

/**
 * Returns true if `now` falls within the quiet period.
 *
 * Supports overnight ranges: startHour=22, endHour=8 means
 * "quiet from 22:00 until 08:00 (next day)".
 *
 * Mirror of QuietHoursConfig.isCurrentlyQuiet() in Dart.
 */
export function isQuiet(quietHours: QuietHours, now: Date = new Date()): boolean {
  if (!quietHours.enabled) return false;

  const h = localHour(quietHours.timezone, now);
  const { startHour, endHour } = quietHours;

  if (startHour === endHour) return false; // degenerate: no quiet period

  // Same-day range: e.g. 02–06
  if (startHour < endHour) {
    return h >= startHour && h < endHour;
  }

  // Overnight range: e.g. 22–08 → quiet if h ≥ 22 OR h < 8
  return h >= startHour || h < endHour;
}

// ---------------------------------------------------------------------------
// Firestore fetch
// ---------------------------------------------------------------------------

/**
 * Reads the user's quietHours preference from Firestore.
 * Returns null if the document does not exist or the field is absent.
 */
export async function fetchQuietHours(
  db: FirebaseFirestore.Firestore,
  uid: string,
): Promise<QuietHours | null> {
  const snap = await db
    .collection('users')
    .doc(uid)
    .collection('notificationPreferences')
    .doc('prefs')
    .get();

  if (!snap.exists) return null;
  return parseQuietHours(snap.data() ?? {});
}
