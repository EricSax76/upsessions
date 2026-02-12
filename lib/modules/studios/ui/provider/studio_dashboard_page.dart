import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../cubits/studios_cubit.dart';
import '../../cubits/studios_state.dart';
import '../widgets/studio_shell_page.dart';

class StudioDashboardPage extends StatelessWidget {
  const StudioDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = locate<AuthRepository>();
    final userId = authRepo.currentUser?.id ?? 'mock_user_id';

    return BlocProvider(
      create: (context) => StudiosCubit()..loadMyStudio(userId),
      child: BlocBuilder<StudiosCubit, StudiosState>(
        builder: (context, state) {
          if (state.status == StudiosStatus.loading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          if (state.myStudio == null) {
            return StudioShellPage(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Aún no has registrado tu estudio',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu perfil de estudio para empezar a recibir reservas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () async {
                         await context.push(AppRoutes.studiosCreate);
                         if (!context.mounted) return;
                         context.read<StudiosCubit>().loadMyStudio(userId);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Registrar Estudio'),
                    ),
                  ],
                ),
              ),
            );
          }

          return StudioShellPage(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Material(
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 0,
                    child: TabBar(
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      tabs: const [
                        Tab(text: 'Mis Salas', icon: Icon(Icons.meeting_room)),
                        Tab(text: 'Reservas', icon: Icon(Icons.event)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Tab 1: Rooms
                        _buildRoomsTab(context, state, userId),
                        // Tab 2: Bookings
                        _buildBookingsTab(context, state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomsTab(BuildContext context, StudiosState state, String userId) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mis Salas', style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            )),
            FilledButton.icon(
              onPressed: () async {
                await context.push(
                  AppRoutes.studiosRoomCreatePath(state.myStudio!.id),
                );
                if (!context.mounted) return;
                context.read<StudiosCubit>().loadMyStudio(userId);
              },
              icon: const Icon(Icons.add),
              label: const Text('Añadir Sala'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (state.myRooms.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.meeting_room_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes salas registradas',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Añade tu primera sala para comenzar a recibir reservas',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...state.myRooms.map((room) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.meeting_room, color: colorScheme.primary),
              ),
              title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${room.capacity} personas • ${room.pricePerHour}€/hora'),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await context.push(
                    AppRoutes.studiosRoomEditPath(
                      studioId: state.myStudio!.id,
                      roomId: room.id,
                    ),
                  );
                  if (!context.mounted) return;
                  context.read<StudiosCubit>().loadMyStudio(userId);
                },
              ),
            ),
          )),
      ],
    );
  }

  Widget _buildBookingsTab(BuildContext context, StudiosState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.studioBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin reservas pendientes',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando recibas reservas aparecerán aquí',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: state.studioBookings.length,
      itemBuilder: (context, index) {
        final booking = state.studioBookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.calendar_today, color: colorScheme.tertiary),
            ),
            title: Text(booking.roomName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${booking.startTime.day}/${booking.startTime.month}/${booking.startTime.year} - ${booking.startTime.hour}:${booking.startTime.minute.toString().padLeft(2, '0')}'),
                Text('Total: ${booking.totalPrice}€'),
              ],
            ),
            isThreeLine: true,
            trailing: Chip(
              label: Text(
                booking.status.name,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 12,
                ),
              ),
              backgroundColor: colorScheme.primaryContainer,
              side: BorderSide.none,
            ),
          ),
        );
      },
    );
  }
}
