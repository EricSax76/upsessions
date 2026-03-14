export const VENUE_SOURCE_TYPES = ['native', 'studio'] as const;

export const REQUIRED_STRING_FIELDS = [
  'ownerId',
  'name',
  'description',
  'address',
  'city',
  'province',
  'contactEmail',
  'contactPhone',
  'licenseNumber',
  'accessibilityInfo',
] as const;

export const OPTIONAL_STRING_FIELDS = ['postalCode', 'sourceId'] as const;

export const MUTABLE_TIMESTAMP_FIELDS = ['createdAt', 'updatedAt'] as const;
