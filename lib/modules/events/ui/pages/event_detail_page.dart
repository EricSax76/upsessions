import 'package:flutter/material.dart';

import '../../models/event_entity.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = MaterialLocalizations.of(context);
    final dateLabel = loc.formatFullDate(event.start);
    final startTime = loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start));
    final endTime = loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.end));

    Widget buildSectionTitle(String label) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    Widget buildChips(Iterable<String> values) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: values
            .map(
              (value) => Chip(
                label: Text(value),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            )
            .toList(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$dateLabel · $startTime - $endTime',
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${event.venue} · ${event.city}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            buildSectionTitle('Descripción'),
            Text(event.description, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            buildSectionTitle('Organizador'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.person_outline),
              title: Text(event.organizer),
              subtitle: Text('Capacidad: ${event.capacity} personas'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _ContactLabel(
                  icon: Icons.email,
                  label: event.contactEmail,
                  color: theme.colorScheme.primary,
                ),
                _ContactLabel(
                  icon: Icons.phone,
                  label: event.contactPhone,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildSectionTitle('Lineup'),
            if (event.lineup.isEmpty)
              const Text('Aún no hay artistas confirmados.')
            else
              buildChips(event.lineup),
            const SizedBox(height: 16),
            buildSectionTitle('Etiquetas'),
            if (event.tags.isEmpty)
              const Text('Sin etiquetas asociadas.')
            else
              buildChips(event.tags),
            const SizedBox(height: 16),
            buildSectionTitle('Recursos necesarios'),
            if (event.resources.isEmpty)
              const Text('Sin recursos registrados.')
            else
              buildChips(event.resources),
            if (event.notes != null && event.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              buildSectionTitle('Notas'),
              Text(event.notes!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir ficha'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.copy_all),
                  label: const Text('Copiar formato'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactLabel extends StatelessWidget {
  const _ContactLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 6),
        SelectableText(label),
      ],
    );
  }
}
