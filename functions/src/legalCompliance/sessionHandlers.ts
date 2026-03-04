import * as functions from 'firebase-functions';

import { admin } from '../firebase';
import { region } from '../region';

import { DEFAULT_DATA_PROCESSING_LEGAL_BASIS } from './constants';
import { primaryRoleFrom, resolveRoles, tokenRole } from './roles';
import { record, sanitizeLocale, sanitizePhone, stringOrEmpty } from './shared';

export const syncUserSession = region.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
  }

  const uid = context.auth.uid;
  const token = record(context.auth.token);
  const roles = await resolveRoles(uid, tokenRole(context));
  const primaryRole = primaryRoleFrom(roles);
  const userRef = admin.firestore().collection('users').doc(uid);
  const timestamp = admin.firestore.FieldValue.serverTimestamp();
  const locale = sanitizeLocale(record(data).locale);

  await admin.firestore().runTransaction(async (transaction) => {
    const snap = await transaction.get(userRef);
    if (!snap.exists) {
      transaction.set(
        userRef,
        {
          createdAt: timestamp,
          marketingConsent: false,
          marketingConsentAt: null,
          marketingConsentRevokedAt: null,
          dataProcessingConsent: false,
          dataProcessingLegalBasis: DEFAULT_DATA_PROCESSING_LEGAL_BASIS,
          deletedAt: null,
          purgeAt: null,
        },
        { merge: true },
      );
    }

    const payload: Record<string, unknown> = {
      email: stringOrEmpty(token.email),
      displayName: stringOrEmpty(token.name) || stringOrEmpty(token.email) || 'Músico',
      photoUrl: stringOrEmpty(token.picture) || null,
      isVerified: Boolean(token.email_verified),
      role: primaryRole,
      roles,
      dataProcessingConsent: false,
      dataProcessingLegalBasis: DEFAULT_DATA_PROCESSING_LEGAL_BASIS,
      lastLoginAt: timestamp,
      updatedAt: timestamp,
    };
    if (locale != null) {
      payload.locale = locale;
    }
    transaction.set(userRef, payload, { merge: true });
  });

  return { ok: true };
});

export const updateUserComplianceProfile = region.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
  }

  const body = record(data);
  const locale = body.locale === null ? null : sanitizeLocale(body.locale);
  const phoneNumber = body.phoneNumber === null ? null : sanitizePhone(body.phoneNumber);

  if (body.locale !== undefined && body.locale !== null && locale == null) {
    throw new functions.https.HttpsError('invalid-argument', 'locale has an invalid format.');
  }

  if (body.phoneNumber !== undefined && body.phoneNumber !== null && phoneNumber == null) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'phoneNumber has an invalid format.',
    );
  }

  if (body.locale === undefined && body.phoneNumber === undefined) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Provide at least one field: locale or phoneNumber.',
    );
  }

  const payload: Record<string, unknown> = {
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  if (body.locale !== undefined) {
    payload.locale = locale;
  }
  if (body.phoneNumber !== undefined) {
    payload.phoneNumber = phoneNumber;
  }

  await admin.firestore().collection('users').doc(context.auth.uid).set(payload, { merge: true });

  return {
    ok: true,
    locale: body.locale !== undefined ? locale : undefined,
    phoneNumber: body.phoneNumber !== undefined ? phoneNumber : undefined,
  };
});
