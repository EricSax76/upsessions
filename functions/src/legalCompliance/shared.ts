import { createHash } from 'node:crypto';

import * as functions from 'firebase-functions';

import { admin } from '../firebase';

import {
  CONSENT_SOURCES,
  LOCALE_PATTERN,
  PHONE_PATTERN,
  POLICY_HASH_PATTERN,
  POLICY_TYPES,
  VERSION_PATTERN,
} from './constants';
import type { ConsentSource, PolicyType } from './types';

export function isPolicyType(value: string): value is PolicyType {
  return (POLICY_TYPES as readonly string[]).includes(value);
}

export function isConsentSource(value: string): value is ConsentSource {
  return (CONSENT_SOURCES as readonly string[]).includes(value);
}

export function record(value: unknown): Record<string, unknown> {
  if (value == null || typeof value !== 'object' || Array.isArray(value)) {
    return {};
  }
  return value as Record<string, unknown>;
}

export function stringOrEmpty(value: unknown): string {
  return typeof value === 'string' ? value : '';
}

export function boolOrDefault(value: unknown, fallback: boolean): boolean {
  return typeof value === 'boolean' ? value : fallback;
}

export function normalizeSource(value: unknown): ConsentSource {
  const source = stringOrEmpty(value).trim().toLowerCase();
  return isConsentSource(source) ? source : 'api';
}

export function assertVersionOrThrow(version: string, fieldName = 'version'): void {
  if (!VERSION_PATTERN.test(version)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `${fieldName} must be 1-64 chars and use [A-Za-z0-9._-].`,
    );
  }
}

export function normalizePolicyHash(value: unknown, fieldName = 'policyHash'): string {
  const hash = stringOrEmpty(value).trim().toLowerCase();
  if (!POLICY_HASH_PATTERN.test(hash)) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `${fieldName} must be a 64-char sha256 hex hash.`,
    );
  }
  return hash;
}

export function sanitizeLocale(value: unknown): string | null {
  const locale = stringOrEmpty(value).trim();
  if (!locale) return null;
  return LOCALE_PATTERN.test(locale) ? locale : null;
}

export function sanitizePhone(value: unknown): string | null {
  const raw = stringOrEmpty(value).trim();
  if (!raw) return null;
  if (!PHONE_PATTERN.test(raw)) return null;
  return raw.replace(/\s+/g, ' ');
}

export function hashOrNull(value: string | null): string | null {
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

export function extractClientIp(context: functions.https.CallableContext): string | null {
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

export function extractUserAgent(context: functions.https.CallableContext): string | null {
  const userAgent = firstHeaderValue(context.rawRequest.headers['user-agent']);
  if (!userAgent) return null;
  const trimmed = userAgent.trim();
  return trimmed ? trimmed : null;
}

export function nowPlusDays(days: number): Date {
  return new Date(Date.now() + days * 24 * 60 * 60 * 1000);
}

export function timestampPlusDays(days: number): admin.firestore.Timestamp {
  return admin.firestore.Timestamp.fromDate(nowPlusDays(days));
}

export function sanitizeReason(value: unknown): string | null {
  const reason = stringOrEmpty(value).trim();
  if (!reason) return null;
  return reason.slice(0, 1000);
}
