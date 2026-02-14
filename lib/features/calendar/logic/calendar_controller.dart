import 'package:flutter/material.dart';

import '../../events/models/event_entity.dart';
import '../../events/repositories/events_repository.dart';

class CalendarController extends ChangeNotifier {
  CalendarController({required EventsRepository repository})
    : _repository = repository {
    final today = DateUtils.dateOnly(DateTime.now());
    _visibleMonth = DateTime(today.year, today.month);
    _selectedDay = today;
    refresh();
  }

  final EventsRepository _repository;

  bool _isDisposed = false;
  bool _loading = true;
  List<EventEntity> _events = const [];
  Map<DateTime, List<EventEntity>> _eventsByDay = const {};
  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  bool get loading => _loading;
  DateTime get visibleMonth => _visibleMonth;
  DateTime get selectedDay => _selectedDay;
  Map<DateTime, List<EventEntity>> get eventsByDay => _eventsByDay;

  List<EventEntity> get selectedDayEvents =>
      _eventsByDay[_selectedDay] ?? const <EventEntity>[];

  List<EventEntity> get monthEvents => _events
      .where(
        (event) =>
            event.start.year == _visibleMonth.year &&
            event.start.month == _visibleMonth.month,
      )
      .toList(growable: false);

  int get totalEvents =>
      _eventsByDay.values.fold<int>(0, (sum, items) => sum + items.length);

  Future<void> refresh() async {
    _setLoading(true);

    final events = await _repository.fetchUpcoming(limit: 60);
    if (_isDisposed) {
      return;
    }

    final grouped = <DateTime, List<EventEntity>>{};
    for (final event in events) {
      final dayKey = DateUtils.dateOnly(event.start);
      grouped.putIfAbsent(dayKey, () => []).add(event);
    }

    _events = events;
    _eventsByDay = grouped;
    _loading = false;
    _ensureSelection();
    _safeNotify();
  }

  void previousMonth() => _changeMonth(-1);

  void nextMonth() => _changeMonth(1);

  void _changeMonth(int offset) {
    final newMonth = DateTime(_visibleMonth.year, _visibleMonth.month + offset);
    _visibleMonth = DateTime(newMonth.year, newMonth.month);
    _selectedDay = DateTime(newMonth.year, newMonth.month, 1);
    _safeNotify();
  }

  void selectDay(DateTime day) {
    final onlyDate = DateUtils.dateOnly(day);
    _selectedDay = onlyDate;
    _visibleMonth = DateTime(onlyDate.year, onlyDate.month);
    _safeNotify();
  }

  void goToToday() {
    final today = DateUtils.dateOnly(DateTime.now());
    _visibleMonth = DateTime(today.year, today.month);
    _selectedDay = today;
    _safeNotify();
  }

  void _ensureSelection() {
    if (_eventsByDay.containsKey(_selectedDay)) {
      return;
    }

    if (_events.isNotEmpty) {
      final firstEventDay = DateUtils.dateOnly(_events.first.start);
      _selectedDay = firstEventDay;
      _visibleMonth = DateTime(firstEventDay.year, firstEventDay.month);
      return;
    }

    final today = DateUtils.dateOnly(DateTime.now());
    _selectedDay = today;
    _visibleMonth = DateTime(today.year, today.month);
  }

  void _setLoading(bool value) {
    if (_isDisposed) {
      return;
    }
    _loading = value;
    _safeNotify();
  }

  void _safeNotify() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
