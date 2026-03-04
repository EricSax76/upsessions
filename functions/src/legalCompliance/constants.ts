import type {
  ConsentSource,
  DataProcessingLegalBasis,
  PolicyType,
  UserRole,
} from './types';

export const POLICY_TYPES: readonly PolicyType[] = ['terms', 'privacy', 'marketing'];
export const CONSENT_SOURCES: readonly ConsentSource[] = ['web', 'android', 'ios', 'api'];
export const VERSION_PATTERN = /^[A-Za-z0-9._-]{1,64}$/;
export const LOCALE_PATTERN = /^[a-z]{2}(?:-[A-Z]{2})?$/;
export const PHONE_PATTERN = /^[+0-9()\-.\s]{6,24}$/;
export const POLICY_HASH_PATTERN = /^[a-f0-9]{64}$/;

export const DEFAULT_ROLE: UserRole = 'musician';
export const DEFAULT_DATA_PROCESSING_LEGAL_BASIS: DataProcessingLegalBasis = 'contract';

export const GDPR_RETENTION_DAYS = 30;
export const CONSENT_EVIDENCE_RETENTION_DAYS = 365 * 6;
export const PRIVACY_REQUEST_RETENTION_DAYS = 365 * 6;
export const RETENTION_PURGE_BATCH_SIZE = 200;
export const RETENTION_PURGE_MAX_BATCHES = 15;
