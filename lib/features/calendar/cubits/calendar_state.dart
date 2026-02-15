import 'package:equatable/equatable.dart';

import '../../events/models/event_entity.dart';

class CalendarState extends Equatable {
  const CalendarState({
    this.loading = true,
    this.events = const [],
    this.eventsByDay = const {},
    required this.visibleMonth,
    required this.selectedDay,
  });

  final bool loading;
  final List<EventEntity> events;
  final Map<DateTime, List<EventEntity>> eventsByDay;
  final DateTime visibleMonth;
  final DateTime selectedDay;

  List<EventEntity> get selectedDayEvents =>
      eventsByDay[selectedDay] ?? const <EventEntity>[];

  List<EventEntity> get monthEvents => events
      .where(
        (event) =>
            event.start.year == visibleMonth.year &&
            event.start.month == visibleMonth.month,
      )
      .toList(growable: false);

  int get totalEvents =>
      eventsByDay.values.fold<int>(0, (sum, items) => sum + items.length);

  CalendarState copyWith({
    bool? loading,
    List<EventEntity>? events,
    Map<DateTime, List<EventEntity>>? eventsByDay,
    DateTime? visibleMonth,
    DateTime? selectedDay,
  }) {
    return CalendarState(
      loading: loading ?? this.loading,
      events: events ?? this.events,
      eventsByDay: eventsByDay ?? this.eventsByDay,
      visibleMonth: visibleMonth ?? this.visibleMonth,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    events,
    eventsByDay,
    visibleMonth,
    selectedDay,
  ];
}
