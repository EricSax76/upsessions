import 'package:flutter/material.dart';

import 'package:upsessions/features/messaging/ui/pages/chat_page.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/features/notifications/repositories/invite_notifications_repository.dart';
import 'package:upsessions/features/contacts/cubits/liked_musicians_cubit.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/auth/repositories/profile_repository.dart';

class MessagesPageArgs {
  const MessagesPageArgs({this.initialThreadId});

  final String? initialThreadId;
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({
    super.key,
    this.initialThreadId,
    required this.groupsRepository,
    required this.chatRepository,
    required this.inviteNotificationsRepository,
    required this.likedMusiciansCubit,
    required this.authRepository,
    required this.profileRepository,
  });

  final String? initialThreadId;
  final GroupsRepository groupsRepository;
  final ChatRepository chatRepository;
  final InviteNotificationsRepository inviteNotificationsRepository;
  final LikedMusiciansCubit likedMusiciansCubit;
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  @override
  Widget build(BuildContext context) {
    return ChatPage(
      showAppBar: false,
      initialThreadId: initialThreadId,
      chatRepository: chatRepository,
      authRepository: authRepository,
      profileRepository: profileRepository,
    );
  }
}
