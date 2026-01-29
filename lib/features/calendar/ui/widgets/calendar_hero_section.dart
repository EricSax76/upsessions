import 'package:flutter/material.dart';

class CalendarHeroSection extends StatelessWidget {
  const CalendarHeroSection({
    super.key,
    required this.totalEvents,
    required this.monthEvents,
  });

  final int totalEvents;
  final int monthEvents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.secondaryContainer, colorScheme.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Calendario',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Consulta las fechas y mantén a tu equipo sincronizado.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatItem(
                icon: Icons.event_available,
                value: totalEvents.toString(),
                label: 'Próximos',
                colorScheme: colorScheme,
              ),
               Container(
                height: 20,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: colorScheme.onSecondaryContainer.withValues(alpha: 0.2),
              ),
              _StatItem(
                icon: Icons.calendar_month,
                value: monthEvents.toString(),
                label: 'Este mes',
                colorScheme: colorScheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.colorScheme,
  });

  final IconData icon;
  final String value;
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
