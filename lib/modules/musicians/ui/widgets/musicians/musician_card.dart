import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/widgets/sm_avatar.dart';
import '../../../models/musician_entity.dart';

class MusicianCard extends StatefulWidget {
  const MusicianCard({super.key, required this.musician, this.onTap});

  final MusicianEntity musician;
  final VoidCallback? onTap;

  @override
  State<MusicianCard> createState() => _MusicianCardState();
}

class _MusicianCardState extends State<MusicianCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final styles = widget.musician.styles.take(3).toList();
    final initials = widget.musician.name.isNotEmpty
        ? widget.musician.name.trim().split(' ').take(2).map((w) => w[0]).join()
        : '';

    return Card(
      margin: EdgeInsets.zero,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: widget.onTap,
        onHover: (hovered) => setState(() => _isHovered = hovered),
        onHighlightChanged: (highlighted) => setState(() => _isPressed = highlighted),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SmAvatar(
                radius: 40,
                imageUrl: widget.musician.photoUrl,
                initials: initials,
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
              ),
              const SizedBox(height: 16),
              Text(
                widget.musician.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                widget.musician.instrument,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.musician.city,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              if (styles.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final style in styles)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: colors.surfaceContainerHighest,
                        ),
                        child: Text(
                          style,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate(target: _isPressed ? 1 : (_isHovered ? 0.5 : 0))
        .scaleXY(end: 0.97, duration: 150.ms, curve: Curves.easeOut)
        .scaleXY(begin: 1.0, end: 1.02, duration: 200.ms, curve: Curves.easeOut);
  }
}
