import 'package:equatable/equatable.dart';

class JamSessionFormState extends Equatable {
  const JamSessionFormState({
    this.isSaving = false,
    this.errorMessage,
    this.success = false,
  });

  final bool isSaving;
  final String? errorMessage;
  final bool success;

  JamSessionFormState copyWith({
    bool? isSaving,
    String? errorMessage,
    bool? success,
  }) {
    return JamSessionFormState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [isSaving, errorMessage, success];
}
