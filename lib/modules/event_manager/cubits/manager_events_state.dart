import 'package:equatable/equatable.dart';
import '../../../../modules/events/models/event_entity.dart';

enum ManagerEventFilter { all, upcoming, past }

class ManagerEventsState extends Equatable {
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
    String? errorMessage,
  }) {
    return ManagerEventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [events, isLoading, filter, errorMessage];
}
