import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:upsessions/modules/musicians/models/musician_entity.dart';
import 'package:upsessions/core/widgets/sm_avatar.dart';

import 'package:upsessions/core/widgets/continuous_carousel.dart';

class NewMusiciansSection extends StatelessWidget {
  const NewMusiciansSection({
    super.key,
    required this.musicians,
    this.onMusicianTap,
  });

  final List<MusicianEntity> musicians;
  final ValueChanged<MusicianEntity>? onMusicianTap;

  @override
  Widget build(BuildContext context) {
    if (musicians.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final listHeight = isCompact ? 120.0 : 100.0;
        final availableWidth = constraints.maxWidth == double.infinity
            ? 260.0
            : constraints.maxWidth;
        final cardWidth = isCompact
            ? (availableWidth * 0.7).clamp(180.0, 260.0)
            : 220.0;

        // Mapear los músicos a sus respectivos widgets empaquetados en SizedBox de ancho fijo
        final carouselItems = musicians.asMap().entries.map((entry) {
          final index = entry.key;
          final musician = entry.value;

          return SizedBox(
            width: cardWidth,
            child: _NewMusicianCard(
              musician: musician,
              onTap: onMusicianTap == null
                  ? null
                  : () => onMusicianTap!(musician),
            ),
          )
              .animate()
              .fade(duration: 350.ms, delay: (index * 70).ms)
              .slideX(
                begin: 0.15,
                end: 0,
                duration: 350.ms,
                delay: (index * 70).ms,
                curve: Curves.easeOutQuad,
              );
        }).toList();

        return SizedBox(
          height: listHeight,
          child: ContinuousCarousel(
            spacing: 12.0,
            scrollSpeed: 45.0, // Ajustar velocidad (pixels por segundo) dependiendo del gusto
            children: carouselItems,
          ),
        );
      },
    );
  }
}

class _NewMusicianCard extends StatefulWidget {
  const _NewMusicianCard({required this.musician, this.onTap});

  final MusicianEntity musician;
  final VoidCallback? onTap;

  @override
  State<_NewMusicianCard> createState() => _NewMusicianCardState();
}

class _NewMusicianCardState extends State<_NewMusicianCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTap: widget.onTap,
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                SmAvatar(
                  radius: 28,
                  imageUrl: widget.musician.photoUrl,
                  initials: widget.musician.name.isNotEmpty ? widget.musician.name[0] : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.musician.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.musician.instrument,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.musician.city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(target: _isPressed ? 1 : (_isHovered ? 0.5 : 0))
        .scaleXY(end: 0.96, duration: 150.ms, curve: Curves.easeOut)
        .scaleXY(begin: 1.0, end: 1.03, duration: 200.ms, curve: Curves.easeOut);
  }
}
