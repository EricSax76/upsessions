import 'package:flutter/material.dart';
import '../../../../core/widgets/layout/hero_stats_section.dart';

class CalendarHeroSection extends StatelessWidget {
  const CalendarHeroSection({
    super.key,
    required this.totalRehearsals,
    required this.monthRehearsals,
  });

  final int totalRehearsals;
  final int monthRehearsals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return HeroStatsSection(
      title: 'Calendario',
      description: 'Consulta tus ensayos y mantén a tu equipo sincronizado.',
      gradientColors: [colorScheme.secondaryContainer, colorScheme.surface],
      textColor: colorScheme.onSecondaryContainer,
      stats: [
        HeroStatItem(
          icon: Icons.music_note_outlined,
          value: totalRehearsals.toString(),
          label: 'Ensayos próximos',
        ),
        HeroStatItem(
          icon: Icons.calendar_month,
          value: monthRehearsals.toString(),
          label: 'Este mes',
        ),
      ],
    );
  }
}
