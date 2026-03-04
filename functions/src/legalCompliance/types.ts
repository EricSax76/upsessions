export type PolicyType = 'terms' | 'privacy' | 'marketing';
export type ConsentAction = 'accept' | 'revoke';
export type ConsentSource = 'web' | 'android' | 'ios' | 'api';
export type UserRole = 'musician' | 'event_manager' | 'studio' | 'admin' | 'multi';
export type DataProcessingLegalBasis = 'contract' | 'consent';
export type PrivacyRequestType = 'data_export' | 'account_deletion';
export type PrivacyRequestStatus = 'pending' | 'in_progress' | 'completed' | 'rejected';
