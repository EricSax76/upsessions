import 'package:equatable/equatable.dart';

import '../../../modules/rehearsals/models/rehearsal_entity.dart';

class CalendarState extends Equatable {
  const CalendarState({
    this.loading = true,
    this.rehearsals = const [],
    this.rehearsalsByDay = const {},
    required this.visibleMonth,
    required this.selectedDay,
  });

  final bool loading;
  final List<RehearsalEntity> rehearsals;
  final Map<DateTime, List<RehearsalEntity>> rehearsalsByDay;
  final DateTime visibleMonth;
  final DateTime selectedDay;

  List<RehearsalEntity> get selectedDayRehearsals =>
      rehearsalsByDay[selectedDay] ?? const <RehearsalEntity>[];

  List<RehearsalEntity> get monthRehearsals => rehearsals
      .where(
        (rehearsal) =>
            rehearsal.startsAt.year == visibleMonth.year &&
            rehearsal.startsAt.month == visibleMonth.month,
      )
      .toList(growable: false);

  int get totalUpcomingRehearsals {
    final now = DateTime.now();
    return rehearsals
        .where((rehearsal) => !rehearsal.startsAt.isBefore(now))
        .length;
  }

  CalendarState copyWith({
    bool? loading,
    List<RehearsalEntity>? rehearsals,
    Map<DateTime, List<RehearsalEntity>>? rehearsalsByDay,
    DateTime? visibleMonth,
    DateTime? selectedDay,
  }) {
    return CalendarState(
      loading: loading ?? this.loading,
      rehearsals: rehearsals ?? this.rehearsals,
      rehearsalsByDay: rehearsalsByDay ?? this.rehearsalsByDay,
      visibleMonth: visibleMonth ?? this.visibleMonth,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    rehearsals,
    rehearsalsByDay,
    visibleMonth,
    selectedDay,
  ];
}
