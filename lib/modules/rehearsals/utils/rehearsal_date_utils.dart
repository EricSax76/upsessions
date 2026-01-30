import '../models/rehearsal_entity.dart';
import '../controllers/rehearsal_filter.dart';

RehearsalEntity? nextUpcomingRehearsal(
  List<RehearsalEntity> rehearsals, {
  required DateTime now,
}) {
  final upcoming =
      rehearsals.where((rehearsal) => rehearsal.startsAt.isAfter(now)).toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  if (upcoming.isEmpty) return null;
  return upcoming.first;
}

String formatDateTime(DateTime value) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${value.day}/${value.month}/${value.year} ${two(value.hour)}:${two(value.minute)}';
}

String monthLabel(int month) {
  const months = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];
  if (month < 1 || month > 12) return '';
  return months[month - 1];
}

String timeLabel(DateTime date) {
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(date.hour)}:${two(date.minute)}';
}

/// Filters rehearsals to show only upcoming ones (future dates).
/// Results are sorted in ascending order (nearest first).
List<RehearsalEntity> filterUpcoming(
  List<RehearsalEntity> items, {
  required DateTime now,
}) {
  if (items.isEmpty) return const [];
  return items.where((r) => r.startsAt.isAfter(now)).toList()
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
}

/// Filters rehearsals to show only past ones.
/// Results are sorted in descending order (most recent first).
List<RehearsalEntity> filterPast(
  List<RehearsalEntity> items, {
  required DateTime now,
}) {
  if (items.isEmpty) return const [];
  return items.where((r) => !r.startsAt.isAfter(now)).toList()
    ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
}

/// Sorts all rehearsals by date in ascending order.
List<RehearsalEntity> sortByDate(List<RehearsalEntity> items) {
  if (items.isEmpty) return const [];
  return [...items]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
}

/// Applies the specified filter to a list of rehearsals.
List<RehearsalEntity> applyRehearsalFilter(
  List<RehearsalEntity> items,
  RehearsalFilter filter, {
  required DateTime now,
}) {
  switch (filter) {
    case RehearsalFilter.upcoming:
      return filterUpcoming(items, now: now);
    case RehearsalFilter.past:
      return filterPast(items, now: now);
    case RehearsalFilter.all:
      return sortByDate(items);
  }
}
