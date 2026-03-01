import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../cubits/manager_events_cubit.dart';
import '../../cubits/manager_events_state.dart';
import '../widgets/events/manager_event_card.dart';

class ManagerEventsPage extends StatefulWidget {
  const ManagerEventsPage({super.key});

  @override
  State<ManagerEventsPage> createState() => _ManagerEventsPageState();
}

class _ManagerEventsPageState extends State<ManagerEventsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ManagerEventsCubit>().loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.eventManagerEventForm),
        icon: const Icon(Icons.add),
        label: const Text('Crear Evento'),
      ),
      body: BlocBuilder<ManagerEventsCubit, ManagerEventsState>(
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

          final events = state.events;

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No has creado ningún evento aún.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: events.length + 1, // +1 for the header
            separatorBuilder: (context, index) {
              if (index == 0) return const SizedBox.shrink();
              return const Divider();
            },
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Mis Eventos',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                );
              }
              final event = events[index - 1];
              return ManagerEventCard(event: event);
            },
          );
        },
      ),
    );
  }
}
