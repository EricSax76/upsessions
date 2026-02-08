import 'package:flutter/material.dart';
import '../../../utils/rehearsal_date_utils.dart';
import '../../../models/rehearsal_entity.dart';
import '../../../models/setlist_item_entity.dart';

import 'rehearsal_detail_web_table.dart';

class RehearsalDetailWebLayout extends StatelessWidget {
  const RehearsalDetailWebLayout({
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
    this.bookingRoomName,
    this.bookingAddress,
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
  final String? bookingRoomName;
  final String? bookingAddress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final scheme = Theme.of(context).colorScheme;
        final listPadding = isWide
            ? const EdgeInsets.symmetric(horizontal: 40, vertical: 32)
            : const EdgeInsets.fromLTRB(16, 24, 16, 112);

        return Scaffold(
          backgroundColor: scheme.surface,
          body: SafeArea(
            child: isWide
                ? Padding(
                    padding: listPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 32),
                        Expanded(child: _buildWideContent(context)),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: listPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 24),
                        _buildSidePanel(context),
                        const SizedBox(height: 24),
                        _buildSetlistSection(context, expands: false),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildWideContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 3, child: _buildSetlistSection(context)),
        const SizedBox(width: 32),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(child: _buildSidePanel(context)),
        ),
      ],
    );
  }

  Widget _buildSidePanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLogisticsCard(context),
        const SizedBox(height: 24),
        _buildBookingCard(context),
        if (rehearsal.notes.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildNotesCard(context),
        ],
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final useCompactActions = constraints.maxWidth < 640;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.event_note, color: scheme.primary, size: 32),
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
                  Text(
                    formatDateTime(rehearsal.startsAt),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (useCompactActions) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: onEditRehearsal,
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Editar'),
                        ),
                        if (onDeleteRehearsal != null)
                          IconButton(
                            onPressed: onDeleteRehearsal,
                            icon: Icon(
                              Icons.delete_outline,
                              color: scheme.error,
                            ),
                            tooltip: 'Eliminar ensayo',
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!useCompactActions) ...[
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: onEditRehearsal,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
              ),
              if (onDeleteRehearsal != null) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: onDeleteRehearsal,
                  icon: Icon(Icons.delete_outline, color: scheme.error),
                  tooltip: 'Eliminar ensayo',
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildSetlistSection(BuildContext context, {bool expands = true}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final setlistBody = setlist.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(48),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.queue_music,
                    size: 48,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay canciones en el setlist',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        : SetlistWebTable(
            setlist: setlist,
            onEditSong: onEditSong,
            onDeleteSong: onDeleteSong,
            onReorderSetlist: onReorderSetlist,
          );

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Toolbar
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSetlistToolbar(context, theme),
          ),
          const Divider(height: 1),
          if (expands) Expanded(child: setlistBody) else setlistBody,
        ],
      ),
    );
  }

  Widget _buildSetlistToolbar(BuildContext context, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useShortLabels = constraints.maxWidth < 500;
        final useStackedToolbar = constraints.maxWidth < 640;

        if (useStackedToolbar) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Setlist (${setlist.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (setlist.isEmpty)
                    TextButton.icon(
                      onPressed: onCopyFromLast,
                      icon: const Icon(Icons.copy_all, size: 18),
                      label: Text(
                        useShortLabels ? 'Copiar' : 'Copiar del anterior',
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: onAddSong,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(useShortLabels ? 'Agregar' : 'Agregar canción'),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Text(
              'Setlist (${setlist.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (setlist.isEmpty)
              TextButton.icon(
                onPressed: onCopyFromLast,
                icon: const Icon(Icons.copy_all, size: 18),
                label: Text(useShortLabels ? 'Copiar' : 'Copiar del anterior'),
              ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onAddSong,
              icon: const Icon(Icons.add, size: 18),
              label: Text(useShortLabels ? 'Agregar' : 'Agregar canción'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogisticsCard(BuildContext context) {
    return InfoSection(
      title: 'Detalles',
      icon: Icons.info_outline,
      children: [
        InfoRow(
          label: 'Inicio',
          value: formatDateTime(rehearsal.startsAt),
          icon: Icons.calendar_today,
        ),
        if (rehearsal.endsAt != null)
          InfoRow(
            label: 'Fin',
            value: formatDateTime(rehearsal.endsAt!),
            icon: Icons.event_busy,
          ),
        if (rehearsal.location.isNotEmpty)
          InfoRow(
            label: 'Ubicación',
            value: rehearsal.location,
            icon: Icons.place,
          ),
      ],
    );
  }

  Widget _buildBookingCard(BuildContext context) {
    final hasBooking = rehearsal.bookingId != null;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InfoSection(
      title: 'Sala de Ensayo',
      icon: hasBooking ? Icons.meeting_room : Icons.meeting_room_outlined,
      action: !hasBooking && onBookRoom != null
          ? TextButton(onPressed: onBookRoom, child: const Text('Reservar'))
          : null,
      children: [
        if (!hasBooking)
          Text(
            'No hay sala reservada',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bookingRoomName != null && bookingRoomName!.isNotEmpty)
                Text(
                  bookingRoomName!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              if (bookingAddress != null && bookingAddress!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    bookingAddress!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Chip(
                label: const Text('Confirmada'),
                backgroundColor: scheme.primaryContainer,
                labelStyle: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                side: BorderSide.none,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InfoSection(
      title: 'Notas',
      icon: Icons.notes,
      children: [
        Text(
          rehearsal.notes,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
} // class InfoSection and InfoRow are assumed to be in reusable widgets
