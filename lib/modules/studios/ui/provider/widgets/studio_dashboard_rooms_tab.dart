import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../cubits/studios_state.dart';
import '../../widgets/empty_states/no_rooms_empty_state.dart';

class StudioDashboardRoomsTab extends StatelessWidget {
  const StudioDashboardRoomsTab({
    super.key,
    required this.state,
    required this.onCreateRoom,
    required this.onEditRoom,
  });

  final StudiosState state;
  final Future<void> Function() onCreateRoom;
  final Future<void> Function(String roomId) onEditRoom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.studioDashboardRoomsTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            FilledButton.icon(
              onPressed: onCreateRoom,
              icon: const Icon(Icons.add),
              label: Text(loc.studioDashboardAddRoom),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (state.myRooms.isEmpty)
          const NoRoomsEmptyState()
        else
          ...state.myRooms.map(
            (room) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.meeting_room, color: colorScheme.primary),
                ),
                title: Text(
                  room.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  loc.studioDashboardRoomSummary(
                    room.capacity.toString(),
                    room.pricePerHour.toStringAsFixed(0),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => onEditRoom(room.id),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
