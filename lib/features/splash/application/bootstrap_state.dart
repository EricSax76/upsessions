part of 'bootstrap_cubit.dart';

enum BootstrapStatus { initial, loading, authenticated, needsLogin, error }

class BootstrapState extends Equatable {
  const BootstrapState({
    this.status = BootstrapStatus.initial,
    this.user,
    this.errorMessage,
  });

  static const Object _unset = Object();

  final BootstrapStatus status;
  final UserEntity? user;
  final String? errorMessage;

  BootstrapState copyWith({
    BootstrapStatus? status,
    Object? user = _unset,
    Object? errorMessage = _unset,
  }) {
    return BootstrapState(
      status: status ?? this.status,
      user: identical(user, _unset) ? this.user : user as UserEntity?,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
