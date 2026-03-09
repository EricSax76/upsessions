import 'package:flutter/material.dart';

import '../../models/event_entity.dart';

String buildEventTextTemplate(BuildContext context, EventEntity event) {
  final loc = MaterialLocalizations.of(context);
  final buffer = StringBuffer()
    ..writeln('EVENTO: ${event.title}')
    ..writeln('FECHA: ${loc.formatFullDate(event.start)}')
    ..writeln(
      'HORARIO: ${loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start), alwaysUse24HourFormat: true)} - '
      '${loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.end), alwaysUse24HourFormat: true)}',
    )
    ..writeln('LUGAR: ${event.venue} (${event.city})')
    ..writeln('ORGANIZA: ${event.organizer}')
    ..writeln('LINEUP: ${event.lineup.join(' / ')}')
    ..writeln('CAPACIDAD: ${event.capacity} personas')
    ..writeln('RECURSOS: ${event.resources.join(', ')}')
    ..writeln('ENTRADAS: ${event.ticketInfo}')
    ..writeln('CONTACTO: ${event.contactEmail} | ${event.contactPhone}')
    ..writeln('DESCRIPCIÓN:\n${event.description}');

  if (event.notes?.isNotEmpty == true) {
    buffer
      ..writeln()
      ..writeln('NOTAS:\n${event.notes}');
  }

  buffer
    ..writeln()
    ..writeln('TAGS: ${event.tags.join(', ')}');
  return buffer.toString();
}
