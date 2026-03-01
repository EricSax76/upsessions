import 'package:equatable/equatable.dart';
import '../models/jam_session_entity.dart';

enum JamSessionFilter { all, upcoming, past }

class JamSessionsState extends Equatable {
  const JamSessionsState({
    this.sessions = const [],
    this.isLoading = true,
    this.filter = JamSessionFilter.upcoming,
    this.errorMessage,
  });

  final List<JamSessionEntity> sessions;
  final bool isLoading;
  final JamSessionFilter filter;
  final String? errorMessage;

  JamSessionsState copyWith({
    List<JamSessionEntity>? sessions,
    bool? isLoading,
    JamSessionFilter? filter,
    String? errorMessage,
  }) {
    return JamSessionsState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [sessions, isLoading, filter, errorMessage];
}
