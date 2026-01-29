import 'package:flutter/material.dart';

import '../../../../features/contacts/ui/widgets/musician_like_button.dart';
import '../../../../modules/musicians/models/musician_entity.dart';
import '../../../../modules/musicians/models/musician_liked_musician_mapper.dart';
import '../../../../core/widgets/sm_avatar.dart';

class MusiciansGrid extends StatelessWidget {
  const MusiciansGrid({super.key, required this.musicians});

  final List<MusicianEntity> musicians;

  @override
  Widget build(BuildContext context) {
    if (musicians.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final cardWidth = isCompact ? 220.0 : 260.0;
        final cardHeight = isCompact ? 120.0 : 100.0;

        return SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: musicians.length,
            itemBuilder: (context, index) {
              final musician = musicians[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: cardWidth,
                  child: _MusicianTile(musician: musician),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MusicianTile extends StatefulWidget {
  const _MusicianTile({required this.musician});

  final MusicianEntity musician;

  @override
  State<_MusicianTile> createState() => _MusicianTileState();
}

class _MusicianTileState extends State<_MusicianTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final likedMusician = widget.musician.toLikedMusician();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translateByDouble(0.0, _isHovered ? -4.0 : 0.0, 0.0, 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surfaceContainerHighest,
              colorScheme.surfaceContainer,
            ],
          ),
          border: Border.all(
            color: _isHovered
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.2),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SmAvatar(
              radius: 28,
              imageUrl: widget.musician.photoUrl,
              initials: widget.musician.name.isNotEmpty
                  ? widget.musician.name[0]
                  : null,
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
            MusicianLikeButton(
              musician: likedMusician,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
