import * as functions from 'firebase-functions';

import { admin } from '../firebase';

import {
  CONSENT_EVIDENCE_RETENTION_DAYS,
  DEFAULT_DATA_PROCESSING_LEGAL_BASIS,
} from './constants';
import { primaryRoleFrom, resolveRoles, tokenRole } from './roles';
import {
  assertVersionOrThrow,
  boolOrDefault,
  extractClientIp,
  extractUserAgent,
  hashOrNull,
  isPolicyType,
  normalizePolicyHash,
  normalizeSource,
  record,
  stringOrEmpty,
  timestampPlusDays,
} from './shared';
import type { ConsentAction } from './types';

function authenticatedUid(context: functions.https.CallableContext): string {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Authentication required.');
  }
  return context.auth.uid;
}

export async function acceptLegalBundleAction(
  data: unknown,
  context: functions.https.CallableContext,
): Promise<Record<string, unknown>> {
  const uid = authenticatedUid(context);
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

  const termsPolicyHash = acceptTerms
    ? normalizePolicyHash(policyHashes.terms, 'policyHashes.terms')
    : null;
  const privacyPolicyHash = acceptPrivacy
    ? normalizePolicyHash(policyHashes.privacy, 'policyHashes.privacy')
    : null;
  const marketingPolicyHash = normalizePolicyHash(
    policyHashes.marketing,
    'policyHashes.marketing',
  );

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
          dataProcessingConsent: false,
          dataProcessingLegalBasis: DEFAULT_DATA_PROCESSING_LEGAL_BASIS,
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
      evidenceRetentionDays: CONSENT_EVIDENCE_RETENTION_DAYS,
      evidencePurgeAt: timestampPlusDays(CONSENT_EVIDENCE_RETENTION_DAYS),
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
      dataProcessingConsent: false,
      dataProcessingLegalBasis: DEFAULT_DATA_PROCESSING_LEGAL_BASIS,
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
}

export async function acceptLegalDocsAction(
  data: unknown,
  context: functions.https.CallableContext,
): Promise<Record<string, unknown>> {
  const uid = authenticatedUid(context);
  const body = record(data);
  const policyType = stringOrEmpty(body.policyType).trim().toLowerCase();
  const version = stringOrEmpty(body.version).trim();
  const actionRaw = stringOrEmpty(body.action).trim().toLowerCase() || 'accept';
  const source = normalizeSource(body.source);
  const policyHash = normalizePolicyHash(body.policyHash, 'policyHash');

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
          dataProcessingConsent: false,
          dataProcessingLegalBasis: DEFAULT_DATA_PROCESSING_LEGAL_BASIS,
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
      evidenceRetentionDays: CONSENT_EVIDENCE_RETENTION_DAYS,
      evidencePurgeAt: timestampPlusDays(CONSENT_EVIDENCE_RETENTION_DAYS),
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
      dataProcessingConsent: false,
      dataProcessingLegalBasis: DEFAULT_DATA_PROCESSING_LEGAL_BASIS,
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
}
