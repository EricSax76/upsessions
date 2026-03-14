import 'package:equatable/equatable.dart';

class VenueFormState extends Equatable {
  const VenueFormState({
    this.isSaving = false,
    this.success = false,
    this.errorMessage,
  });

  final bool isSaving;
  final bool success;
  final String? errorMessage;

  VenueFormState copyWith({
    bool? isSaving,
    bool? success,
    Object? errorMessage = _noChange,
  }) {
    return VenueFormState(
      isSaving: isSaving ?? this.isSaving,
      success: success ?? this.success,
      errorMessage: errorMessage == _noChange
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [isSaving, success, errorMessage];
}

const Object _noChange = Object();
