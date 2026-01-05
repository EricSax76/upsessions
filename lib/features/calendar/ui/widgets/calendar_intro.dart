import 'package:flutter/material.dart';

class CalendarIntro extends StatelessWidget {
  const CalendarIntro({
    super.key,
    required this.totalEvents,
    required this.monthEvents,
  });

  final int totalEvents;
  final int monthEvents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calendario',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Consulta las fechas registradas y mantén a tu equipo sincronizado con los showcases planificados.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SummaryChip(
              label: 'Próximos registrados',
              value: '$totalEvents eventos',
              icon: Icons.event_available,
            ),
            SummaryChip(
              label: 'En este mes',
              value: monthEvents.toString(),
              icon: Icons.calendar_month,
            ),
          ],
        ),
      ],
    );
  }
}

class SummaryChip extends StatelessWidget {
  const SummaryChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label),
            ],
          ),
        ],
      ),
    );
  }
}
