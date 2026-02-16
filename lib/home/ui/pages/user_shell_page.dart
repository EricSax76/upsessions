import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/ui/shell/core_shell.dart';

import '../../../modules/auth/cubits/auth_cubit.dart';

import '../../../modules/groups/cubits/my_groups_cubit.dart';
import '../../../features/notifications/cubits/notifications_status_cubit.dart';
import '../../../features/contacts/cubits/liked_musicians_cubit.dart';
import '../../../features/messaging/repositories/chat_repository.dart';
import '../../../features/notifications/repositories/invite_notifications_repository.dart';
import '../../../modules/groups/repositories/groups_repository.dart';
import '../widgets/header/sm_app_bar.dart';
import '../widgets/profile/profile_quick_actions_fab.dart';
import '../widgets/sidebar/user_sidebar.dart';
import '../widgets/bottom_nav_bar.dart';

class UserShellPage extends StatelessWidget {
  const UserShellPage({
    super.key,
    required this.child,
    required this.groupsRepository,
    required this.chatRepository,
    required this.inviteNotificationsRepository,
    required this.likedMusiciansCubit,
  });

  final Widget child;
  final GroupsRepository groupsRepository;
  final ChatRepository chatRepository;
  final InviteNotificationsRepository inviteNotificationsRepository;
  final LikedMusiciansCubit likedMusiciansCubit;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWideLayout = kIsWeb ? width >= 700 : width >= 1200;
    
    // On web, we always showed top bar in the previous code.
    // Logic: `showTopAppBar = kIsWeb || !isWideLayout`
    final showTopAppBar = kIsWeb || !isWideLayout;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MyGroupsCubit(groupsRepository: groupsRepository),
        ),
        BlocProvider(
          create: (_) => NotificationsStatusCubit(
            chatRepository: chatRepository,
            inviteNotificationsRepository: inviteNotificationsRepository,
          ),
        ),
        BlocProvider<LikedMusiciansCubit>.value(value: likedMusiciansCubit),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            context.go(AppRoutes.login);
          }
        },
        child: CoreShell(
          sidebar: const UserSidebar(),
          appBar: showTopAppBar 
              ? SmAppBar(showMenuButton: !isWideLayout) 
              : null,
          bottomNavigationBar: const UserBottomNavBar(),
          floatingActionButton: isWideLayout ? null : const ProfileQuickActionsFab(),
          child: KeyedSubtree(
            key: const ValueKey('user-shell-content'),
            child: child,
          ),
        ),
      ),
    );
  }
}
