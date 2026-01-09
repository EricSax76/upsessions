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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.eventsShowcasesTitle,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          loc.eventsShowcasesDescription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SummaryChip(
              label: loc.eventsActiveLabel,
              value: eventsCount.toString(),
              icon: Icons.event_available,
            ),
            SummaryChip(
              label: loc.eventsThisWeekLabel,
              value: thisWeekCount.toString(),
              icon: Icons.calendar_month,
            ),
            SummaryChip(
              label: loc.eventsTotalCapacityLabel,
              value: loc.eventsPeopleCount(totalCapacity),
              icon: Icons.people_alt_outlined,
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
