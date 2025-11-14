import 'package:flutter/material.dart';

class GlobalStatsRow extends StatelessWidget {
  const GlobalStatsRow({super.key, required this.musicians, required this.announcements});

  final int musicians;
  final int announcements;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStat(context, 'Músicos activos', musicians.toString()),
        const SizedBox(width: 16),
        _buildStat(context, 'Anuncios publicados', announcements.toString()),
        const SizedBox(width: 16),
        _buildStat(context, 'Eventos esta semana', '12'),
      ],
    );
  }

  Expanded _buildStat(BuildContext context, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
