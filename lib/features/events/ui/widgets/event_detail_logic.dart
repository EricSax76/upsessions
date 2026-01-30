part of '../pages/event_detail_page.dart';

_EventDetailMeta _buildEventDetailMeta(
  BuildContext context,
  EventEntity event,
) {
  final loc = MaterialLocalizations.of(context);
  return _EventDetailMeta(
    dateLabel: loc.formatFullDate(event.start),
    startTime: loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(event.start),
      alwaysUse24HourFormat: true,
    ),
    endTime: loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(event.end),
      alwaysUse24HourFormat: true,
    ),
  );
}

Future<void> _copyToClipboard(
  BuildContext context,
  String value, {
  required String message,
}) async {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return;
  await Clipboard.setData(ClipboardData(text: trimmed));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
