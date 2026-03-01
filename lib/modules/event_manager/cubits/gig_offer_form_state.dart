import 'package:equatable/equatable.dart';

class GigOfferFormState extends Equatable {
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
    String? errorMessage,
    bool? success,
  }) {
    return GigOfferFormState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [isSaving, errorMessage, success];
}
