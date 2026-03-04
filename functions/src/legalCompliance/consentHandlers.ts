import { region } from '../region';

import { acceptLegalBundleAction, acceptLegalDocsAction } from './consentActions';

export const acceptLegalBundle = region.https.onCall((data, context) =>
  acceptLegalBundleAction(data, context),
);

export const acceptLegalDocs = region.https.onCall((data, context) =>
  acceptLegalDocsAction(data, context),
);
