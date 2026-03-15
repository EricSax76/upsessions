import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../auth/repositories/auth_repository.dart';
import '../../cubits/my_studio_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../cubits/studios_status.dart';
import '../widgets/empty_states/no_studio_empty_state.dart';
import 'widgets/studio_dashboard_bookings_tab.dart';
import 'widgets/studio_dashboard_rooms_tab.dart';

class StudioDashboardPage extends StatelessWidget {
  const StudioDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = locate<AuthRepository>();
    final userId = authRepo.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      return const _StudioDashboardAuthRedirect();
    }

    final loc = AppLocalizations.of(context);

    return BlocBuilder<MyStudioCubit, StudiosState>(
      builder: (context, state) {
        if (state.status == StudiosStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.myStudio == null) {
          return NoStudioEmptyState(
            onRegister: () async {
              await context.push(AppRoutes.studiosCreate);
              if (!context.mounted) return;
              context.read<MyStudioCubit>().loadMyStudio(userId);
            },
          );
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 0,
                child: TabBar(
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: [
                    Tab(
                      text: loc.studioDashboardTabRooms,
                      icon: const Icon(Icons.meeting_room),
                    ),
                    Tab(
                      text: loc.studioDashboardTabBookings,
                      icon: const Icon(Icons.event),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    StudioDashboardRoomsTab(
                      state: state,
                      onCreateRoom: () async {
                        await context.push(
                          AppRoutes.studiosRoomCreatePath(state.myStudio!.id),
                        );
                        if (!context.mounted) return;
                        context.read<MyStudioCubit>().loadMyStudio(userId);
                      },
                      onEditRoom: (roomId) async {
                        await context.push(
                          AppRoutes.studiosRoomEditPath(
                            studioId: state.myStudio!.id,
                            roomId: roomId,
                          ),
                        );
                        if (!context.mounted) return;
                        context.read<MyStudioCubit>().loadMyStudio(userId);
                      },
                    ),
                    StudioDashboardBookingsTab(state: state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StudioDashboardAuthRedirect extends StatefulWidget {
  const _StudioDashboardAuthRedirect();

  @override
  State<_StudioDashboardAuthRedirect> createState() =>
      _StudioDashboardAuthRedirectState();
}

class _StudioDashboardAuthRedirectState
    extends State<_StudioDashboardAuthRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(AppRoutes.studiosLogin);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
