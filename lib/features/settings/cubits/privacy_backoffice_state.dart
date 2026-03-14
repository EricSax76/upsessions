import 'package:equatable/equatable.dart';
import 'package:upsessions/features/settings/models/privacy_backoffice_request.dart';

class PrivacyBackofficeState extends Equatable {
  const PrivacyBackofficeState({
    this.isLoading = false,
    this.requests = const <PrivacyBackofficeRequest>[],
    this.selectedStatus,
    this.activeRequestKey,
    this.errorMessage,
    this.feedbackMessage,
    this.feedbackVersion = 0,
  });

  final bool isLoading;
  final List<PrivacyBackofficeRequest> requests;
  final PrivacyRequestStatus? selectedStatus;
  final String? activeRequestKey;
  final String? errorMessage;
  final String? feedbackMessage;
  final int feedbackVersion;

  bool get isUpdatingStatus => activeRequestKey != null;

  PrivacyBackofficeState copyWith({
    bool? isLoading,
    List<PrivacyBackofficeRequest>? requests,
    Object? selectedStatus = _noChange,
    Object? activeRequestKey = _noChange,
    Object? errorMessage = _noChange,
    Object? feedbackMessage = _noChange,
    int? feedbackVersion,
  }) {
    return PrivacyBackofficeState(
      isLoading: isLoading ?? this.isLoading,
      requests: requests ?? this.requests,
      selectedStatus: identical(selectedStatus, _noChange)
          ? this.selectedStatus
          : selectedStatus as PrivacyRequestStatus?,
      activeRequestKey: identical(activeRequestKey, _noChange)
          ? this.activeRequestKey
          : activeRequestKey as String?,
      errorMessage: identical(errorMessage, _noChange)
          ? this.errorMessage
          : errorMessage as String?,
      feedbackMessage: identical(feedbackMessage, _noChange)
          ? this.feedbackMessage
          : feedbackMessage as String?,
      feedbackVersion: feedbackVersion ?? this.feedbackVersion,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    requests,
    selectedStatus,
    activeRequestKey,
    errorMessage,
    feedbackMessage,
    feedbackVersion,
  ];
}

const Object _noChange = Object();
