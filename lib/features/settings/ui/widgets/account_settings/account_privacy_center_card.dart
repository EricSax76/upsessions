import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:upsessions/core/services/cookie_consent_service.dart';
import 'package:upsessions/core/widgets/app_card.dart';
import 'package:upsessions/features/settings/ui/widgets/account_settings/cookie_consent_section.dart';
import 'package:upsessions/features/settings/ui/widgets/account_settings/data_rights_section.dart';
import 'package:upsessions/features/settings/ui/widgets/account_settings/legal_docs_section.dart';

typedef AsyncVoidCallback = Future<void> Function();
typedef AsyncBoolCallback = Future<void> Function(bool value);

class AccountPrivacyCenterCard extends StatelessWidget {
  const AccountPrivacyCenterCard({
    required this.cookiePreferences,
    required this.onAnalyticsCookiesChanged,
    required this.onPreferencesCookiesChanged,
    required this.onMarketingCookiesChanged,
    required this.userComplianceStream,
    required this.isUpdatingMarketingConsent,
    required this.onMarketingConsentChanged,
    required this.isRequestingDataExport,
    required this.onRequestDataExport,
    required this.isRequestingAccountDeletion,
    required this.onRequestAccountDeletion,
    required this.onContactDpo,
    super.key,
  });

  final CookieConsentPreferences cookiePreferences;
  final AsyncBoolCallback onAnalyticsCookiesChanged;
  final AsyncBoolCallback onPreferencesCookiesChanged;
  final AsyncBoolCallback onMarketingCookiesChanged;
  final Stream<DocumentSnapshot<Map<String, dynamic>>>? userComplianceStream;
  final bool isUpdatingMarketingConsent;
  final AsyncBoolCallback onMarketingConsentChanged;
  final bool isRequestingDataExport;
  final AsyncVoidCallback onRequestDataExport;
  final bool isRequestingAccountDeletion;
  final AsyncVoidCallback onRequestAccountDeletion;
  final AsyncVoidCallback onContactDpo;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          const LegalDocsSection(),
          const Divider(height: 1),
          CookieConsentSection(
            cookiePreferences: cookiePreferences,
            onAnalyticsCookiesChanged: onAnalyticsCookiesChanged,
            onPreferencesCookiesChanged: onPreferencesCookiesChanged,
            onMarketingCookiesChanged: onMarketingCookiesChanged,
            userComplianceStream: userComplianceStream,
            isUpdatingMarketingConsent: isUpdatingMarketingConsent,
            onMarketingConsentChanged: onMarketingConsentChanged,
          ),
          const Divider(height: 1),
          DataRightsSection(
            isRequestingDataExport: isRequestingDataExport,
            onRequestDataExport: onRequestDataExport,
            isRequestingAccountDeletion: isRequestingAccountDeletion,
            onRequestAccountDeletion: onRequestAccountDeletion,
            onContactDpo: onContactDpo,
          ),
        ],
      ),
    );
  }
}
