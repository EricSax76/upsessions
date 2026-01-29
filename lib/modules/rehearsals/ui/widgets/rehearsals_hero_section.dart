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
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.secondaryContainer, colorScheme.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (groupPhotoUrl != null || groupName.isNotEmpty)
                SmAvatar(
                  radius: 20,
                  imageUrl: groupPhotoUrl,
                  initials:
                      groupName.isNotEmpty ? groupName[0].toUpperCase() : null,
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                ),
              if (groupPhotoUrl != null || groupName.isNotEmpty)
                const SizedBox(width: 12),
              Flexible(
                child: Text(
                  groupName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loc.rehearsalsTotalCount(totalRehearsals),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}
