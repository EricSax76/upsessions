import 'package:flutter/material.dart';

class ManagerHeroSection extends StatelessWidget {
  const ManagerHeroSection({
    super.key,
    required this.managerName,
    required this.totalEvents,
    required this.totalCapacity,
    required this.eventsThisWeek,
  });

  final String managerName;
  final int totalEvents;
  final int totalCapacity;
  final int eventsThisWeek;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, $managerName!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este es el resumen de tu actividad como promotor.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatItem(context, 'Total Eventos', totalEvents.toString()),
              const SizedBox(width: 16),
              _buildStatItem(context, 'Aforo Total', totalCapacity.toString()),
              const SizedBox(width: 16),
              _buildStatItem(context, 'Esta Semana', eventsThisWeek.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
