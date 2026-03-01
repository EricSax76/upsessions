import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/ui/shell/core_shell.dart';
import '../../../../../core/widgets/app_logo.dart';
import '../../../../../core/widgets/sm_avatar.dart';
import '../../../cubits/event_manager_auth_cubit.dart';
import '../../../cubits/event_manager_auth_state.dart';
import 'manager_bottom_nav.dart';
import 'manager_sidebar.dart';

class ManagerShellPage extends StatelessWidget {
  const ManagerShellPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWideLayout = kIsWeb ? width >= 700 : width >= 1200;
    final showTopAppBar = kIsWeb || !isWideLayout;

    return BlocListener<EventManagerAuthCubit, EventManagerAuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == EventManagerAuthStatus.unauthenticated) {
          context.go(AppRoutes.eventManagerLogin);
        }
      },
      child: BlocBuilder<EventManagerAuthCubit, EventManagerAuthState>(
        builder: (context, state) {
          final manager = state.manager;
          final name = manager?.name ?? '';
          final initials = name.trim().isEmpty ? '' : name.trim()[0];

          return CoreShell(
            sidebar: const ManagerSidebar(),
            bottomNavigationBar: const ManagerBottomNav(),
            appBar: showTopAppBar
                ? AppBar(
                    centerTitle: true,
                    title: AppLogo(
                      label: 'UpSessions PRO',
                      textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      iconSize: 22,
                    ),
                    leading: isWideLayout
                        ? null
                        : Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () => Scaffold.of(context).openDrawer(),
                            ),
                          ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: InkWell(
                          onTap: () => context.push(AppRoutes.eventManagerProfile),
                          borderRadius: BorderRadius.circular(24),
                          child: SmAvatar(
                            radius: 16,
                            imageUrl: manager?.logoUrl,
                            initials: initials,
                            fallbackIcon: Icons.store_outlined,
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
            child: child,
          );
        },
      ),
    );
  }
}
