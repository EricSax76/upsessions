import 'package:flutter/material.dart';
import '../../../../core/widgets/sm_avatar.dart';
import '../../../../l10n/app_localizations.dart';

class RehearsalsHeroSection extends StatelessWidget {
  const RehearsalsHeroSection({
    super.key,
    required this.groupName,
    required this.totalRehearsals,
    this.groupPhotoUrl,
    this.onCreateRehearsal,
    this.onInviteMusician,
    this.canManageMembers = false,
  });

  final String groupName;
  final int totalRehearsals;
  final String? groupPhotoUrl;
  final VoidCallback? onCreateRehearsal;
  final VoidCallback? onInviteMusician;
  final bool canManageMembers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.secondaryContainer, colorScheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupName,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  loc.rehearsalsTotalCount(totalRehearsals),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _QuickActionButton(
                      icon: Icons.add_circle_outline,
                      label: loc.rehearsalsNewButton,
                      onPressed: onCreateRehearsal ?? () {},
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: colorScheme.onSecondary,
                    ),
                    if (onInviteMusician != null)
                      _QuickActionButton(
                        icon: Icons.person_add_alt_1_outlined,
                        label: canManageMembers
                            ? loc.rehearsalsAddMusicianButton
                            : loc.rehearsalsOnlyAdmin,
                        onPressed: canManageMembers ? onInviteMusician! : () {},
                        backgroundColor: colorScheme.surface,
                        foregroundColor: colorScheme.secondary,
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (groupPhotoUrl != null || groupName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: SmAvatar(
                radius: 60,
                imageUrl: groupPhotoUrl,
                initials: groupName.isNotEmpty ? groupName[0].toUpperCase() : null,
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }
}
