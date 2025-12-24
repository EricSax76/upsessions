import 'package:flutter/material.dart';
import 'package:upsessions/features/rehearsals/data/setlist_repository.dart';

import '../../../domain/setlist_item_entity.dart';
import '../../widgets/rehearsal_detail_widgets.dart';

Future<void> addSetlistItem({
  required BuildContext context,
  required SetlistRepository repository,
  required String groupId,
  required String rehearsalId,
  required List<SetlistItemEntity> current,
}) async {
  final nextOrder = (current.isEmpty ? 0 : current.last.order) + 1;
  final draft = await showDialog<SetlistDraft>(
    context: context,
    builder: (context) => SetlistItemDialog(initialOrder: nextOrder),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('No se pudo agregar: $error')));
  }
}

Future<void> confirmDeleteSetlistItem({
  required BuildContext context,
  required SetlistRepository repository,
  required String groupId,
  required String rehearsalId,
  required SetlistItemEntity item,
}) async {
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('No se pudo eliminar: $error')));
  }
}

Widget? setlistSubtitleFor(SetlistItemEntity item) {
  final parts = <String>[];
  if (item.keySignature.trim().isNotEmpty) {
    parts.add('Tono: ${item.keySignature}');
  }
  if (item.tempoBpm != null) parts.add('Tempo: ${item.tempoBpm} bpm');
  if (item.notes.trim().isNotEmpty) parts.add(item.notes.trim());
  if (parts.isEmpty) return null;
  return Text(parts.join(' • '));
}
