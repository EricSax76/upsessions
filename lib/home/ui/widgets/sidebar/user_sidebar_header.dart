import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/sm_avatar.dart';
import '../../../../modules/auth/cubits/auth_cubit.dart';
import '../../../../modules/profile/cubit/profile_cubit.dart';

class UserSidebarHeader extends StatelessWidget {
  const UserSidebarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            final user = authState.user;
            final profile = profileState.profile;
            final avatarUrl = profile?.photoUrl ?? user?.photoUrl;
            final displayName = user?.displayName ?? '';
            final theme = Theme.of(context);

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   InkWell(
                    onTap: () => context.push(AppRoutes.account),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          SmAvatar(
                            radius: 24,
                            imageUrl: avatarUrl,
                            initials: displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '',
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Ver perfil',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
