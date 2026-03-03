import { createHash } from 'node:crypto';

import * as functions from 'firebase-functions';

import { admin } from './firebase';
import { region } from './region';

type PolicyType = 'terms' | 'privacy' | 'marketing';
type ConsentAction = 'accept' | 'revoke';
type ConsentSource = 'web' | 'android' | 'ios' | 'api';
type UserRole = 'musician' | 'event_manager' | 'studio' | 'admin' | 'multi';

const POLICY_TYPES: readonly PolicyType[] = ['terms', 'privacy', 'marketing'];
const CONSENT_SOURCES: readonly ConsentSource[] = ['web', 'android', 'ios', 'api'];
const VERSION_PATTERN = /^[A-Za-z0-9._-]{1,64}$/;
const LOCALE_PATTERN = /^[a-z]{2}(?:-[A-Z]{2})?$/;
const PHONE_PATTERN = /^[+0-9()\-.\s]{6,24}$/;
const DEFAULT_ROLE: UserRole = 'musician';
const GDPR_RETENTION_DAYS = 30;

function isPolicyType(value: string): value is PolicyType {
  return (POLICY_TYPES as readonly string[]).includes(value);
}

function isConsentSource(value: string): value is ConsentSource {
  return (CONSENT_SOURCES as readonly string[]).includes(value);
}

function record(value: unknown): Record<string, unknown> {
  if (value == null || typeof value !== 'object' || Array.isArray(value)) {
    return {};
  }
  return value as Record<string, unknown>;
}

function stringOrEmpty(value: unknown): string {
  return typeof value === 'string' ? value : '';
}

function boolOrDefault(value: unknown, fallback: boolean): boolean {
  return typeof value === 'boolean' ? value : fallback;
}

function normalizeSource(value: unknown): ConsentSource {
  const source = stringOrEmpty(value).trim().toLowerCase();
  return isConsentSource(source) ? source : 'api';
}

function assertVersionOrThrow(version: string, fieldName = 'version'): void {
  if (!VERSION_PATTERN.test(version)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `${fieldName} must be 1-64 chars and use [A-Za-z0-9._-].`,
    );
  }
}

function normalizePolicyHash(value: unknown): string | null {
  const hash = stringOrEmpty(value).trim().toLowerCase();
  if (!hash) return null;
  // sha256 hex canonical length.
  if (/^[a-f0-9]{64}$/.test(hash)) return hash;
  // Store a normalized hash if caller sends plain text by mistake.
  return createHash('sha256').update(hash).digest('hex');
}

function sanitizeLocale(value: unknown): string | null {
  const locale = stringOrEmpty(value).trim();
  if (!locale) return null;
  return LOCALE_PATTERN.test(locale) ? locale : null;
}

function sanitizePhone(value: unknown): string | null {
  const raw = stringOrEmpty(value).trim();
  if (!raw) return null;
  if (!PHONE_PATTERN.test(raw)) return null;
  return raw.replace(/\s+/g, ' ');
}

function hashOrNull(value: string | null): string | null {
  if (!value) return null;
  return createHash('sha256').update(value).digest('hex');
}

function firstHeaderValue(value: string | string[] | undefined): string | null {
  if (typeof value === 'string') return value;
  if (Array.isArray(value) && value.length > 0 && typeof value[0] === 'string') {
    return value[0];
  }
  return null;
}

function extractClientIp(context: functions.https.CallableContext): string | null {
  const forwarded = firstHeaderValue(context.rawRequest.headers['x-forwarded-for']);
  if (forwarded && forwarded.trim()) {
    const firstIp = forwarded.split(',')[0]?.trim();
    if (firstIp) return firstIp;
  }
  const rawIp = context.rawRequest.ip;
  if (typeof rawIp === 'string' && rawIp.trim()) {
    return rawIp.trim();
  }
  return null;
}

function extractUserAgent(context: functions.https.CallableContext): string | null {
  const userAgent = firstHeaderValue(context.rawRequest.headers['user-agent']);
  if (!userAgent) return null;
  const trimmed = userAgent.trim();
  return trimmed ? trimmed : null;
}

function normalizeRole(rawRole: string): UserRole {
  const role = rawRole.trim().toLowerCase();
  if (!role) return DEFAULT_ROLE;
  if (role === 'eventmanager' || role === 'manager') return 'event_manager';
  if (role === 'event_manager') return 'event_manager';
  if (role === 'studio') return 'studio';
  if (role === 'admin') return 'admin';
  if (role === 'musician') return 'musician';
  return DEFAULT_ROLE;
}

function tokenRole(context: functions.https.CallableContext): UserRole | null {
  const token = record(context.auth?.token);
  const rawRole = stringOrEmpty(token.role).trim();
  if (!rawRole) return null;
  return normalizeRole(rawRole);
}

function primaryRoleFrom(roles: UserRole[]): UserRole {
  if (roles.includes('admin')) return 'admin';
  if (roles.length <= 1) return roles[0] ?? DEFAULT_ROLE;
  return 'multi';
}

async function resolveRoles(uid: string, hintedRole: UserRole | null): Promise<UserRole[]> {
  const db = admin.firestore();
  const [managerDoc, studioDocs, musicianDoc, musicianByOwnerId] = await Promise.all([
    db.collection('event_managers').doc(uid).get(),
    db.collection('studios').where('ownerId', '==', uid).limit(1).get(),
    db.collection('musicians').doc(uid).get(),
    db.collection('musicians').where('ownerId', '==', uid).limit(1).get(),
  ]);

  const roles = new Set<UserRole>();
  if (hintedRole != null) {
    roles.add(hintedRole);
  }
  if (managerDoc.exists) {
    roles.add('event_manager');
  }
  if (!studioDocs.empty) {
    roles.add('studio');
  }
  if (musicianDoc.exists || !musicianByOwnerId.empty) {
    roles.add('musician');
  }
  if (!roles.size) {
    roles.add(DEFAULT_ROLE);
  }

  return Array.from(roles.values());
}

function nowPlusDays(days: number): Date {
  return new Date(Date.now() + days * 24 * 60 * 60 * 1000);
}

export const onAuthUserCreateBootstrap = region.auth.user().onCreate(async (user) => {
  const userRef = admin.firestore().collection('users').doc(user.uid);
  const timestamp = admin.firestore.FieldValue.serverTimestamp();
  await userRef.set(
    {
      email: user.email ?? '',
      displayName: user.displayName ?? user.email ?? 'Músico',
      photoUrl: user.photoURL ?? null,
      isVerified: user.emailVerified ?? false,
      role: DEFAULT_ROLE,
      roles: [DEFAULT_ROLE],
      locale: null,
      phoneNumber: null,
      marketingConsent: false,
      marketingConsentAt: null,
      marketingConsentRevokedAt: null,
      termsVersion: null,
      privacyVersion: null,
      acceptedTermsAt: null,
      acceptedPrivacyAt: null,
      dataProcessingConsent: true,
      createdAt: timestamp,
      lastLoginAt: timestamp,
      deletedAt: null,
      purgeAt: null,
      updatedAt: timestamp,
    },
    { merge: true },
  );
});

export const onAuthUserDeleteSoftDelete = region.auth.user().onDelete(async (user) => {
  const userRef = admin.firestore().collection('users').doc(user.uid);
  await userRef.set(
    {
      deletedAt: admin.firestore.FieldValue.serverTimestamp(),
      purgeAt: admin.firestore.Timestamp.fromDate(nowPlusDays(GDPR_RETENTION_DAYS)),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
});

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
          dataProcessingConsent: true,
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

export const acceptLegalBundle = region.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
  }

  const body = record(data);
  const acceptTerms = boolOrDefault(body.acceptTerms, true);
  const acceptPrivacy = boolOrDefault(body.acceptPrivacy, true);
  const marketingOptIn = boolOrDefault(body.marketingOptIn, false);

  if (!acceptTerms && !acceptPrivacy) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'At least one legal document must be accepted: acceptTerms or acceptPrivacy.',
    );
  }

  const source = normalizeSource(body.source);
  const policyHashes = record(body.policyHashes);

  const termsVersion = stringOrEmpty(body.termsVersion).trim();
  const privacyVersion = stringOrEmpty(body.privacyVersion).trim();
  const marketingVersion = stringOrEmpty(body.marketingVersion).trim();

  if (acceptTerms) {
    assertVersionOrThrow(termsVersion, 'termsVersion');
  }
  if (acceptPrivacy) {
    assertVersionOrThrow(privacyVersion, 'privacyVersion');
  }
  assertVersionOrThrow(marketingVersion, 'marketingVersion');

  const termsPolicyHash = normalizePolicyHash(policyHashes.terms);
  const privacyPolicyHash = normalizePolicyHash(policyHashes.privacy);
  const marketingPolicyHash = normalizePolicyHash(policyHashes.marketing);

  const uid = context.auth.uid;
  const roles = await resolveRoles(uid, tokenRole(context));
  const primaryRole = primaryRoleFrom(roles);
  const userRef = admin.firestore().collection('users').doc(uid);
  const timestamp = admin.firestore.FieldValue.serverTimestamp();
  const ipHash = hashOrNull(extractClientIp(context));
  const userAgentHash = hashOrNull(extractUserAgent(context));

  await admin.firestore().runTransaction(async (transaction) => {
    const userSnap = await transaction.get(userRef);
    if (!userSnap.exists) {
      transaction.set(
        userRef,
        {
          createdAt: timestamp,
          marketingConsent: false,
          marketingConsentAt: null,
          marketingConsentRevokedAt: null,
          dataProcessingConsent: true,
          deletedAt: null,
          purgeAt: null,
        },
        { merge: true },
      );
    }

    const baseAcceptancePayload: Record<string, unknown> = {
      source,
      consentSource: source,
      ipHash,
      userAgentHash,
      updatedAt: timestamp,
    };

    if (acceptTerms) {
      const termsRef = userRef.collection('policy_acceptances').doc(`terms_${termsVersion}`);
      transaction.set(
        termsRef,
        {
          ...baseAcceptancePayload,
          policyType: 'terms',
          version: termsVersion,
          policyHash: termsPolicyHash,
          status: 'accepted',
          acceptedAt: timestamp,
          consentEvidenceAt: timestamp,
          revokedAt: null,
          consentRevokedAt: null,
        },
        { merge: true },
      );
    }

    if (acceptPrivacy) {
      const privacyRef = userRef.collection('policy_acceptances').doc(`privacy_${privacyVersion}`);
      transaction.set(
        privacyRef,
        {
          ...baseAcceptancePayload,
          policyType: 'privacy',
          version: privacyVersion,
          policyHash: privacyPolicyHash,
          status: 'accepted',
          acceptedAt: timestamp,
          consentEvidenceAt: timestamp,
          revokedAt: null,
          consentRevokedAt: null,
        },
        { merge: true },
      );
    }

    const marketingRef = userRef.collection('policy_acceptances').doc(`marketing_${marketingVersion}`);
    transaction.set(
      marketingRef,
      {
        ...baseAcceptancePayload,
        policyType: 'marketing',
        version: marketingVersion,
        policyHash: marketingPolicyHash,
        status: marketingOptIn ? 'accepted' : 'revoked',
        acceptedAt: marketingOptIn ? timestamp : null,
        consentEvidenceAt: marketingOptIn ? timestamp : null,
        revokedAt: marketingOptIn ? null : timestamp,
        consentRevokedAt: marketingOptIn ? null : timestamp,
      },
      { merge: true },
    );

    const userPayload: Record<string, unknown> = {
      updatedAt: timestamp,
      role: primaryRole,
      roles,
      marketingConsent: marketingOptIn,
      marketingConsentAt: marketingOptIn ? timestamp : null,
      marketingConsentRevokedAt: marketingOptIn ? null : timestamp,
    };

    if (acceptTerms) {
      userPayload.acceptedTermsAt = timestamp;
      userPayload.termsVersion = termsVersion;
    }
    if (acceptPrivacy) {
      userPayload.acceptedPrivacyAt = timestamp;
      userPayload.privacyVersion = privacyVersion;
    }

    transaction.set(userRef, userPayload, { merge: true });
  });

  return {
    ok: true,
    uid,
    accepted: {
      terms: acceptTerms,
      privacy: acceptPrivacy,
      marketing: marketingOptIn,
    },
    source,
  };
});

export const acceptLegalDocs = region.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
  }

  const body = record(data);
  const policyType = stringOrEmpty(body.policyType).trim().toLowerCase();
  const version = stringOrEmpty(body.version).trim();
  const actionRaw = stringOrEmpty(body.action).trim().toLowerCase() || 'accept';
  const source = normalizeSource(body.source);
  const policyHash = normalizePolicyHash(body.policyHash);

  if (!isPolicyType(policyType)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'policyType must be one of: terms, privacy, marketing.',
    );
  }
  assertVersionOrThrow(version, 'version');

  const action: ConsentAction = actionRaw === 'revoke' ? 'revoke' : 'accept';

  if ((policyType === 'terms' || policyType === 'privacy') && action !== 'accept') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Only marketing consent can be revoked.',
    );
  }

  const uid = context.auth.uid;
  const roles = await resolveRoles(uid, tokenRole(context));
  const primaryRole = primaryRoleFrom(roles);
  const userRef = admin.firestore().collection('users').doc(uid);
  const acceptanceId = `${policyType}_${version}`;
  const acceptanceRef = userRef.collection('policy_acceptances').doc(acceptanceId);
  const timestamp = admin.firestore.FieldValue.serverTimestamp();

  const ipHash = hashOrNull(extractClientIp(context));
  const userAgentHash = hashOrNull(extractUserAgent(context));

  await admin.firestore().runTransaction(async (transaction) => {
    const userSnap = await transaction.get(userRef);
    if (!userSnap.exists) {
      transaction.set(
        userRef,
        {
          createdAt: timestamp,
          marketingConsent: false,
          marketingConsentAt: null,
          marketingConsentRevokedAt: null,
          dataProcessingConsent: true,
          deletedAt: null,
          purgeAt: null,
        },
        { merge: true },
      );
    }

    const acceptancePayload: Record<string, unknown> = {
      policyType,
      version,
      source,
      consentSource: source,
      policyHash,
      ipHash,
      userAgentHash,
      updatedAt: timestamp,
    };

    if (action === 'accept') {
      acceptancePayload.status = 'accepted';
      acceptancePayload.acceptedAt = timestamp;
      acceptancePayload.consentEvidenceAt = timestamp;
      acceptancePayload.revokedAt = null;
      acceptancePayload.consentRevokedAt = null;
    } else {
      acceptancePayload.status = 'revoked';
      acceptancePayload.revokedAt = timestamp;
      acceptancePayload.consentRevokedAt = timestamp;
    }

    transaction.set(acceptanceRef, acceptancePayload, { merge: true });

    const userPayload: Record<string, unknown> = {
      updatedAt: timestamp,
      role: primaryRole,
      roles,
    };

    if (policyType === 'terms') {
      userPayload.acceptedTermsAt = timestamp;
      userPayload.termsVersion = version;
    } else if (policyType === 'privacy') {
      userPayload.acceptedPrivacyAt = timestamp;
      userPayload.privacyVersion = version;
    } else if (action === 'accept') {
      userPayload.marketingConsent = true;
      userPayload.marketingConsentAt = timestamp;
      userPayload.marketingConsentRevokedAt = null;
    } else {
      userPayload.marketingConsent = false;
      userPayload.marketingConsentRevokedAt = timestamp;
    }

    transaction.set(userRef, userPayload, { merge: true });
  });

  return {
    ok: true,
    uid,
    policyType,
    version,
    action,
    source,
  };
});
