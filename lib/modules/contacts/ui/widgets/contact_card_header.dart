import 'package:flutter/material.dart';

import '../../../../core/widgets/sm_avatar.dart';
import '../../models/liked_musician.dart';
import 'musician_like_button.dart';

class ContactCardHeader extends StatelessWidget {
  const ContactCardHeader({super.key, required this.musician});

  final LikedMusician musician;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final styles = musician.nonEmptyStyles;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmAvatar(
          radius: 24,
          imageUrl: musician.photoUrl,
          initials: musician.initials,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      musician.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  MusicianLikeButton(
                    musician: musician,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${musician.instrument} · ${musician.city}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (styles.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  styles.take(3).join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.secondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
