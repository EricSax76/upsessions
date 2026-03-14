import {
  MUTABLE_TIMESTAMP_FIELDS,
  OPTIONAL_STRING_FIELDS,
  REQUIRED_STRING_FIELDS,
  VENUE_SOURCE_TYPES,
} from './constants';
import { admin } from '../firebase';
import { VenueValidationResult } from './types';

function isNonEmptyString(value: unknown): value is string {
  return typeof value === 'string' && value.trim().length > 0;
}

export function validateVenueData(
  data: Record<string, unknown>,
): VenueValidationResult {
  const errors: string[] = [];

  for (const field of REQUIRED_STRING_FIELDS) {
    if (!isNonEmptyString(data[field])) {
      errors.push(`${field} must be a non-empty string`);
    }
  }

  for (const field of OPTIONAL_STRING_FIELDS) {
    const value = data[field];
    if (value != null && typeof value !== 'string') {
      errors.push(`${field} must be a string when provided`);
    }
  }

  const maxCapacity = data.maxCapacity;
  if (
    typeof maxCapacity !== 'number'
    || !Number.isInteger(maxCapacity)
    || maxCapacity <= 0
  ) {
    errors.push('maxCapacity must be an integer > 0');
  }

  if (typeof data.isPublic !== 'boolean') {
    errors.push('isPublic must be a boolean');
  }

  if (typeof data.isActive !== 'boolean') {
    errors.push('isActive must be a boolean');
  }

  const sourceType = data.sourceType;
  if (
    typeof sourceType !== 'string'
    || !VENUE_SOURCE_TYPES.includes(sourceType as (typeof VENUE_SOURCE_TYPES)[number])
  ) {
    errors.push('sourceType must be one of: native, studio');
  }

  for (const field of MUTABLE_TIMESTAMP_FIELDS) {
    const value = data[field];
    if (value != null && !(value instanceof admin.firestore.Timestamp)) {
      errors.push(`${field} must be a Firestore timestamp`);
    }
  }

  return {
    valid: errors.length === 0,
    errors,
  };
}
