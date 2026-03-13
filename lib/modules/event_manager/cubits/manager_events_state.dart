import 'package:equatable/equatable.dart';
import '../../../../modules/events/models/event_entity.dart';

enum ManagerEventFilter { all, upcoming, past }

class ManagerEventsState extends Equatable {
  static const Object _unset = Object();

  const ManagerEventsState({
    this.events = const [],
    this.isLoading = true,
    this.filter = ManagerEventFilter.all,
    this.errorMessage,
  });

  final List<EventEntity> events;
  final bool isLoading;
  final ManagerEventFilter filter;
  final String? errorMessage;

  ManagerEventsState copyWith({
    List<EventEntity>? events,
    bool? isLoading,
    ManagerEventFilter? filter,
    Object? errorMessage = _unset,
  }) {
    return ManagerEventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      filter: filter ?? this.filter,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [events, isLoading, filter, errorMessage];
}
