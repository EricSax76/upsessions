import { admin } from '../firebase';

function stringOrEmpty(value: unknown): string {
  return typeof value === 'string' ? value.trim() : '';
}

function intOrNull(value: unknown): number | null {
  if (typeof value !== 'number' || !Number.isFinite(value)) return null;
  const parsed = Math.floor(value);
  return parsed > 0 ? parsed : null;
}

function boolOrDefault(value: unknown, fallback: boolean): boolean {
  if (typeof value === 'boolean') return value;
  return fallback;
}

export function venuePayloadFromStudio(
  studioId: string,
  studioData: Record<string, unknown>,
): Record<string, unknown> {
  const maxCapacity = intOrNull(studioData.maxRoomCapacity) ?? 1;
  const description = stringOrEmpty(studioData.description);
  const accessibility = stringOrEmpty(studioData.accessibilityInfo);
  const contactEmail = stringOrEmpty(studioData.contactEmail);
  const contactPhone = stringOrEmpty(studioData.contactPhone);

  return {
    ownerId: stringOrEmpty(studioData.ownerId),
    name: stringOrEmpty(studioData.name),
    description: description || 'Local sincronizado desde modulo studios.',
    address: stringOrEmpty(studioData.address),
    city: stringOrEmpty(studioData.city),
    province: stringOrEmpty(studioData.province),
    postalCode: stringOrEmpty(studioData.postalCode) || null,
    contactEmail: contactEmail || 'studio@upsessions.app',
    contactPhone: contactPhone || '+34 000 000 000',
    licenseNumber: stringOrEmpty(studioData.licenseNumber),
    maxCapacity,
    accessibilityInfo: accessibility || 'Informacion no disponible',
    isPublic: true,
    isActive: boolOrDefault(studioData.isActive, true),
    sourceType: 'studio',
    sourceId: studioId,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };
}

export function shouldSyncStudioProjection(
  beforeData: Record<string, unknown> | undefined,
  afterData: Record<string, unknown> | undefined,
): boolean {
  if (!afterData) return false;
  if (!beforeData) return true;

  const trackedKeys = [
    'ownerId',
    'name',
    'description',
    'address',
    'city',
    'province',
    'postalCode',
    'contactEmail',
    'contactPhone',
    'licenseNumber',
    'maxRoomCapacity',
    'accessibilityInfo',
    'isActive',
  ];

  for (const key of trackedKeys) {
    const beforeValue = beforeData[key];
    const afterValue = afterData[key];
    if (JSON.stringify(beforeValue) != JSON.stringify(afterValue)) {
      return true;
    }
  }
  return false;
}

export async function syncVenueProjectionToJamSessions(
  venueId: string,
  venueData: Record<string, unknown>,
): Promise<void> {
  const resolvedVenueName = stringOrEmpty(venueData.name);
  const resolvedCity = stringOrEmpty(venueData.city);
  const resolvedProvince = stringOrEmpty(venueData.province);
  const maxCapacity = intOrNull(venueData.maxCapacity);
  if (
    resolvedVenueName.length === 0
    || resolvedCity.length === 0
    || resolvedProvince.length === 0
  ) {
    return;
  }

  const db = admin.firestore();
  const now = admin.firestore.Timestamp.now();
  const snapshot = await db
    .collection('jam_sessions')
    .where('venueId', '==', venueId)
    .where('date', '>=', now)
    .limit(500)
    .get();

  if (snapshot.empty) return;

  const batch = db.batch();
  for (const doc of snapshot.docs) {
    const payload: Record<string, unknown> = {
      location: resolvedVenueName,
      city: resolvedCity,
      province: resolvedProvince,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const existingMaxAttendees = intOrNull(doc.get('maxAttendees'));
    if (maxCapacity != null && existingMaxAttendees == null) {
      payload.maxAttendees = maxCapacity;
    }
    batch.set(doc.ref, payload, { merge: true });
  }
  await batch.commit();
}
