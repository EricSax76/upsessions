import 'package:equatable/equatable.dart';

import '../models/venue_entity.dart';

class ManagerVenueFormState extends Equatable {
  const ManagerVenueFormState({
    this.isLoading = false,
    this.isSaving = false,
    this.loadingError,
    this.feedbackMessage,
    this.saveSuccess = false,
    this.editingVenue,
    this.isPublic = true,
    this.requestedVenueId,
  });

  static const Object _unset = Object();

  final bool isLoading;
  final bool isSaving;
  final String? loadingError;
  final String? feedbackMessage;
  final bool saveSuccess;
  final VenueEntity? editingVenue;
  final bool isPublic;
  final String? requestedVenueId;

  bool get isEditing => editingVenue != null;

  ManagerVenueFormState copyWith({
    bool? isLoading,
    bool? isSaving,
    Object? loadingError = _unset,
    Object? feedbackMessage = _unset,
    bool? saveSuccess,
    Object? editingVenue = _unset,
    bool? isPublic,
    Object? requestedVenueId = _unset,
  }) {
    return ManagerVenueFormState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      loadingError: identical(loadingError, _unset)
          ? this.loadingError
          : loadingError as String?,
      feedbackMessage: identical(feedbackMessage, _unset)
          ? this.feedbackMessage
          : feedbackMessage as String?,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      editingVenue: identical(editingVenue, _unset)
          ? this.editingVenue
          : editingVenue as VenueEntity?,
      isPublic: isPublic ?? this.isPublic,
      requestedVenueId: identical(requestedVenueId, _unset)
          ? this.requestedVenueId
          : requestedVenueId as String?,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isSaving,
    loadingError,
    feedbackMessage,
    saveSuccess,
    editingVenue,
    isPublic,
    requestedVenueId,
  ];
}
