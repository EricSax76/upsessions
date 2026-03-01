import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../cubits/manager_agenda_cubit.dart';
import '../../cubits/manager_agenda_state.dart';

class ManagerAgendaPage extends StatefulWidget {
  const ManagerAgendaPage({super.key});

  @override
  State<ManagerAgendaPage> createState() => _ManagerAgendaPageState();
}

class _ManagerAgendaPageState extends State<ManagerAgendaPage> {
  @override
  void initState() {
    super.initState();
    context.read<ManagerAgendaCubit>().loadAgenda();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ManagerAgendaCubit, ManagerAgendaState>(
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

          final items = state.items;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes eventos ni jam sessions próximos.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Mi Agenda',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                );
              }
              final item = items[index - 1];
              final isEvent = item.type == 'Evento';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isEvent
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.tertiaryContainer,
                    child: Icon(
                      isEvent ? Icons.event : Icons.music_note,
                      color: isEvent
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${item.type} • ${_formatDate(item.date)}\n${item.city ?? ''}${item.location != null ? ' - ${item.location}' : ''}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (isEvent) {
                      context.push(AppRoutes.eventManagerEventDetailPath(item.id));
                    } else {
                      context.push(AppRoutes.eventManagerJamSessionDetailPath(item.id));
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} a las ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
