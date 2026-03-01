import 'package:equatable/equatable.dart';
import '../models/event_manager_entity.dart';

enum EventManagerAuthStatus { initial, loading, authenticated, unauthenticated, error }

class EventManagerAuthState extends Equatable {
  const EventManagerAuthState({
    this.status = EventManagerAuthStatus.initial,
    this.manager,
    this.errorMessage,
  });

  final EventManagerAuthStatus status;
  final EventManagerEntity? manager;
  final String? errorMessage;

  EventManagerAuthState copyWith({
    EventManagerAuthStatus? status,
    EventManagerEntity? manager,
    String? errorMessage,
  }) {
    return EventManagerAuthState(
      status: status ?? this.status,
      manager: manager ?? this.manager,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, manager, errorMessage];
}
