import 'package:flutter/material.dart';

import '../../../../modules/rehearsals/models/rehearsal_entity.dart';

class RehearsalTile extends StatelessWidget {
  const RehearsalTile({
    super.key,
    required this.rehearsal,
    required this.onViewRehearsal,
  });

  final RehearsalEntity rehearsal;
  final ValueChanged<RehearsalEntity> onViewRehearsal;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final startTime = loc.formatTimeOfDay(
      TimeOfDay.fromDateTime(rehearsal.startsAt),
    );
    final endTime = rehearsal.endsAt == null
        ? null
        : loc.formatTimeOfDay(TimeOfDay.fromDateTime(rehearsal.endsAt!));
    final notes = rehearsal.notes.trim();
    final location = rehearsal.location.trim();
    final title = notes.isEmpty ? 'Ensayo' : notes;
    final locationLabel = location.isEmpty ? 'Ubicación por definir' : location;
    final timeRange = endTime == null ? startTime : '$startTime - $endTime';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      tileColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '${loc.formatMediumDate(rehearsal.startsAt)} · $timeRange · $locationLabel',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_outward, size: 20),
        tooltip: 'Ver detalle del ensayo',
        onPressed: () => onViewRehearsal(rehearsal),
      ),
      onTap: () => onViewRehearsal(rehearsal),
    );
  }
}
