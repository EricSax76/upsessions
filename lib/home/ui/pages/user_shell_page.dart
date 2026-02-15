import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';

import '../../../modules/auth/cubits/auth_cubit.dart';
import '../../../core/locator/locator.dart';
import '../../../modules/groups/cubits/my_groups_cubit.dart';
import '../../../features/notifications/cubits/notifications_status_cubit.dart';
import '../../../features/contacts/cubits/liked_musicians_cubit.dart';
import '../widgets/header/sm_app_bar.dart';
import '../widgets/profile/profile_quick_actions_fab.dart';
import '../widgets/sidebar/user_sidebar.dart';
import '../widgets/bottom_nav_bar.dart';

class UserShellPage extends StatelessWidget {
  const UserShellPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWideLayout = kIsWeb ? width >= 700 : width >= 1200;
    final showTopAppBar = kIsWeb || !isWideLayout;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MyGroupsCubit(groupsRepository: locate()),
        ),
        BlocProvider(
          create: (_) => NotificationsStatusCubit(
            chatRepository: locate(),
            inviteNotificationsRepository: locate(),
          ),
        ),
        BlocProvider<LikedMusiciansCubit>.value(
          value: locate<LikedMusiciansCubit>(),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            context.go(AppRoutes.login);
          }
        },
        child: Scaffold(
          drawer: isWideLayout
              ? null
              : const Drawer(child: SafeArea(child: UserSidebar())),
          appBar: showTopAppBar ? SmAppBar(showMenuButton: !isWideLayout) : null,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWideLayout) ...[
                const SizedBox(
                  width: 300,
                  child: Material(elevation: 0, child: UserSidebar()),
                ),
                const VerticalDivider(width: 1, thickness: 1),
              ],
              Expanded(key: const ValueKey('user-shell-content'), child: child),
            ],
          ),
          bottomNavigationBar: isWideLayout ? null : const UserBottomNavBar(),
          floatingActionButton: isWideLayout
              ? null
              : const ProfileQuickActionsFab(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      ),
    );
  }
}
