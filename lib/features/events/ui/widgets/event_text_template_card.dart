import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/event_entity.dart';

class EventTextTemplateCard extends StatelessWidget {
  const EventTextTemplateCard({super.key, required this.event});

  final EventEntity? event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final template = event == null
        ? 'Aún no seleccionaste un evento.\nGenera uno con el formulario o toca un evento existente para ver su ficha.'
        : buildEventTextTemplate(context, event!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Formato tipo archivo de texto',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                template,
                style: const TextStyle(fontFamily: 'monospace', height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: event == null
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: template));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ficha copiada al portapapeles'),
                          ),
                        );
                      },
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Copiar texto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
