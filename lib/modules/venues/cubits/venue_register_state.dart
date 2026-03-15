import 'package:equatable/equatable.dart';

enum VenueRegisterStatus { initial, submitting, success, failure }

class VenueRegisterState extends Equatable {
  static const Object _unset = Object();

  const VenueRegisterState({
    this.status = VenueRegisterStatus.initial,
    this.errorMessage,
    this.obscurePassword = true,
  });

  final VenueRegisterStatus status;
  final String? errorMessage;
  final bool obscurePassword;

  VenueRegisterState copyWith({
    VenueRegisterStatus? status,
    Object? errorMessage = _unset,
    bool? obscurePassword,
  }) {
    return VenueRegisterState(
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, obscurePassword];
}
