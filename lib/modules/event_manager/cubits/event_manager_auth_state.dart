import 'package:equatable/equatable.dart';
import '../models/event_manager_entity.dart';

enum EventManagerAuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class EventManagerAuthState extends Equatable {
  static const Object _unset = Object();

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
    Object? manager = _unset,
    Object? errorMessage = _unset,
  }) {
    return EventManagerAuthState(
      status: status ?? this.status,
      manager: identical(manager, _unset)
          ? this.manager
          : manager as EventManagerEntity?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, manager, errorMessage];
}
