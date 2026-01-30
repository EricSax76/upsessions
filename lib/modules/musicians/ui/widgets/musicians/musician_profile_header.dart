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
    
    // Premium Header Redesign
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        // Narrow Layout (Centered Column)
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SmAvatar(
                radius: 64, // Slightly larger for center focus
                imageUrl: musician.photoUrl,
                initials: initials,
                backgroundColor: colors.surfaceContainerHighest,
                foregroundColor: colors.onSurface,
              ),
              const SizedBox(height: 16),
              Text(
                musician.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  fontSize: 32, // explicit size control
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                   if (musician.instrument.isNotEmpty)
                    _HeaderPill(
                      icon: Icons.music_note,
                      label: musician.instrument,
                      color: colors.primary,
                      backgroundColor: colors.primaryContainer.withOpacity(0.4),
                    ),
                   if (musician.city.isNotEmpty)
                    _HeaderPill(
                      icon: Icons.location_on_outlined,
                      label: musician.city,
                      color: colors.secondary,
                      backgroundColor: colors.secondaryContainer.withOpacity(0.4),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Disponible para eventos y colaboraciones',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }

        // Wide Layout (Row)
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Avatar
            SmAvatar(
              radius: 56, // Increased size for premium focus
              imageUrl: musician.photoUrl,
              initials: initials,
              backgroundColor: colors.surfaceContainerHighest,
              foregroundColor: colors.onSurface,
            ),
            const SizedBox(width: 24),
            
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const SizedBox(height: 8), // Visual alignment with top of avatar circle
                  Text(
                    musician.name,
                    style: theme.textTheme.displaySmall?.copyWith( // Larger, bolder
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Chips for details
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                       if (musician.instrument.isNotEmpty)
                        _HeaderPill(
                          icon: Icons.music_note,
                          label: musician.instrument,
                          color: colors.primary,
                          backgroundColor: colors.primaryContainer.withOpacity(0.4),
                        ),
                       if (musician.city.isNotEmpty)
                        _HeaderPill(
                          icon: Icons.location_on_outlined,
                          label: musician.city,
                          color: colors.secondary,
                          backgroundColor: colors.secondaryContainer.withOpacity(0.4),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Disponible para eventos y colaboraciones',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.icon, 
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
