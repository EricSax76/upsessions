import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../home/ui/pages/user_shell_page.dart';
import '../../cubits/group_cubit.dart';
import '../../repositories/groups_repository.dart';
import '../widgets/group_detail/group_page_view.dart';
import '../../../../features/messaging/repositories/chat_repository.dart';
import '../../../../features/notifications/repositories/invite_notifications_repository.dart';
import '../../../../features/contacts/cubits/liked_musicians_cubit.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({
    super.key,
    required this.groupId,
    required this.groupsRepository,
    required this.chatRepository,
    required this.inviteNotificationsRepository,
    required this.likedMusiciansCubit,
  });

  final String groupId;
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
      child: BlocProvider(
        create: (context) => GroupCubit(
          groupId: groupId,
          groupsRepository: context.read<GroupsRepository>(),
          imagePicker: ImagePicker(),
        ),
        child: DefaultTabController(
          length: 2,
          child: GroupPageView(groupId: groupId),
        ),
      ),
    );
  }
}
