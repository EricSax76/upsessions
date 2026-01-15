import 'package:flutter/material.dart';
import 'package:upsessions/core/widgets/sm_avatar.dart';

class ChatThreadListItem extends StatelessWidget {
  const ChatThreadListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.avatarUrl,
    this.unreadCount = 0,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final String? avatarUrl;
  final int unreadCount;
  final bool selected;
  final VoidCallback onTap;

  String _initialsFromName(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return '?';
    final parts = cleaned.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final buffer = StringBuffer();
    for (final part in parts.take(2)) {
      buffer.write(part[0]);
    }
    final result = buffer.toString().trim();
    return result.isEmpty ? '?' : result.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final surface = selected
        ? colorScheme.secondaryContainer.withAlpha(110)
        : colorScheme.surface;
    final borderColor = colorScheme.outlineVariant.withAlpha(160);
    final subtitleColor = colorScheme.onSurfaceVariant;

    final badgeCount = unreadCount < 0 ? 0 : unreadCount;
    final badgeText = badgeCount > 99 ? '99+' : badgeCount.toString();

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              SmAvatar(
                radius: 22,
                imageUrl: avatarUrl,
                initials: _initialsFromName(title),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: badgeCount > 0 ? FontWeight.w700 : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle.trim().isEmpty ? ' ' : subtitle.trim(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

