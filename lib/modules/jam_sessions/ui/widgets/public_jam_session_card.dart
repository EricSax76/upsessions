import 'package:flutter/material.dart';

import '../../models/jam_session_entity.dart';

class PublicJamSessionCard extends StatelessWidget {
  const PublicJamSessionCard({
    super.key,
    required this.session,
    required this.currentUserId,
    required this.isJoining,
    required this.onJoin,
    required this.onOpenDetail,
  });

  final JamSessionEntity session;
  final String currentUserId;
  final bool isJoining;
  final VoidCallback onJoin;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final isJoined =
        currentUserId.isNotEmpty && session.attendees.contains(currentUserId);
    final hasCapacityLimit = session.maxAttendees != null;
    final isFull =
        hasCapacityLimit && session.attendees.length >= session.maxAttendees!;
    final canJoin = !isJoined && !isFull && !isJoining;

    return Card(
      child: InkWell(
        onTap: onOpenDetail,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!session.isPublic)
                    const Chip(
                      avatar: Icon(Icons.lock_outline, size: 16),
                      label: Text('Privada'),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${session.city} • ${session.location}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(session.date, session.time),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              Text(
                _capacityText(session),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: onOpenDetail,
                    child: const Text('Ver detalles'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: canJoin ? onJoin : null,
                    icon: isJoining
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            isJoined
                                ? Icons.check
                                : isFull
                                ? Icons.block
                                : Icons.how_to_reg,
                          ),
                    label: Text(
                      isJoined
                          ? 'Apuntado'
                          : isFull
                          ? 'Completo'
                          : 'Unirme',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capacityText(JamSessionEntity session) {
    if (session.maxAttendees == null) {
      return 'Asistentes: ${session.attendees.length}';
    }
    return 'Asistentes: ${session.attendees.length}/${session.maxAttendees}';
  }

  String _formatDate(DateTime? date, String time) {
    if (date == null) return 'Fecha por definir';
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    final cleanTime = time.trim();
    if (cleanTime.isEmpty) return '$dd/$mm/$yyyy';
    return '$dd/$mm/$yyyy • $cleanTime';
  }
}
