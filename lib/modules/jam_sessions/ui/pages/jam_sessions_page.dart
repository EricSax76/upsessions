import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../cubits/jam_sessions_cubit.dart';
import '../../cubits/jam_sessions_state.dart';
import '../widgets/jam_session_list_tile.dart';

class JamSessionsPage extends StatefulWidget {
  const JamSessionsPage({super.key});

  @override
  State<JamSessionsPage> createState() => _JamSessionsPageState();
}

class _JamSessionsPageState extends State<JamSessionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<JamSessionsCubit>().loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final sessionsCubit = context.read<JamSessionsCubit>();
          await context.push(AppRoutes.eventManagerJamSessionForm);
          if (!mounted) return;
          sessionsCubit.loadSessions();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Jam Session'),
      ),
      body: BlocBuilder<JamSessionsCubit, JamSessionsState>(
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

          final sessions = state.sessions;

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.music_note,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes jam sessions programadas.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: sessions.length + 1,
            separatorBuilder: (context, index) {
              if (index == 0) return const SizedBox.shrink();
              return const Divider();
            },
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Mis Jam Sessions',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return JamSessionListTile(session: sessions[index - 1]);
            },
          );
        },
      ),
    );
  }
}
