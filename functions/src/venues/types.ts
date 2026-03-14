export type VenueSourceType = 'native' | 'studio';

export interface VenueValidationResult {
  readonly valid: boolean;
  readonly errors: string[];
}
