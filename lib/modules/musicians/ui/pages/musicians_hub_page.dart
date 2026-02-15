import 'package:flutter/material.dart';

import '../../../../home/ui/pages/user_shell_page.dart';
import 'musician_search_page.dart';
import '../../../../modules/groups/repositories/groups_repository.dart';
import '../../../../features/messaging/repositories/chat_repository.dart';
import '../../../../features/notifications/repositories/invite_notifications_repository.dart';
import '../../../../features/contacts/cubits/liked_musicians_cubit.dart';

class MusiciansHubPage extends StatelessWidget {
  const MusiciansHubPage({
    super.key,
    required this.groupsRepository,
    required this.chatRepository,
    required this.inviteNotificationsRepository,
    required this.likedMusiciansCubit,
  });

  final GroupsRepository groupsRepository;
  final ChatRepository chatRepository;
  final InviteNotificationsRepository inviteNotificationsRepository;
  final LikedMusiciansCubit likedMusiciansCubit;

  @override
  Widget build(BuildContext context) {
    return UserShellPage(
      groupsRepository: groupsRepository,
      chatRepository: chatRepository,
      inviteNotificationsRepository: inviteNotificationsRepository,
      likedMusiciansCubit: likedMusiciansCubit,
      child: const MusicianSearchPage(showAppBar: false),
    );
  }
}
