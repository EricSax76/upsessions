import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../modules/auth/cubits/auth_cubit.dart';
import '../../../../modules/auth/domain/profile_entity.dart';

class ProfileStatusBar extends StatelessWidget {
  const ProfileStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final profile = state.profile;
        final user = state.user;
        final avatarUrl = profile?.photoUrl ?? user?.photoUrl;
        final displayName = profile?.name ?? user?.displayName ?? 'Tu perfil';
        final subtitle = _buildSubtitle(profile);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 600;
            final padding = EdgeInsets.symmetric(
              horizontal: isCompact ? 20 : 28,
              vertical: isCompact ? 20 : 24,
            );

            Widget buildUserInfo() {
              final avatar = CircleAvatar(
                radius: isCompact ? 28 : 32,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.1),
                child: avatarUrl == null
                    ? Icon(
                        Icons.person,
                        color: colorScheme.primary,
                      )
                    : null,
              );
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  avatar,
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary
                                .withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: padding,
                child: buildUserInfo(),
              ),
            );
          },
        );
      },
    );
  }

  String _buildSubtitle(ProfileEntity? profile) {
    if (profile == null) {
      return 'Completa tu perfil para destacar en la comunidad';
    }
    final role = profile.skills.isNotEmpty
        ? profile.skills.first
        : 'Talento disponible';
    final location = profile.location.isNotEmpty
        ? profile.location
        : 'Ubicación no registrada';
    if (profile.bio.isNotEmpty) {
      return profile.bio;
    }
    return '$role · $location';
  }
}
