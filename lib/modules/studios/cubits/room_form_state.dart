import 'package:equatable/equatable.dart';

class RoomFormState extends Equatable {
  static const Object _unset = Object();

  const RoomFormState({this.isSubmitting = false, this.errorMessage});

  final bool isSubmitting;
  final String? errorMessage;

  RoomFormState copyWith({bool? isSubmitting, Object? errorMessage = _unset}) {
    return RoomFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, errorMessage];
}
