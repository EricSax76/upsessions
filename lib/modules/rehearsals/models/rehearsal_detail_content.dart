import 'package:flutter/material.dart';

import 'rehearsal_entity.dart';
import 'setlist_item_entity.dart';
import '../ui/widgets/rehearsal_detail/rehearsal_info_card.dart';
import '../ui/widgets/rehearsal_detail/setlist_header.dart';
import '../ui/widgets/rehearsal_detail/setlist_items_list.dart';

class RehearsalDetailContent extends StatelessWidget {
  const RehearsalDetailContent({
    super.key,
    required this.rehearsal,
    required this.setlist,
    required this.onEditRehearsal,
    this.onDeleteRehearsal,
    required this.onCopyFromLast,
    required this.onAddSong,
    required this.onEditSong,
    required this.onDeleteSong,
    required this.onReorderSetlist,
    this.onBookRoom,
    this.bookingInfo,
  });

  final RehearsalEntity rehearsal;
  final List<SetlistItemEntity> setlist;
  final VoidCallback onEditRehearsal;
  final VoidCallback? onDeleteRehearsal;
  final VoidCallback onCopyFromLast;
  final VoidCallback onAddSong;
  final ValueChanged<SetlistItemEntity> onEditSong;
  final ValueChanged<SetlistItemEntity> onDeleteSong;
  final ValueChanged<List<String>> onReorderSetlist;
  final VoidCallback? onBookRoom;
  final String? bookingInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 420
            ? 16.0
            : (constraints.maxWidth < 720 ? 20.0 : 24.0);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                40, // More top padding for breathing room
                horizontalPadding,
                88,
              ),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 56, // Larger icon container
                      width: 56,
                      decoration: BoxDecoration(
                        color: scheme.surface, // Clean background
                        shape: BoxShape.circle, // Circular shape
                        // image: DecorationImage(image: ...), // User's avatar eventually
                        border: Border.all(
                          color: scheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: ClipOval(
                        child: Icon(
                          Icons.event_note,
                          color: scheme.primary,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ensayo',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Detalles y setlist',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onDeleteRehearsal != null)
                      IconButton(
                        tooltip: 'Eliminar ensayo',
                        icon: Icon(Icons.delete_outline, color: scheme.error),
                        onPressed: onDeleteRehearsal,
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                RehearsalInfoCard(rehearsal: rehearsal, onTap: onEditRehearsal),
                const SizedBox(height: 24),
                // Booking Section
                _BookingSection(
                  hasBooking: rehearsal.bookingId != null,
                  bookingInfo: bookingInfo,
                  onBookRoom: onBookRoom,
                  scheme: scheme,
                  theme: theme,
                ),
                const SizedBox(height: 32),
                SetlistHeader(
                  count: setlist.length,
                  onAddSong: onAddSong,
                  onCopyFromLast: onCopyFromLast,
                ),
                const SizedBox(height: 16),
                SetlistItemsList(
                  setlist: setlist,
                  onEditSong: onEditSong,
                  onDeleteSong: onDeleteSong,
                  onReorderSetlist: onReorderSetlist,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookingSection extends StatelessWidget {
  const _BookingSection({
    required this.hasBooking,
    required this.bookingInfo,
    required this.onBookRoom,
    required this.scheme,
    required this.theme,
  });

  final bool hasBooking;
  final String? bookingInfo;
  final VoidCallback? onBookRoom;
  final ColorScheme scheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: hasBooking ? scheme.primary.withOpacity(0.3) : scheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasBooking
                        ? scheme.primaryContainer.withOpacity(0.5)
                        : scheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasBooking ? Icons.meeting_room : Icons.meeting_room_outlined,
                    color: hasBooking ? scheme.primary : scheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sala de Ensayo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasBooking
                            ? (bookingInfo ?? 'Sala reservada')
                            : 'Sin sala reservada',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: hasBooking
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!hasBooking && onBookRoom != null)
                  FilledButton.icon(
                    onPressed: onBookRoom,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Reservar'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  )
                else if (hasBooking)
                  Chip(
                    label: const Text('Reservada'),
                    backgroundColor: scheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide.none,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
