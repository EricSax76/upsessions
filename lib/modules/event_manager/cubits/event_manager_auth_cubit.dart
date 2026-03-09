import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import '../../auth/repositories/auth_repository.dart';
import '../../auth/models/user_entity.dart';
import '../models/event_manager_entity.dart';
import '../repositories/event_manager_repository.dart';
import 'event_manager_auth_state.dart';

class EventManagerAuthCubit extends Cubit<EventManagerAuthState> {
  EventManagerAuthCubit({
    required AuthRepository authRepository,
    required EventManagerRepository managerRepository,
  }) : _authRepository = authRepository,
       _managerRepository = managerRepository,
       super(const EventManagerAuthState());

  final AuthRepository _authRepository;
  final EventManagerRepository _managerRepository;
  static const int _loadProfileAttempts = 5;
  static const Duration _loadProfileRetryDelay = Duration(milliseconds: 120);

  void _safeEmit(EventManagerAuthState newState) {
    if (isClosed) return;
    emit(newState);
  }

  Future<void> loadProfile() async {
    _safeEmit(
      state.copyWith(
        status: EventManagerAuthStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      final user = await _resolveCurrentUser();
      if (user == null) {
        _safeEmit(
          state.copyWith(
            status: EventManagerAuthStatus.unauthenticated,
            manager: null,
            errorMessage: null,
          ),
        );
        return;
      }

      final manager = await _resolveManager(user.id);
      if (manager != null) {
        _safeEmit(
          state.copyWith(
            status: EventManagerAuthStatus.authenticated,
            manager: manager,
            errorMessage: null,
          ),
        );
      } else {
        _safeEmit(
          state.copyWith(
            status: EventManagerAuthStatus.unauthenticated,
            manager: null,
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      _safeEmit(
        state.copyWith(
          status: EventManagerAuthStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> login(String email, String password) async {
    _safeEmit(
      state.copyWith(
        status: EventManagerAuthStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      await _authRepository.signIn(email, password);
      await loadProfile();
    } catch (e) {
      _safeEmit(
        state.copyWith(
          status: EventManagerAuthStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String managerName,
    required String contactEmail,
    required String contactPhone,
    required String city,
    required List<String> specialties,
    String? province,
    String? description,
    String? website,
  }) async {
    _safeEmit(
      state.copyWith(
        status: EventManagerAuthStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      // 1. Create Firebase Auth user
      final user = await _authRepository.register(
        email: email,
        password: password,
        displayName: managerName,
      );

      // 2. Create EventManagerEntity
      final manager = EventManagerEntity(
        id: user.id,
        ownerId: user.id,
        name: managerName,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        city: city,
        specialties: specialties,
        province: province,
        description: description,
        website: website,
      );

      // 3. Save to Firestore
      await _managerRepository.create(manager);

      _safeEmit(
        state.copyWith(
          status: EventManagerAuthStatus.authenticated,
          manager: manager,
          errorMessage: null,
        ),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(
          status: EventManagerAuthStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> logout() async {
    _safeEmit(state.copyWith(status: EventManagerAuthStatus.loading));
    try {
      await _authRepository.signOut();
      _safeEmit(
        const EventManagerAuthState(
          status: EventManagerAuthStatus.unauthenticated,
        ),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(
          status: EventManagerAuthStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> updateProfile({
    required String managerName,
    Uint8List? photoBytes,
    String photoExtension = 'jpg',
  }) async {
    final currentManager = state.manager;
    if (currentManager == null) {
      _safeEmit(
        state.copyWith(
          status: EventManagerAuthStatus.error,
          errorMessage: 'No se encontró el perfil del manager.',
        ),
      );
      return;
    }

    final trimmedName = managerName.trim();
    if (trimmedName.isEmpty) {
      _safeEmit(
        state.copyWith(
          status: EventManagerAuthStatus.error,
          errorMessage: 'El nombre es obligatorio.',
        ),
      );
      return;
    }

    _safeEmit(
      state.copyWith(
        status: EventManagerAuthStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      var updatedManager = currentManager.copyWith(name: trimmedName);

      if (photoBytes != null && photoBytes.isNotEmpty) {
        final logoUrl = await _managerRepository.uploadLogoBytes(
          currentManager.id,
          photoBytes,
          fileExtension: photoExtension,
        );
        updatedManager = updatedManager.copyWith(logoUrl: logoUrl);
      }

      await _managerRepository.update(updatedManager);

      _safeEmit(
        state.copyWith(
          status: EventManagerAuthStatus.authenticated,
          manager: updatedManager,
          errorMessage: null,
        ),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(
          status: EventManagerAuthStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<UserEntity?> _resolveCurrentUser() async {
    for (var attempt = 0; attempt < _loadProfileAttempts; attempt++) {
      final user = _authRepository.currentUser;
      if (user != null) {
        return user;
      }
      if (attempt < _loadProfileAttempts - 1) {
        await Future<void>.delayed(_loadProfileRetryDelay);
      }
    }
    return null;
  }

  Future<EventManagerEntity?> _resolveManager(String userId) async {
    for (var attempt = 0; attempt < _loadProfileAttempts; attempt++) {
      final manager = await _fetchManager(userId);
      if (manager != null) {
        return manager;
      }
      if (attempt < _loadProfileAttempts - 1) {
        await Future<void>.delayed(_loadProfileRetryDelay);
      }
    }
    return null;
  }

  Future<EventManagerEntity?> _fetchManager(String userId) async {
    final byId = await _managerRepository.fetchById(userId);
    if (byId != null) {
      return byId;
    }
    return _managerRepository.fetchByOwnerId(userId);
  }
}
