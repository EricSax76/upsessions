import 'package:equatable/equatable.dart';
import 'package:upsessions/core/services/cookie_consent_service.dart';

class AccountPrivacyActionsState extends Equatable {
  const AccountPrivacyActionsState({
    this.cookiePreferences = const CookieConsentPreferences(),
    this.isUpdatingMarketingConsent = false,
    this.isRequestingDataExport = false,
    this.isRequestingAccountDeletion = false,
    this.requestingPrivacyRightType,
    this.feedbackMessage,
    this.feedbackVersion = 0,
  });

  final CookieConsentPreferences cookiePreferences;
  final bool isUpdatingMarketingConsent;
  final bool isRequestingDataExport;
  final bool isRequestingAccountDeletion;
  final String? requestingPrivacyRightType;
  final String? feedbackMessage;
  final int feedbackVersion;

  AccountPrivacyActionsState copyWith({
    CookieConsentPreferences? cookiePreferences,
    bool? isUpdatingMarketingConsent,
    bool? isRequestingDataExport,
    bool? isRequestingAccountDeletion,
    Object? requestingPrivacyRightType = _noChange,
    Object? feedbackMessage = _noChange,
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
      requestingPrivacyRightType: requestingPrivacyRightType == _noChange
          ? this.requestingPrivacyRightType
          : requestingPrivacyRightType as String?,
      feedbackMessage: feedbackMessage == _noChange
          ? this.feedbackMessage
          : feedbackMessage as String?,
      feedbackVersion: feedbackVersion ?? this.feedbackVersion,
    );
  }

  @override
  List<Object?> get props => [
    cookiePreferences,
    isUpdatingMarketingConsent,
    isRequestingDataExport,
    isRequestingAccountDeletion,
    requestingPrivacyRightType,
    feedbackMessage,
    feedbackVersion,
  ];
}

const Object _noChange = Object();
