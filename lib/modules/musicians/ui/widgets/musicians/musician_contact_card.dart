import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class MusicianContactCard extends StatelessWidget {
  const MusicianContactCard({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.onInvite,
  });

  final bool isLoading;
  final VoidCallback? onPressed;
  final VoidCallback? onInvite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant),
      ),
      color: colors.surface, // Clean background
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.connect_without_contact,
                    color: colors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.musicianContactTitle, 
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                       Text(
                        loc.musicianContactDescription,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, 
                              color: colors.onPrimary
                            ),
                          )
                        : const Icon(Icons.message_rounded),
                    label: Text(isLoading
                        ? loc.musicianContactLoading
                        : loc.musicianContactButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded( // Make invite button equal width
                  child: OutlinedButton.icon(
                    onPressed: onInvite,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: colors.outline),
                    ),
                    icon: const Icon(Icons.group_add_outlined),
                    label: Text(loc.musicianInviteButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
