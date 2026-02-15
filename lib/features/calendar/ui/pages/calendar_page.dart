import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';

import '../../../../home/ui/pages/user_shell_page.dart';
import '../../../events/repositories/events_repository.dart';
import '../../cubits/calendar_cubit.dart';
import '../../cubits/calendar_state.dart';
import 'calendar_dashboard.dart';
import '../../../../modules/groups/repositories/groups_repository.dart';
import '../../../../features/messaging/repositories/chat_repository.dart';
import '../../../../features/notifications/repositories/invite_notifications_repository.dart';
import '../../../../features/contacts/cubits/liked_musicians_cubit.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({
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
    return BlocProvider(
      create: (_) =>
          CalendarCubit(repository: context.read<EventsRepository>()),
      child: UserShellPage(
        groupsRepository: groupsRepository,
        chatRepository: chatRepository,
        inviteNotificationsRepository: inviteNotificationsRepository,
        likedMusiciansCubit: likedMusiciansCubit,
        child: BlocBuilder<CalendarCubit, CalendarState>(
          builder: (context, state) {
            final cubit = context.read<CalendarCubit>();
            return CalendarDashboard(
              state: state,
              onRefresh: cubit.refresh,
              onPreviousMonth: cubit.previousMonth,
              onNextMonth: cubit.nextMonth,
              onSelectDay: cubit.selectDay,
              onGoToToday: cubit.goToToday,
              onViewEvent: (event) {
                context.push(AppRoutes.eventDetailPath(event.id), extra: event);
              },
            );
          },
        ),
      ),
    );
  }
}
