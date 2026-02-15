import 'package:flutter/material.dart';

import 'package:upsessions/home/ui/pages/user_shell_page.dart';
import 'package:upsessions/features/contacts/ui/widgets/contacts_view.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/features/notifications/repositories/invite_notifications_repository.dart';
import 'package:upsessions/features/contacts/cubits/liked_musicians_cubit.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({
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
      child: ContactsView(chatRepository: chatRepository),
    );
  }
}
