import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';

import '../../../../home/ui/pages/user_shell_page.dart';
import '../../../../modules/auth/repositories/auth_repository.dart';
import '../../repositories/events_repository.dart';
import '../../cubits/events_page_cubit.dart';
import '../widgets/events_dashboard.dart';
import '../../../../modules/groups/repositories/groups_repository.dart';
import '../../../../features/messaging/repositories/chat_repository.dart';
import '../../../../features/notifications/repositories/invite_notifications_repository.dart';
import '../../../../features/contacts/cubits/liked_musicians_cubit.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({
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
    final ownerId = context.read<AuthRepository>().currentUser?.id;
    return BlocProvider(
      create: (_) =>
          EventsPageCubit(repository: context.read<EventsRepository>())..load(),
      child: UserShellPage(
        groupsRepository: groupsRepository,
        chatRepository: chatRepository,
        inviteNotificationsRepository: inviteNotificationsRepository,
        likedMusiciansCubit: likedMusiciansCubit,
        child: BlocListener<EventsPageCubit, EventsPageState>(
          listenWhen: (previous, current) =>
              previous.draftSavedCount != current.draftSavedCount,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ficha de evento lista para compartir.'),
              ),
            );
          },
          child: BlocBuilder<EventsPageCubit, EventsPageState>(
            builder: (context, state) {
              final cubit = context.read<EventsPageCubit>();
              return EventsDashboard(
                events: state.events,
                loading: state.loading || state.savingDraft,
                eventsCount: state.events.length,
                thisWeekCount: state.thisWeekCount,
                totalCapacity: state.totalCapacity,
                ownerId: ownerId,
                onRefresh: cubit.load,
                onSelectForPreview: cubit.selectPreview,
                onCreateEvent: () => context.push(AppRoutes.createEvent),
                onViewDetails: (event) => context.push(
                  AppRoutes.eventDetailPath(event.id),
                  extra: event,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
