import { admin } from '../firebase';
import { region } from '../region';

import {
  DEFAULT_DATA_PROCESSING_LEGAL_BASIS,
  DEFAULT_ROLE,
  GDPR_RETENTION_DAYS,
} from './constants';
import { nowPlusDays } from './shared';

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
      dataProcessingConsent: false,
      dataProcessingLegalBasis: DEFAULT_DATA_PROCESSING_LEGAL_BASIS,
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
