import 'package:equatable/equatable.dart';

class GigOfferFormState extends Equatable {
  static const Object _unset = Object();

  const GigOfferFormState({
    this.isSaving = false,
    this.errorMessage,
    this.success = false,
  });

  final bool isSaving;
  final String? errorMessage;
  final bool success;

  GigOfferFormState copyWith({
    bool? isSaving,
    Object? errorMessage = _unset,
    bool? success,
  }) {
    return GigOfferFormState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [isSaving, errorMessage, success];
}
