import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/auth_exceptions.dart';
import '../data/auth_repository.dart';
import '../data/profile_repository.dart';
import '../domain/profile_entity.dart';
import '../domain/user_entity.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
  })
      : _authRepository = authRepository,
        _profileRepository = profileRepository,
        super(const AuthState()) {
    _authSubscription = _authRepository.authStateChanges.listen(_handleUserChanged);
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: user, profile: null));
      unawaited(refreshProfile(profileId: user.id));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  StreamSubscription<UserEntity?>? _authSubscription;

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: AuthAction.login,
      passwordResetEmailSent: false,
    ));
    try {
      await _authRepository.signIn(email.trim(), password.trim());
      if (state.lastAction == AuthAction.login) {
        emit(state.copyWith(isLoading: false));
      }
    } on AuthException catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.message));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Error inesperado: $error'));
    }
  }

  Future<void> register({required String email, required String password, required String displayName}) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: AuthAction.register,
      passwordResetEmailSent: false,
    ));
    try {
      await _authRepository.register(email: email.trim(), password: password.trim(), displayName: displayName.trim());
      if (state.lastAction == AuthAction.register) {
        emit(state.copyWith(isLoading: false));
      }
    } on AuthException catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.message));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Error inesperado: $error'));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: AuthAction.resetPassword,
      passwordResetEmailSent: false,
    ));
    try {
      await _authRepository.sendPasswordReset(email.trim());
      emit(state.copyWith(isLoading: false, passwordResetEmailSent: true));
    } on AuthException catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.message));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Error inesperado: $error'));
    }
  }

  Future<void> signOut() async {
    print('[AuthCubit] Signing out...');
    emit(state.copyWith(lastAction: AuthAction.signOut));
    await _authRepository.signOut();
  }

  Future<void> refreshProfile({String? profileId}) async {
    final id = profileId ?? state.user?.id;
    if (id == null) {
      emit(state.copyWith(
        lastAction: AuthAction.loadProfile,
        errorMessage: 'Debes iniciar sesión para cargar el perfil.',
      ));
      return;
    }
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: AuthAction.loadProfile,
    ));
    try {
      final dto = await _profileRepository.fetchProfile(profileId: id);
      emit(state.copyWith(
        profile: dto.toEntity(),
        isLoading: false,
        lastAction: AuthAction.none,
      ));
    } on AuthException catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.message, lastAction: AuthAction.loadProfile));
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo cargar el perfil: $error',
        lastAction: AuthAction.loadProfile,
      ));
    }
  }

  Future<void> updateProfile(ProfileEntity profile) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: AuthAction.updateProfile,
    ));
    try {
      final dto = await _profileRepository.updateProfile(profile);
      emit(state.copyWith(
        profile: dto.toEntity(),
        isLoading: false,
        lastAction: AuthAction.none,
      ));
    } on AuthException catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.message, lastAction: AuthAction.updateProfile));
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo actualizar el perfil: $error',
        lastAction: AuthAction.updateProfile,
      ));
    }
  }

  Future<void> updateProfilePhoto(Uint8List bytes, {required String fileExtension}) async {
    final user = state.user;
    if (user == null) {
      emit(state.copyWith(errorMessage: 'Debes iniciar sesión para actualizar tu foto.', lastAction: AuthAction.updateProfilePhoto));
      return;
    }
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: AuthAction.updateProfilePhoto,
    ));
    try {
      final dto = await _profileRepository.uploadProfilePhoto(
        userId: user.id,
        bytes: bytes,
        fileExtension: fileExtension,
      );
      emit(state.copyWith(
        profile: dto.toEntity(),
        isLoading: false,
        lastAction: AuthAction.none,
      ));
    } on AuthException catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.message, lastAction: AuthAction.updateProfilePhoto));
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo actualizar la foto: $error',
        lastAction: AuthAction.updateProfilePhoto,
      ));
    }
  }

  void clearMessages() {
    if (state.errorMessage == null && !state.passwordResetEmailSent) {
      return;
    }
    emit(state.copyWith(errorMessage: null, passwordResetEmailSent: false, lastAction: AuthAction.none));
  }

  void _handleUserChanged(UserEntity? user) {
    print('[AuthCubit] User state changed: ${user != null ? 'Authenticated' : 'Unauthenticated'} (user ID: ${user?.id})');
    emit(state.copyWith(
      status: user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      user: user,
      profile: user == null
          ? null
          : (state.profile != null && state.profile!.id == user.id ? state.profile : null),
      isLoading: false,
      errorMessage: null,
      lastAction: AuthAction.none,
      passwordResetEmailSent: false,
    ));
    if (user != null) {
      unawaited(refreshProfile(profileId: user.id));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
