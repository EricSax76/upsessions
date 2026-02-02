import 'package:flutter/material.dart';
import '../../../../core/widgets/layout/hero_stats_section.dart';

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

    return HeroStatsSection(
      title: 'Calendario',
      description: 'Consulta las fechas y mantén a tu equipo sincronizado.',
      gradientColors: [colorScheme.secondaryContainer, colorScheme.surface],
      textColor: colorScheme.onSecondaryContainer,
      stats: [
        HeroStatItem(
          icon: Icons.event_available,
          value: totalEvents.toString(),
          label: 'Próximos',
        ),
        HeroStatItem(
          icon: Icons.calendar_month,
          value: monthEvents.toString(),
          label: 'Este mes',
        ),
      ],
    );
  }
}
