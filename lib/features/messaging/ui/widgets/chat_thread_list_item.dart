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
    
    // Design decisions from user screenshot:
    // Selected: Pinkish background / Border
    // Normal: White/Surface background
    
    final backgroundColor = selected
        ? const Color(0xFFF43F5E).withValues(alpha: 0.12) // Rose-like opacity
        : colorScheme.surface;
        
    final borderColor = selected
        ? const Color(0xFFF43F5E).withValues(alpha: 0.5)
        : colorScheme.outlineVariant.withValues(alpha: 0.5);

    final titleColor = colorScheme.onSurface;
    final subtitleColor = selected 
        ? const Color(0xFFF43F5E) // Text matches selection
        : colorScheme.onSurfaceVariant;

    final badgeCount = unreadCount < 0 ? 0 : unreadCount;
    final badgeText = badgeCount > 99 ? '99+' : badgeCount.toString();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              SmAvatar(
                radius: 24, // Slightly larger
                imageUrl: avatarUrl,
                initials: _initialsFromName(title),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle.trim().isEmpty ? 'Start a conversation' : subtitle.trim(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                        fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF43F5E), // Rose
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badgeText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: selected 
                    ? const Color(0xFFF43F5E).withValues(alpha: 0.8) 
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

