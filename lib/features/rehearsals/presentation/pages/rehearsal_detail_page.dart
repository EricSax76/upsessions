import 'package:flutter/material.dart';
import 'package:upsessions/features/rehearsals/data/rehearsals_repository.dart';
import 'package:upsessions/features/rehearsals/data/setlist_repository.dart';

import '../../../../core/locator/locator.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../domain/rehearsal_entity.dart';
import '../../domain/setlist_item_entity.dart';

class RehearsalDetailPage extends StatelessWidget {
  const RehearsalDetailPage({
    super.key,
    required this.groupId,
    required this.rehearsalId,
  });

  final String groupId;
  final String rehearsalId;

  @override
  Widget build(BuildContext context) {
    return UserShellPage(
      child: _RehearsalDetailView(
        groupId: groupId,
        rehearsalId: rehearsalId,
      ),
    );
  }
}

class _RehearsalDetailView extends StatelessWidget {
  const _RehearsalDetailView({
    required this.groupId,
    required this.rehearsalId,
  });

  final String groupId;
  final String rehearsalId;

  @override
  Widget build(BuildContext context) {
    final rehearsalsRepository = locate<RehearsalsRepository>();
    final setlistRepository = locate<SetlistRepository>();

    return StreamBuilder<RehearsalEntity?>(
      stream: rehearsalsRepository.watchRehearsal(
        groupId: groupId,
        rehearsalId: rehearsalId,
      ),
      builder: (context, rehearsalSnapshot) {
        if (rehearsalSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        if (rehearsalSnapshot.hasError) {
          return Center(child: Text('Error: ${rehearsalSnapshot.error}'));
        }
        final rehearsal = rehearsalSnapshot.data;
        if (rehearsal == null) {
          return const Center(child: Text('Ensayo no encontrado.'));
        }
        return StreamBuilder<List<SetlistItemEntity>>(
          stream: setlistRepository.watchSetlist(
            groupId: groupId,
            rehearsalId: rehearsalId,
          ),
          builder: (context, setlistSnapshot) {
            if (setlistSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            }
            if (setlistSnapshot.hasError) {
              return Center(child: Text('Error: ${setlistSnapshot.error}'));
            }
            final setlist = setlistSnapshot.data ?? const [];
            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 88),
                  children: [
                    Text(
                      'Ensayo',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(_formatDateTime(rehearsal.startsAt)),
                    if (rehearsal.endsAt != null) ...[
                      const SizedBox(height: 4),
                      Text('Fin: ${_formatDateTime(rehearsal.endsAt!)}'),
                    ],
                    if (rehearsal.location.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(rehearsal.location)),
                        ],
                      ),
                    ],
                    if (rehearsal.notes.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Notas',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(rehearsal.notes),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          'Setlist',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        Text('${setlist.length} items'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (setlist.isEmpty)
                      const Text('Aún no hay canciones. Agrega la primera.')
                    else
                      ...setlist.map(
                        (item) => Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 14,
                              child: Text(item.order.toString()),
                            ),
                            title: Text(item.displayTitle),
                            subtitle: _subtitleFor(item),
                            trailing: IconButton(
                              tooltip: 'Eliminar',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDeleteItem(
                                context,
                                setlistRepository,
                                item,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: FloatingActionButton.extended(
                    onPressed: () =>
                        _addSetlistItem(context, setlistRepository, setlist),
                    icon: const Icon(Icons.playlist_add),
                    label: const Text('Agregar canción'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addSetlistItem(
    BuildContext context,
    SetlistRepository repository,
    List<SetlistItemEntity> current,
  ) async {
    final nextOrder = (current.isEmpty ? 0 : current.last.order) + 1;
    final draft = await showDialog<_SetlistDraft>(
      context: context,
      builder: (context) => _SetlistItemDialog(initialOrder: nextOrder),
    );
    if (draft == null) return;
    try {
      await repository.addSetlistItem(
        groupId: groupId,
        rehearsalId: rehearsalId,
        order: draft.order,
        songTitle: draft.songTitle,
        keySignature: draft.keySignature,
        tempoBpm: draft.tempoBpm,
        notes: draft.notes,
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo agregar: $error')),
      );
    }
  }

  Future<void> _confirmDeleteItem(
    BuildContext context,
    SetlistRepository repository,
    SetlistItemEntity item,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar item'),
        content: Text('Eliminar "${item.displayTitle}" del setlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await repository.deleteSetlistItem(
        groupId: groupId,
        rehearsalId: rehearsalId,
        itemId: item.id,
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $error')),
      );
    }
  }

  static Widget? _subtitleFor(SetlistItemEntity item) {
    final parts = <String>[];
    if (item.keySignature.trim().isNotEmpty) {
      parts.add('Tono: ${item.keySignature}');
    }
    if (item.tempoBpm != null) parts.add('Tempo: ${item.tempoBpm} bpm');
    if (item.notes.trim().isNotEmpty) parts.add(item.notes.trim());
    if (parts.isEmpty) return null;
    return Text(parts.join(' • '));
  }

  static String _formatDateTime(DateTime value) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${value.day}/${value.month}/${value.year} ${two(value.hour)}:${two(value.minute)}';
  }
}

class _SetlistDraft {
  const _SetlistDraft({
    required this.order,
    required this.songTitle,
    required this.keySignature,
    required this.tempoBpm,
    required this.notes,
  });

  final int order;
  final String songTitle;
  final String keySignature;
  final int? tempoBpm;
  final String notes;
}

class _SetlistItemDialog extends StatefulWidget {
  const _SetlistItemDialog({required this.initialOrder});

  final int initialOrder;

  @override
  State<_SetlistItemDialog> createState() => _SetlistItemDialogState();
}

class _SetlistItemDialogState extends State<_SetlistItemDialog> {
  late final TextEditingController _title;
  late final TextEditingController _key;
  late final TextEditingController _tempo;
  late final TextEditingController _notes;
  late final TextEditingController _order;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _key = TextEditingController();
    _tempo = TextEditingController();
    _notes = TextEditingController();
    _order = TextEditingController(text: widget.initialOrder.toString());
  }

  @override
  void dispose() {
    _title.dispose();
    _key.dispose();
    _tempo.dispose();
    _notes.dispose();
    _order.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar canción'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: 'Canción',
                hintText: 'Ej. Autumn Leaves',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _key,
                    decoration: const InputDecoration(labelText: 'Tono'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _tempo,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tempo (bpm)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _order,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Orden'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notas'),
              minLines: 2,
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final order =
                int.tryParse(_order.text.trim()) ?? widget.initialOrder;
            Navigator.of(context).pop(
              _SetlistDraft(
                order: order,
                songTitle: _title.text.trim(),
                keySignature: _key.text.trim(),
                tempoBpm: int.tryParse(_tempo.text.trim()),
                notes: _notes.text.trim(),
              ),
            );
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
