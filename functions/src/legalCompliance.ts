export {
  onAuthUserCreateBootstrap,
  onAuthUserDeleteSoftDelete,
} from './legalCompliance/authTriggers';
export { acceptLegalBundle, acceptLegalDocs } from './legalCompliance/consentHandlers';
export {
  requestAccountDeletion,
  requestDataExport,
} from './legalCompliance/privacyRequestHandlers';
export { purgeExpiredComplianceData } from './legalCompliance/retentionHandlers';
export {
  syncUserSession,
  updateUserComplianceProfile,
} from './legalCompliance/sessionHandlers';
