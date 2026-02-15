import 'package:flutter/material.dart';

import '../../../../home/ui/pages/user_shell_page.dart';

import '../../../groups/repositories/groups_repository.dart';
import '../../../studios/repositories/studios_repository.dart';
import '../../repositories/rehearsals_repository.dart';
import '../../repositories/setlist_repository.dart';
import 'rehearsal_detail_view.dart';
import '../../../../features/messaging/repositories/chat_repository.dart';
import '../../../../features/notifications/repositories/invite_notifications_repository.dart';
import '../../../../features/contacts/cubits/liked_musicians_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RehearsalDetailPage extends StatelessWidget {
  const RehearsalDetailPage({
    super.key,
    required this.groupId,
    required this.rehearsalId,
    required this.groupsRepository,
    required this.chatRepository,
    required this.inviteNotificationsRepository,
    required this.likedMusiciansCubit,
  });

  final String groupId;
  final String rehearsalId;
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
      child: RehearsalDetailView(
        groupId: groupId,
        rehearsalId: rehearsalId,
        groupsRepository: context.read<GroupsRepository>(),
        rehearsalsRepository: context.read<RehearsalsRepository>(),
        setlistRepository: context.read<SetlistRepository>(),
        studiosRepository: context.read<StudiosRepository>(),
      ),
    );
  }
}
