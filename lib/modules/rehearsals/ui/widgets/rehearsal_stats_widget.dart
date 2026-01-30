import 'package:flutter/material.dart';

import '../../../../core/widgets/gap.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../utils/rehearsal_date_utils.dart';
import '../../models/rehearsal_entity.dart';

/// Displays statistics card with total rehearsals and next rehearsal info.
class RehearsalStatsCard extends StatelessWidget {
  const RehearsalStatsCard({
    super.key,
    required this.nextRehearsal,
    required this.totalCount,
  });

  final RehearsalEntity? nextRehearsal;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return SectionCard(
      title: loc.rehearsalsSummaryTitle,
      child: Column(
        children: [
          _StatTile(
            icon: Icons.calendar_today,
            label: loc.rehearsalsTotalStat,
            value: totalCount.toString(),
            color: colorScheme.primary,
          ),
          const Gap(16),
          _StatTile(
            icon: Icons.next_plan,
            label: loc.rehearsalsNextLabel,
            value: nextRehearsal != null
                ? formatDateTime(nextRehearsal!.startsAt)
                : loc.rehearsalsNoUpcoming,
            color: colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
