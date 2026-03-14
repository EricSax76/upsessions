import 'package:equatable/equatable.dart';

import '../models/jam_session_entity.dart';

class PublicJamSessionsState extends Equatable {
  const PublicJamSessionsState({
    this.sessions = const [],
    this.currentUserId = '',
    this.joiningSessionIds = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  final List<JamSessionEntity> sessions;
  final String currentUserId;
  final List<String> joiningSessionIds;
  final bool isLoading;
  final String? errorMessage;

  PublicJamSessionsState copyWith({
    List<JamSessionEntity>? sessions,
    String? currentUserId,
    List<String>? joiningSessionIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PublicJamSessionsState(
      sessions: sessions ?? this.sessions,
      currentUserId: currentUserId ?? this.currentUserId,
      joiningSessionIds: joiningSessionIds ?? this.joiningSessionIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool isJoining(String sessionId) => joiningSessionIds.contains(sessionId);

  @override
  List<Object?> get props => [
    sessions,
    currentUserId,
    joiningSessionIds,
    isLoading,
    errorMessage,
  ];
}
