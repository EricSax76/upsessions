import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/home/ui/pages/user_shell_page.dart';
import '../modules/contacts/cubits/liked_musicians_cubit.dart';
import '../modules/groups/repositories/groups_repository.dart';
import '../modules/messaging/repositories/chat_repository.dart';
import '../modules/notifications/repositories/invite_notifications_repository.dart';

Widget buildUserShell(BuildContext context, Widget child) {
  return UserShellPage(
    groupsRepository: context.read<GroupsRepository>(),
    chatRepository: context.read<ChatRepository>(),
    inviteNotificationsRepository: context.read<InviteNotificationsRepository>(),
    likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
    child: child,
  );
}
