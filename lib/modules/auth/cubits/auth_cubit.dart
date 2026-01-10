import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/auth_exceptions.dart';
import '../data/auth_repository.dart';
import '../domain/user_entity.dart';
import '../../../core/services/push_notifications_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    PushNotificationsService? pushNotificationsService,
  })  : _authRepository = authRepository,
        _pushNotificationsService = pushNotificationsService,
        super(const AuthState()) {
    _authSubscription = _authRepository.authStateChanges.listen(
      _handleUserChanged,
    );
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        ),
      );
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  final AuthRepository _authRepository;
  final PushNotificationsService? _pushNotificationsService;
  StreamSubscription<UserEntity?>? _authSubscription;

  Future<void> signIn(String email, String password) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        lastAction: AuthAction.login,
        passwordResetEmailSent: false,
      ),
    );
    try {
      await _authRepository.signIn(email.trim(), password.trim());
      if (state.lastAction == AuthAction.login) {
        emit(state.copyWith(isLoading: false));
      }
    } on AuthException catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.message));
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error inesperado: $error',
        ),
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        lastAction: AuthAction.register,
        passwordResetEmailSent: false,
      ),
    );
    try {
      await _authRepository.register(
        email: email.trim(),
        password: password.trim(),
        displayName: displayName.trim(),
      );
      if (state.lastAction == AuthAction.register) {
        emit(state.copyWith(isLoading: false));
      }
    } on AuthException catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.message));
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error inesperado: $error',
        ),
      );
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        lastAction: AuthAction.resetPassword,
        passwordResetEmailSent: false,
      ),
    );
    try {
      await _authRepository.sendPasswordReset(email.trim());
      emit(state.copyWith(isLoading: false, passwordResetEmailSent: true));
    } on AuthException catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.message));
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error inesperado: $error',
        ),
      );
    }
  }

  Future<void> signOut() async {
    log('[AuthCubit] Signing out...');
    final userId = state.user?.id;
    if (userId != null && _pushNotificationsService != null) {
      unawaited(_pushNotificationsService.unregisterUser(userId));
    }
    emit(state.copyWith(lastAction: AuthAction.signOut));
    await _authRepository.signOut();
  }

  void clearPasswordResetState() {
    if (state.lastAction != AuthAction.resetPassword) return;
    emit(
      state.copyWith(
        errorMessage: null,
        passwordResetEmailSent: false,
        lastAction: AuthAction.none,
      ),
    );
  }

  void clearMessages() {
    if (state.errorMessage == null && !state.passwordResetEmailSent) {
      return;
    }
    emit(
      state.copyWith(
        errorMessage: null,
        passwordResetEmailSent: false,
        lastAction: AuthAction.none,
      ),
    );
  }

  void _handleUserChanged(UserEntity? user) {
    log(
      '[AuthCubit] User state changed: ${user != null ? 'Authenticated' : 'Unauthenticated'} (user ID: ${user?.id})',
    );
    emit(
      state.copyWith(
        status: user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: user,
        isLoading: false,
        errorMessage: null,
        lastAction: AuthAction.none,
        passwordResetEmailSent: false,
      ),
    );
    if (user != null) {
      if (_pushNotificationsService != null) {
        unawaited(_pushNotificationsService.registerForUser(user.id));
      }
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
