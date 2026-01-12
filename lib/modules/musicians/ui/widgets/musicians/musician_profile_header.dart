import 'package:flutter/material.dart';

import '../../../../../core/widgets/sm_avatar.dart';
import '../../../models/musician_entity.dart';

class MusicianProfileHeader extends StatelessWidget {
  const MusicianProfileHeader({super.key, required this.musician});

  final MusicianEntity musician;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final initials = musician.name.isNotEmpty
        ? musician.name.trim().split(' ').take(2).map((word) => word[0]).join()
        : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.primary.withValues()],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SmAvatar(
                radius: 40,
                imageUrl: musician.photoUrl,
                initials: initials,
                backgroundColor: colors.onPrimary.withValues(),
                foregroundColor: colors.onPrimary,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      musician.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeaderPill(
                          icon: Icons.music_note,
                          label: musician.instrument,
                        ),
                        _HeaderPill(
                          icon: Icons.location_on_outlined,
                          label: musician.city,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Disponible para eventos y colaboraciones',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onPrimary.withValues(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: colors.onPrimary.withValues(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.onPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
