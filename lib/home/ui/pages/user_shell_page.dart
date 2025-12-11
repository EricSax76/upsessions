import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../modules/auth/cubits/auth_cubit.dart';
import '../widgets/header/main_nav_bar.dart';
import '../widgets/header/sm_app_bar.dart';
import '../widgets/profile/profile_quick_actions_fab.dart';
import '../widgets/sidebar/user_sidebar.dart';

class UserShellPage extends StatelessWidget {
  const UserShellPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isWideLayout = MediaQuery.of(context).size.width >= 1200;

    final layout = isWideLayout
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 280, child: UserSidebar()),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          )
        : child;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        appBar: SmAppBar(
          bottom: const MainNavBar(),
          showMenuButton: !isWideLayout,
        ),
        drawer: isWideLayout
            ? null
            : const Drawer(child: SafeArea(child: UserSidebar())),
        body: layout,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: const ProfileQuickActionsFab(),
      ),
    );
  }
}
