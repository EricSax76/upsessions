import 'package:flutter/material.dart';

import '../../../../../core/utils/string_utils.dart';
import '../../../../../core/widgets/sm_avatar.dart';
import '../../../models/group_member.dart';

class MemberAvatarTile extends StatelessWidget {
  const MemberAvatarTile({super.key, required this.member, this.onTap});

  final GroupMember member;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final initials = getInitials(member.name);
    final isOwner = member.role == 'owner';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: SmAvatar(
                  radius: 34,
                  imageUrl: member.photoUrl,
                  initials: initials,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
              ),
              if (isOwner)
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                      border: Border.all(color: colorScheme.surface, width: 1.5),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 12,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          member.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
