import 'package:equatable/equatable.dart';

class ManagerEventFormState extends Equatable {
  static const Object _unset = Object();

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
    Object? errorMessage = _unset,
    bool? success,
  }) {
    return ManagerEventFormState(
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
