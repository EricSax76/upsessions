import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../modules/rehearsals/models/rehearsal_entity.dart';
import '../../../modules/rehearsals/repositories/rehearsals_repository.dart';
import 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit({
    required RehearsalsRepository repository,
    bool autoRefresh = true,
  }) : _repository = repository,
       super(
         CalendarState(
           visibleMonth: DateTime(DateTime.now().year, DateTime.now().month),
           selectedDay: DateUtils.dateOnly(DateTime.now()),
         ),
       ) {
    if (autoRefresh) {
      refresh();
    }
  }

  final RehearsalsRepository _repository;

  Future<void> refresh() async {
    emit(state.copyWith(loading: true));

    try {
      final rehearsals = await _repository.getMyRehearsals();
      rehearsals.sort((a, b) => a.startsAt.compareTo(b.startsAt));
      if (isClosed) return;

      final grouped = <DateTime, List<RehearsalEntity>>{};
      for (final rehearsal in rehearsals) {
        final dayKey = DateUtils.dateOnly(rehearsal.startsAt);
        grouped.putIfAbsent(dayKey, () => []).add(rehearsal);
      }

      emit(
        state.copyWith(
          loading: false,
          rehearsals: rehearsals,
          rehearsalsByDay: grouped,
        ),
      );
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
      state.visibleMonth.year,
      state.visibleMonth.month + offset,
    );
    final normalized = DateTime(newMonth.year, newMonth.month);
    emit(
      state.copyWith(
        visibleMonth: normalized,
        selectedDay: DateTime(normalized.year, normalized.month, 1),
      ),
    );
  }

  void selectDay(DateTime day) {
    final onlyDate = DateUtils.dateOnly(day);
    emit(
      state.copyWith(
        selectedDay: onlyDate,
        visibleMonth: DateTime(onlyDate.year, onlyDate.month),
      ),
    );
  }

  void goToToday() {
    final today = DateUtils.dateOnly(DateTime.now());
    emit(
      state.copyWith(
        visibleMonth: DateTime(today.year, today.month),
        selectedDay: today,
      ),
    );
  }
}
