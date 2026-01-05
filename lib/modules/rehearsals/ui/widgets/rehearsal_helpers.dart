import '../../domain/rehearsal_entity.dart';

RehearsalEntity? nextUpcomingRehearsal(List<RehearsalEntity> rehearsals) {
  final now = DateTime.now();
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
