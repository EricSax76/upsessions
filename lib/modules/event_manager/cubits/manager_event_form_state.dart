import 'package:equatable/equatable.dart';

class ManagerEventFormState extends Equatable {
  const ManagerEventFormState({
    this.isSaving = false,
    this.errorMessage,
    this.success = false,
  });

  final bool isSaving;
  final String? errorMessage;
  final bool success;

  ManagerEventFormState copyWith({
    bool? isSaving,
    String? errorMessage,
    bool? success,
  }) {
    return ManagerEventFormState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [isSaving, errorMessage, success];
}
