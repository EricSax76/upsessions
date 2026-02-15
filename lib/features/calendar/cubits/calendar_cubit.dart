import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../events/models/event_entity.dart';
import '../../events/repositories/events_repository.dart';
import 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit({
    required EventsRepository repository,
    bool autoRefresh = true,
  })
      : _repository = repository,
        super(CalendarState(
          visibleMonth: DateTime(DateTime.now().year, DateTime.now().month),
          selectedDay: DateUtils.dateOnly(DateTime.now()),
        )) {
    if (autoRefresh) {
      refresh();
    }
  }

  final EventsRepository _repository;

  Future<void> refresh() async {
    emit(state.copyWith(loading: true));

    try {
      final events = await _repository.fetchUpcoming(limit: 60);
      if (isClosed) return;

      final grouped = <DateTime, List<EventEntity>>{};
      for (final event in events) {
        final dayKey = DateUtils.dateOnly(event.start);
        grouped.putIfAbsent(dayKey, () => []).add(event);
      }

      var selectedDay = state.selectedDay;
      var visibleMonth = state.visibleMonth;

      if (!grouped.containsKey(selectedDay) && events.isNotEmpty) {
        final firstEventDay = DateUtils.dateOnly(events.first.start);
        selectedDay = firstEventDay;
        visibleMonth = DateTime(firstEventDay.year, firstEventDay.month);
      }

      emit(state.copyWith(
        loading: false,
        events: events,
        eventsByDay: grouped,
        selectedDay: selectedDay,
        visibleMonth: visibleMonth,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(loading: false));
      rethrow;
    }
  }

  void previousMonth() => _changeMonth(-1);
  void nextMonth() => _changeMonth(1);

  void _changeMonth(int offset) {
    final newMonth = DateTime(
        state.visibleMonth.year, state.visibleMonth.month + offset);
    final normalized = DateTime(newMonth.year, newMonth.month);
    emit(state.copyWith(
      visibleMonth: normalized,
      selectedDay: DateTime(normalized.year, normalized.month, 1),
    ));
  }

  void selectDay(DateTime day) {
    final onlyDate = DateUtils.dateOnly(day);
    emit(state.copyWith(
      selectedDay: onlyDate,
      visibleMonth: DateTime(onlyDate.year, onlyDate.month),
    ));
  }

  void goToToday() {
    final today = DateUtils.dateOnly(DateTime.now());
    emit(state.copyWith(
      visibleMonth: DateTime(today.year, today.month),
      selectedDay: today,
    ));
  }
}
