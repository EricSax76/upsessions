import '../../cubits/rehearsal_entity.dart';
import '../models/rehearsal_filter.dart';

/// Filters rehearsals to show only upcoming ones (future dates).
/// Results are sorted in ascending order (nearest first).
List<RehearsalEntity> filterUpcoming(List<RehearsalEntity> items) {
  if (items.isEmpty) return const [];
  final now = DateTime.now();
  return items.where((r) => r.startsAt.isAfter(now)).toList()
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
}

/// Filters rehearsals to show only past ones.
/// Results are sorted in descending order (most recent first).
List<RehearsalEntity> filterPast(List<RehearsalEntity> items) {
  if (items.isEmpty) return const [];
  final now = DateTime.now();
  return items.where((r) => !r.startsAt.isAfter(now)).toList()
    ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
}

/// Sorts all rehearsals by date in ascending order.
List<RehearsalEntity> sortByDate(List<RehearsalEntity> items) {
  if (items.isEmpty) return const [];
  return [...items]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
}

/// Applies the specified filter to a list of rehearsals.
/// 
/// Example:
/// ```dart
/// final filtered = applyRehearsalFilter(
///   allRehearsals,
///   RehearsalFilter.upcoming,
/// );
/// ```
List<RehearsalEntity> applyRehearsalFilter(
  List<RehearsalEntity> items,
  RehearsalFilter filter,
) {
  switch (filter) {
    case RehearsalFilter.upcoming:
      return filterUpcoming(items);
    case RehearsalFilter.past:
      return filterPast(items);
    case RehearsalFilter.all:
      return sortByDate(items);
  }
}
