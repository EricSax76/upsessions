import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../cubits/event_manager_auth_cubit.dart';
import '../../cubits/manager_dashboard_cubit.dart';
import '../../cubits/manager_dashboard_state.dart';
import '../widgets/dashboard/manager_hero_section.dart';
import '../widgets/dashboard/upcoming_events_card.dart';

class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({super.key});

  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<ManagerDashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<EventManagerAuthCubit>().state.manager;

    return BlocBuilder<ManagerDashboardCubit, ManagerDashboardState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage != null) {
          return Center(
            child: Text(
              'Error: ${state.errorMessage}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.eventManagerEventForm),
                    icon: const Icon(Icons.add),
                    label: const Text('Crear Evento'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ManagerHeroSection(
                managerName: manager?.name ?? 'Gestor',
                totalEvents: state.totalEvents,
                totalCapacity: state.totalCapacity,
                eventsThisWeek: state.eventsThisWeek,
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        UpcomingEventsCard(events: state.upcomingEvents),
                        const SizedBox(height: 16),
                        // ActiveJamSessionsCard(count: state.activeJamSessionsCount),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Expanded(
                  //   flex: 1,
                  //   child: PendingRequestsCard(count: state.pendingRequestsCount),
                  // ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
