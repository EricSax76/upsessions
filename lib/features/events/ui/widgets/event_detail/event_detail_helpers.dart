import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/event_entity.dart';

class EventDetailMeta {
  const EventDetailMeta({
    required this.dateLabel,
    required this.startTime,
    required this.endTime,
  });

  final String dateLabel;
  final String startTime;
  final String endTime;
}

EventDetailMeta buildEventDetailMeta(
  BuildContext context,
  EventEntity event,
) {
  final loc = MaterialLocalizations.of(context);
  return EventDetailMeta(
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

Future<void> copyToClipboard(
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
