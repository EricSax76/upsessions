import 'package:bloc/bloc.dart';

import '../../auth/repositories/auth_repository.dart';
import '../models/jam_session_entity.dart';
import '../repositories/jam_sessions_repository.dart';
import 'public_jam_sessions_state.dart';

enum JoinJamOutcomeType {
  success,
  requiresLogin,
  alreadyJoined,
  full,
  busy,
  failure,
}

class JoinJamOutcome {
  const JoinJamOutcome({required this.type, this.message});

  final JoinJamOutcomeType type;
  final String? message;
}

class PublicJamSessionsCubit extends Cubit<PublicJamSessionsState> {
  PublicJamSessionsCubit({
    required JamSessionsRepository repository,
    required AuthRepository authRepository,
  }) : _repository = repository,
       _authRepository = authRepository,
       super(const PublicJamSessionsState());

  final JamSessionsRepository _repository;
  final AuthRepository _authRepository;

  void _safeEmit(PublicJamSessionsState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadSessions() async {
    _safeEmit(
      state.copyWith(
        isLoading: true,
        currentUserId: _authRepository.currentUser?.id ?? '',
        clearError: true,
      ),
    );

    try {
      final sessions = await _repository.fetchPublicUpcoming();
      _safeEmit(
        state.copyWith(
          isLoading: false,
          sessions: sessions,
          currentUserId: _authRepository.currentUser?.id ?? '',
          clearError: true,
        ),
      );
    } catch (error) {
      _safeEmit(
        state.copyWith(isLoading: false, errorMessage: error.toString()),
      );
    }
  }

  Future<JoinJamOutcome> joinSession(JamSessionEntity session) async {
    final userId = _authRepository.currentUser?.id ?? '';
    if (userId.isEmpty) {
      return const JoinJamOutcome(type: JoinJamOutcomeType.requiresLogin);
    }

    if (state.isJoining(session.id)) {
      return const JoinJamOutcome(type: JoinJamOutcomeType.busy);
    }

    if (session.attendees.contains(userId)) {
      return const JoinJamOutcome(type: JoinJamOutcomeType.alreadyJoined);
    }

    final hasCapacityLimit = session.maxAttendees != null;
    final isFull =
        hasCapacityLimit && session.attendees.length >= session.maxAttendees!;
    if (isFull) {
      return const JoinJamOutcome(type: JoinJamOutcomeType.full);
    }

    final joining = [...state.joiningSessionIds, session.id];
    _safeEmit(
      state.copyWith(joiningSessionIds: joining, currentUserId: userId),
    );

    try {
      await _repository.joinJam(sessionId: session.id, userId: userId);

      final updatedSessions = state.sessions.map((item) {
        if (item.id != session.id) return item;
        if (item.attendees.contains(userId)) return item;
        return item.copyWith(attendees: [...item.attendees, userId]);
      }).toList();

      _safeEmit(
        state.copyWith(sessions: updatedSessions, currentUserId: userId),
      );
      return const JoinJamOutcome(type: JoinJamOutcomeType.success);
    } catch (error) {
      return JoinJamOutcome(
        type: JoinJamOutcomeType.failure,
        message: error.toString(),
      );
    } finally {
      final remaining = [...state.joiningSessionIds]..remove(session.id);
      _safeEmit(state.copyWith(joiningSessionIds: remaining));
    }
  }
}
