import 'package:flutter/material.dart';
import '../../../../core/widgets/layout/hero_stats_section.dart';
import '../../../../l10n/app_localizations.dart';

class EventsHeroSection extends StatelessWidget {
  const EventsHeroSection({
    super.key,
    required this.eventsCount,
    required this.thisWeekCount,
    required this.onCreateEvent,
  });

  final int eventsCount;
  final int thisWeekCount;
  final VoidCallback onCreateEvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return HeroStatsSection(
      title: 'Eventos',
      description: 'Gestiona y difunde tus eventos.',
      gradientColors: [colorScheme.primaryContainer, colorScheme.surface],
      textColor: colorScheme.onPrimaryContainer,
      stats: [
        HeroStatItem(
          icon: Icons.event_available,
          value: eventsCount.toString(),
          label: loc.eventsActiveLabel,
        ),
        HeroStatItem(
          icon: Icons.calendar_month,
          value: thisWeekCount.toString(),
          label: loc.eventsThisWeekLabel,
        ),
      ],
      action: ElevatedButton.icon(
        onPressed: onCreateEvent,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Nuevo evento'),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }
}
