import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final profile = state.profile;
        final avatarUrl = profile?.photoUrl ?? user?.photoUrl;
        final displayName = user?.displayName ?? '';
        return AppBar(
          automaticallyImplyLeading: false,
          title: InkWell(
            onTap: () => context.go(AppRoutes.userHome),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text('Upsessions'),
            ),
          ),
          bottom: bottom,
          leading: showMenuButton
              ? Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : null,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: InkWell(
                onTap: () => context.push(AppRoutes.account),
                borderRadius: BorderRadius.circular(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      displayName,
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),
          ],
        );
      },
    );
  }
}
