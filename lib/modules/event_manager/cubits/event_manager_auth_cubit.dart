import 'package:bloc/bloc.dart';
import '../../auth/repositories/auth_repository.dart';
import '../models/event_manager_entity.dart';
import '../repositories/event_manager_repository.dart';
import 'event_manager_auth_state.dart';

class EventManagerAuthCubit extends Cubit<EventManagerAuthState> {
  EventManagerAuthCubit({
    required AuthRepository authRepository,
    required EventManagerRepository managerRepository,
  })  : _authRepository = authRepository,
        _managerRepository = managerRepository,
        super(const EventManagerAuthState());

  final AuthRepository _authRepository;
  final EventManagerRepository _managerRepository;

  void _safeEmit(EventManagerAuthState newState) {
    if (isClosed) return;
    emit(newState);
  }

  Future<void> loadProfile() async {
    _safeEmit(state.copyWith(status: EventManagerAuthStatus.loading, errorMessage: null));
    try {
      final user = _authRepository.currentUser;
      if (user == null) {
        _safeEmit(state.copyWith(status: EventManagerAuthStatus.unauthenticated));
        return;
      }

      final manager = await _managerRepository.fetchByOwnerId(user.id);
      if (manager != null) {
        _safeEmit(state.copyWith(status: EventManagerAuthStatus.authenticated, manager: manager));
      } else {
        _safeEmit(state.copyWith(status: EventManagerAuthStatus.unauthenticated));
      }
    } catch (e) {
      _safeEmit(state.copyWith(
        status: EventManagerAuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> login(String email, String password) async {
    _safeEmit(state.copyWith(status: EventManagerAuthStatus.loading, errorMessage: null));
    try {
      await _authRepository.signIn(email, password);
      await loadProfile();
    } catch (e) {
      _safeEmit(state.copyWith(
        status: EventManagerAuthStatus.error,
        errorMessage: e.toString(),
      ));
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
    _safeEmit(state.copyWith(status: EventManagerAuthStatus.loading, errorMessage: null));
    try {
      // 1. Create Firebase Auth user
      final user = await _authRepository.register(
        email: email,
        password: password,
        displayName: managerName,
      );

      // 2. Create EventManagerEntity
      final manager = EventManagerEntity(
        id: user.id, // Using the same ID as auth, or generating a new one? For simplicity, we can use user.id, but usually it's better to let Firestore generate or use a UUID. Let's use user.id for simplicity if it's 1-to-1, or generate a new one. I will use the user.id as the document ID for the event manager to enforce 1-to-1 or keep it simpler, but wait, ownerId is also user.id. Let's make id = user.id. No, usually doc handles its own ID. Let's use user.id. Wait, dto.id would then be user.id.
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

      _safeEmit(state.copyWith(status: EventManagerAuthStatus.authenticated, manager: manager));
    } catch (e) {
      _safeEmit(state.copyWith(
        status: EventManagerAuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> logout() async {
    _safeEmit(state.copyWith(status: EventManagerAuthStatus.loading));
    try {
      await _authRepository.signOut();
      _safeEmit(const EventManagerAuthState(status: EventManagerAuthStatus.unauthenticated));
    } catch (e) {
      _safeEmit(state.copyWith(
        status: EventManagerAuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
