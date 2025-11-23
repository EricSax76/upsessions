import 'package:flutter/material.dart';

class GlobalStatsRow extends StatelessWidget {
  const GlobalStatsRow({
    super.key,
    required this.musicians,
    required this.announcements,
  });

  final int musicians;
  final int announcements;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final stats = [
          _StatCard(label: 'Músicos activos', value: musicians.toString()),
          _StatCard(
            label: 'Anuncios publicados',
            value: announcements.toString(),
          ),
          const _StatCard(label: 'Eventos esta semana', value: '12'),
        ];

        if (isCompact) {
          return Column(
            children: [
              for (final card in stats) ...[card, const SizedBox(height: 12)],
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < stats.length; i++) ...[
              Expanded(child: stats[i]),
              if (i < stats.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
