import 'package:equatable/equatable.dart';
import 'package:upsessions/core/services/cookie_consent_service.dart';

class AccountPrivacyActionsState extends Equatable {
  const AccountPrivacyActionsState({
    this.cookiePreferences = const CookieConsentPreferences(),
    this.isUpdatingMarketingConsent = false,
    this.isRequestingDataExport = false,
    this.isRequestingAccountDeletion = false,
    this.feedbackMessage,
    this.feedbackVersion = 0,
  });

  final CookieConsentPreferences cookiePreferences;
  final bool isUpdatingMarketingConsent;
  final bool isRequestingDataExport;
  final bool isRequestingAccountDeletion;
  final String? feedbackMessage;
  final int feedbackVersion;

  AccountPrivacyActionsState copyWith({
    CookieConsentPreferences? cookiePreferences,
    bool? isUpdatingMarketingConsent,
    bool? isRequestingDataExport,
    bool? isRequestingAccountDeletion,
    String? feedbackMessage,
    int? feedbackVersion,
  }) {
    return AccountPrivacyActionsState(
      cookiePreferences: cookiePreferences ?? this.cookiePreferences,
      isUpdatingMarketingConsent:
          isUpdatingMarketingConsent ?? this.isUpdatingMarketingConsent,
      isRequestingDataExport:
          isRequestingDataExport ?? this.isRequestingDataExport,
      isRequestingAccountDeletion:
          isRequestingAccountDeletion ?? this.isRequestingAccountDeletion,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      feedbackVersion: feedbackVersion ?? this.feedbackVersion,
    );
  }

  @override
  List<Object?> get props => [
    cookiePreferences,
    isUpdatingMarketingConsent,
    isRequestingDataExport,
    isRequestingAccountDeletion,
    feedbackMessage,
    feedbackVersion,
  ];
}
