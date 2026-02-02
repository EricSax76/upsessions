import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/date_badge.dart';
import '../../models/rehearsal_entity.dart';
import '../../utils/rehearsal_date_utils.dart';

class RehearsalCard extends StatelessWidget {
  const RehearsalCard({
    super.key,
    required this.rehearsal,
    required this.onTap,
  });

  final RehearsalEntity rehearsal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final month = monthLabel(rehearsal.startsAt.month);
    final time = timeLabel(rehearsal.startsAt);
    final location = rehearsal.location.trim();

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          DateBadge(
            month: month,
            day: rehearsal.startsAt.day.toString(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: theme.textTheme.titleMedium),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
