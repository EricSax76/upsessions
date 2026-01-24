import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/constants/breakpoints.dart';
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
    final width = MediaQuery.of(context).size.width;
    final isWideLayout = width >= 1200;
    final isMobile = context.isMobile;

    Widget body;
    if (isWideLayout) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 300,
            child: Material(
              elevation: 0,
              child: UserSidebar(),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Scaffold(
              body: child,
            ),
          ),
        ],
      );
    } else {
      body = child;
    }

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        drawer: isWideLayout
            ? null
            : const Drawer(
                child: SafeArea(child: UserSidebar()),
              ),
        appBar: isWideLayout
            ? null
            : SmAppBar(
                bottom: isMobile ? null : const MainNavBar(),
                showMenuButton: true,
              ),
        body: body,
        bottomNavigationBar: isWideLayout || !isMobile
            ? null
            : const SafeArea(
                child: MainNavBar(),
              ),
        floatingActionButton: isWideLayout ? null : const ProfileQuickActionsFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
