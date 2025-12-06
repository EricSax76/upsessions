part of 'auth_cubit.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

enum AuthAction { none, login, register, resetPassword, signOut, loadProfile, updateProfile, updateProfilePhoto }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.passwordResetEmailSent = false,
    this.lastAction = AuthAction.none,
  });

  static const Object _unset = Object();

  final AuthStatus status;
  final UserEntity? user;
  final ProfileEntity? profile;
  final bool isLoading;
  final String? errorMessage;
  final bool passwordResetEmailSent;
  final AuthAction lastAction;

  AuthState copyWith({
    AuthStatus? status,
    Object? user = _unset,
    Object? profile = _unset,
    bool? isLoading,
    Object? errorMessage = _unset,
    bool? passwordResetEmailSent,
    AuthAction? lastAction,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: identical(user, _unset) ? this.user : user as UserEntity?,
      profile: identical(profile, _unset) ? this.profile : profile as ProfileEntity?,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
      passwordResetEmailSent: passwordResetEmailSent ?? this.passwordResetEmailSent,
      lastAction: lastAction ?? this.lastAction,
    );
  }

  @override
  List<Object?> get props => [status, user, profile, isLoading, errorMessage, passwordResetEmailSent, lastAction];
}
