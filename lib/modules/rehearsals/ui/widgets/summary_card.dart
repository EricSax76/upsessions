import 'package:flutter/material.dart';

import '../../domain/rehearsal_entity.dart';
import 'rehearsal_helpers.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.totalCount,
    required this.nextRehearsal,
  });

  final int totalCount;
  final RehearsalEntity? nextRehearsal;

  @override
  Widget build(BuildContext context) {
    final totalLabel = totalCount == 1
        ? '1 ensayo programado'
        : '$totalCount ensayos programados';
    final nextLabel = nextRehearsal == null
        ? 'Sin proximo ensayo'
        : formatDateTime(nextRehearsal!.startsAt);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event_note_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Proximo: $nextLabel',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
