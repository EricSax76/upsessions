export {
  onAuthUserCreateBootstrap,
  onAuthUserDeleteSoftDelete,
} from './legalCompliance/authTriggers';
export { acceptLegalBundle, acceptLegalDocs } from './legalCompliance/consentHandlers';
export {
  requestAccountDeletion,
  requestDataExport,
  requestPrivacyRight,
} from './legalCompliance/privacyRequestHandlers';
export {
  listPrivacyRequestsBackoffice,
  updatePrivacyRequestStatusBackoffice,
} from './legalCompliance/privacyBackofficeHandlers';
export { purgeExpiredComplianceData } from './legalCompliance/retentionHandlers';
export {
  syncUserSession,
  updateUserComplianceProfile,
} from './legalCompliance/sessionHandlers';
export {
  onEventManagerWriteSyncUserRole,
  onStudioWriteSyncUserRole,
} from './legalCompliance/roleSyncTriggers';
