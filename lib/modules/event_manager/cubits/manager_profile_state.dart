import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class ManagerProfileState extends Equatable {
  static const Object _unset = Object();

  const ManagerProfileState({
    this.pendingPhotoBytes,
    this.pendingPhotoExtension,
    this.isSaving = false,
    this.feedbackMessage,
    this.feedbackIsError = false,
  });

  final Uint8List? pendingPhotoBytes;
  final String? pendingPhotoExtension;
  final bool isSaving;
  final String? feedbackMessage;
  final bool feedbackIsError;

  bool get hasPendingPhoto => pendingPhotoBytes != null;

  ManagerProfileState copyWith({
    Object? pendingPhotoBytes = _unset,
    Object? pendingPhotoExtension = _unset,
    bool? isSaving,
    Object? feedbackMessage = _unset,
    bool? feedbackIsError,
  }) {
    return ManagerProfileState(
      pendingPhotoBytes: identical(pendingPhotoBytes, _unset)
          ? this.pendingPhotoBytes
          : pendingPhotoBytes as Uint8List?,
      pendingPhotoExtension: identical(pendingPhotoExtension, _unset)
          ? this.pendingPhotoExtension
          : pendingPhotoExtension as String?,
      isSaving: isSaving ?? this.isSaving,
      feedbackMessage: identical(feedbackMessage, _unset)
          ? this.feedbackMessage
          : feedbackMessage as String?,
      feedbackIsError: feedbackIsError ?? this.feedbackIsError,
    );
  }

  @override
  List<Object?> get props => [
        pendingPhotoBytes,
        pendingPhotoExtension,
        isSaving,
        feedbackMessage,
        feedbackIsError,
      ];
}
