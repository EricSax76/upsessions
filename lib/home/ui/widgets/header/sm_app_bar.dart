import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/widgets/app_logo.dart';
import 'package:upsessions/core/widgets/sm_avatar.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/profile/cubit/profile_cubit.dart';

class SmAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SmAppBar({super.key, this.bottom, this.showMenuButton = false});

  final PreferredSizeWidget? bottom;
  final bool showMenuButton;

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + 12 + (bottom?.preferredSize.height ?? 0),
  );

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
            final appBarTheme = Theme.of(context).appBarTheme;
            final appBarBackground =
                appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface;
            final logo = AppLogo(
              label: 'UpSessions',
              textStyle: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              iconSize: 24,
            );

            return AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: appBarBackground,
              elevation: 0,
              scrolledUnderElevation: 0,
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: appBarBackground.withValues(alpha: 0.9),
                  ),
                ),
              ),
              shape: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              title: InkWell(
                onTap: () => context.go(AppRoutes.userHome),
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: logo,
                ),
              ),
              centerTitle: true,
              leading: showMenuButton
                  ? Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu_rounded),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    )
                  : null,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, left: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => context.push(AppRoutes.account),
                      borderRadius: BorderRadius.circular(24),
                      child: SmAvatar(
                        radius: 17, // Slightly larger visual with border
                        imageUrl: avatarUrl,
                        initials: displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '',
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ],
              bottom: bottom,
            );
          },
        );
      },
    );
  }
}
