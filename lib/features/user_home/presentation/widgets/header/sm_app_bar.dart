import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/features/auth/application/auth_cubit.dart';

class SmAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SmAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final profile = state.profile;
        final avatarUrl = profile?.photoUrl ?? user?.photoUrl;
        final displayName = user?.displayName ?? 'Cuenta';
        return AppBar(
          title: const Text('Solo Músicos'),
          leading: Builder(
            builder: (context) {
              final scaffold = Scaffold.maybeOf(context);
              final hasDrawer = scaffold?.hasDrawer ?? false;
              if (!hasDrawer) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => scaffold?.openDrawer(),
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: InkWell(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.account),
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
                                  : '?',
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
