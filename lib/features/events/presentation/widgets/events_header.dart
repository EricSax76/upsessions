import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class EventsHeader extends StatelessWidget {
  const EventsHeader({
    super.key,
    required this.eventsCount,
    required this.thisWeekCount,
    required this.totalCapacity,
  });

  final int eventsCount;
  final int thisWeekCount;
  final int totalCapacity;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.eventsShowcasesTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          loc.eventsShowcasesDescription,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final isWide = maxWidth >= 720;

            final active = SummaryChip(
              label: loc.eventsActiveLabel,
              value: eventsCount.toString(),
              icon: Icons.event_available,
            );
            final thisWeek = SummaryChip(
              label: loc.eventsThisWeekLabel,
              value: thisWeekCount.toString(),
              icon: Icons.calendar_month,
            );
            final capacity = SummaryChip(
              label: loc.eventsTotalCapacityLabel,
              value: loc.eventsPeopleCount(totalCapacity),
              icon: Icons.people_alt_outlined,
            );

            if (isWide) {
              return Row(
                children: [
                  Expanded(child: active),
                  const SizedBox(width: 12),
                  Expanded(child: thisWeek),
                  const SizedBox(width: 12),
                  Expanded(child: capacity),
                ],
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: active),
                    const SizedBox(width: 12),
                    Expanded(child: thisWeek),
                  ],
                ),
                const SizedBox(height: 12),
                capacity,
              ],
            );
          },
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
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
