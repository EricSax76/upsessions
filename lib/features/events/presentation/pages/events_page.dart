import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../../../modules/auth/data/auth_repository.dart';
import '../../data/events_repository.dart';
import '../cubit/events_page_cubit.dart';
import '../widgets/events_dashboard.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ownerId = locate<AuthRepository>().currentUser?.id;
    return BlocProvider(
      create: (_) =>
          EventsPageCubit(repository: locate<EventsRepository>())..load(),
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
        child: UserShellPage(
          child: BlocBuilder<EventsPageCubit, EventsPageState>(
            builder: (context, state) {
              final cubit = context.read<EventsPageCubit>();
              return EventsDashboard(
                events: state.events,
                preview: state.preview,
                loading: state.loading || state.savingDraft,
                eventsCount: state.events.length,
                thisWeekCount: state.thisWeekCount,
                totalCapacity: state.totalCapacity,
                ownerId: ownerId,
                onRefresh: cubit.load,
                onGenerateDraft: cubit.generateDraft,
                onSelectForPreview: cubit.selectPreview,
                onViewDetails: (event) =>
                    context.push(AppRoutes.eventDetail, extra: event),
              );
            },
          ),
        ),
      ),
    );
  }
}
