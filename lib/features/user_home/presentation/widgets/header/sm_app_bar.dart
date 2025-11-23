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
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.account),
          icon: const Icon(Icons.person_outline),
        ),
        TextButton.icon(
          onPressed: () => context.read<AuthCubit>().signOut(),
          icon: const Icon(Icons.logout),
          label: const Text('Salir'),
          style: TextButton.styleFrom(foregroundColor: colorScheme.onPrimary),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
