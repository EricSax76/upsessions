import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/locator/locator.dart';
import '../features/home/ui/pages/user_shell_page.dart';
import '../modules/contacts/cubits/liked_musicians_cubit.dart';
import '../modules/event_manager/repositories/manager_notifications_repository.dart';
import '../modules/groups/repositories/groups_repository.dart';
import '../modules/musicians/repositories/musician_notifications_repository.dart';
import '../modules/studios/repositories/studio_notifications_repository.dart';
import '../modules/venues/repositories/venue_notifications_repository.dart';

Widget buildUserShell(BuildContext context, Widget child) {
  return UserShellPage(
    groupsRepository: context.read<GroupsRepository>(),
    musicianNotificationsRepository: context
        .read<MusicianNotificationsRepository>(),
    studioNotificationsRepository: locate<StudioNotificationsRepository>(),
    managerNotificationsRepository: locate<ManagerNotificationsRepository>(),
    venueNotificationsRepository: locate<VenueNotificationsRepository>(),
    likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
    child: child,
  );
}
