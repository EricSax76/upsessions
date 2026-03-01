import 'package:bloc/bloc.dart';
import '../../auth/repositories/auth_repository.dart';
import '../repositories/jam_sessions_repository.dart';
import 'jam_sessions_state.dart';

class JamSessionsCubit extends Cubit<JamSessionsState> {
  JamSessionsCubit({
    required JamSessionsRepository repository,
    required AuthRepository authRepository,
  })  : _repository = repository,
        _authRepository = authRepository,
        super(const JamSessionsState());

  final JamSessionsRepository _repository;
  final AuthRepository _authRepository;

  void _safeEmit(JamSessionsState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadSessions() async {
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final managerId = _authRepository.currentUser?.id ?? '';
      if (managerId.isEmpty) throw Exception('No autenticado');
      
      final sessions = await _repository.fetchMySessions(managerId);
      _safeEmit(state.copyWith(isLoading: false, sessions: sessions));
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void setFilter(JamSessionFilter filter) {
    _safeEmit(state.copyWith(filter: filter));
  }

  Future<void> deleteSession(String sessionId) async {
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.delete(sessionId);
      final updatedList = state.sessions.where((e) => e.id != sessionId).toList();
      _safeEmit(state.copyWith(isLoading: false, sessions: updatedList));
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
