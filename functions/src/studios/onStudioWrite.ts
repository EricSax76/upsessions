import * as functions from 'firebase-functions';

import { admin } from '../firebase';
import { region } from '../region';

const CIF_REGEX = /^[ABCDEFGHJKLMNPQRSUVW]\d{7}[0-9A-J]$/;

const REQUIRED_STRING_FIELDS = [
  'name',
  'cif',
  'businessName',
  'city',
  'province',
  'postalCode',
  'vatNumber',
  'licenseNumber',
  'contactEmail',
  'contactPhone',
  'accessibilityInfo',
] as const;

function isRecord(value: unknown): value is Record<string, unknown> {
  return value != null && typeof value === 'object' && !Array.isArray(value);
}

function isNonEmptyString(value: unknown): value is string {
  return typeof value === 'string' && value.trim().length > 0;
}

export function validateStudioData(data: Record<string, unknown>): string[] {
  const errors: string[] = [];

  for (const field of REQUIRED_STRING_FIELDS) {
    if (!isNonEmptyString(data[field])) {
      errors.push(`${field} must be a non-empty string`);
    }
  }

  const maxRoomCapacity = data.maxRoomCapacity;
  if (
    typeof maxRoomCapacity !== 'number'
    || !Number.isInteger(maxRoomCapacity)
    || maxRoomCapacity <= 0
  ) {
    errors.push('maxRoomCapacity must be an integer > 0');
  }

  if (typeof data.noiseOrdinanceCompliant !== 'boolean') {
    errors.push('noiseOrdinanceCompliant must be a boolean');
  }

  const openingHours = data.openingHours;
  if (!isRecord(openingHours) || Object.keys(openingHours).length === 0) {
    errors.push('openingHours must be a non-empty map');
  }

  const insuranceExpiry = data.insuranceExpiry;
  if (!(insuranceExpiry instanceof admin.firestore.Timestamp)) {
    errors.push('insuranceExpiry must be a Firestore timestamp');
  } else if (insuranceExpiry.toMillis() < Date.now()) {
    errors.push('insuranceExpiry cannot be in the past');
  }

  const cif = data.cif;
  if (typeof cif === 'string' && !CIF_REGEX.test(cif.trim().toUpperCase())) {
    errors.push('cif does not match Spanish CIF format');
  }

  return errors;
}

async function ensureUpdatedAt(
  ref: admin.firestore.DocumentReference,
  updatedAt: unknown,
): Promise<void> {
  if (updatedAt instanceof admin.firestore.Timestamp) {
    return;
  }

  await ref.set(
    { updatedAt: admin.firestore.FieldValue.serverTimestamp() },
    { merge: true },
  );
}

export const onStudioCreated = region.firestore
  .document('studios/{studioId}')
  .onCreate(async (snapshot) => {
    const data = snapshot.data() as Record<string, unknown> | undefined;
    if (!data) return;

    const errors = validateStudioData(data);
    if (errors.length) {
      await snapshot.ref.delete();
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Studio validation failed on create: ${errors.join('; ')}`,
      );
    }

    await ensureUpdatedAt(snapshot.ref, data.updatedAt);
  });

export const onStudioUpdated = region.firestore
  .document('studios/{studioId}')
  .onUpdate(async (change) => {
    const before = change.before.data() as Record<string, unknown> | undefined;
    const after = change.after.data() as Record<string, unknown> | undefined;

    if (!before || !after) return;

    const errors = validateStudioData(after);
    if (errors.length) {
      await change.after.ref.set(before);
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Studio validation failed on update: ${errors.join('; ')}`,
      );
    }

    await ensureUpdatedAt(change.after.ref, after.updatedAt);
  });
