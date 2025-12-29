import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upsessions/modules/rehearsals/data/setlist_repository.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final itemId = await repository.addSetlistItem(
      groupId: groupId,
      rehearsalId: rehearsalId,
      order: draft.order,
      songTitle: draft.songTitle,
      keySignature: draft.keySignature,
      tempoBpm: draft.tempoBpm,
      notes: draft.notes,
      linkUrl: draft.linkUrl,
    );
    final sheetBytes = draft.sheetBytes;
    if (sheetBytes != null && sheetBytes.isNotEmpty) {
      await repository.uploadSetlistSheet(
        groupId: groupId,
        rehearsalId: rehearsalId,
        itemId: itemId,
        bytes: sheetBytes,
        fileExtension: draft.sheetFileExtension,
      );
    }
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('No se pudo agregar: $error')));
  }
}

Future<void> editSetlistItem({
  required BuildContext context,
  required SetlistRepository repository,
  required String groupId,
  required String rehearsalId,
  required SetlistItemEntity item,
}) async {
  final draft = await showDialog<SetlistDraft>(
    context: context,
    builder: (context) => SetlistItemDialog(
      initialOrder: item.order,
      dialogTitle: 'Editar canción',
      submitLabel: 'Guardar',
      initialTitle: item.songTitle ?? '',
      initialKeySignature: item.keySignature,
      initialTempoBpm: item.tempoBpm,
      initialNotes: item.notes,
      initialLinkUrl: item.linkUrl,
      initialSheetUrl: item.sheetUrl,
    ),
  );
  if (draft == null) return;
  try {
    await repository.updateSetlistItem(
      groupId: groupId,
      rehearsalId: rehearsalId,
      itemId: item.id,
      order: draft.order,
      songTitle: draft.songTitle,
      keySignature: draft.keySignature,
      tempoBpm: draft.tempoBpm,
      notes: draft.notes,
      linkUrl: draft.linkUrl,
    );

    if (draft.removeSheet) {
      await repository.clearSetlistSheet(
        groupId: groupId,
        rehearsalId: rehearsalId,
        itemId: item.id,
        sheetPath: item.sheetPath,
      );
    }

    final sheetBytes = draft.sheetBytes;
    if (sheetBytes != null && sheetBytes.isNotEmpty) {
      await repository.uploadSetlistSheet(
        groupId: groupId,
        rehearsalId: rehearsalId,
        itemId: item.id,
        bytes: sheetBytes,
        fileExtension: draft.sheetFileExtension,
      );
    }
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('No se pudo actualizar: $error')));
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

Widget? setlistSubtitleFor(BuildContext context, SetlistItemEntity item) {
  final keySignature = item.keySignature.trim();
  final notes = item.notes.trim();
  final linkUrl = item.linkUrl.trim();
  final sheetUrl = item.sheetUrl.trim();

  final chips = <Widget>[];
  if (keySignature.isNotEmpty) {
    chips.add(Text('Tono: $keySignature'));
  }
  if (item.tempoBpm != null) {
    chips.add(Text('Tempo: ${item.tempoBpm} bpm'));
  }
  if (sheetUrl.isNotEmpty) {
    chips.add(
      InputChip(
        avatar: const Icon(Icons.description_outlined, size: 18),
        label: const Text('Partitura'),
        onPressed: () => _openExternalUrl(context, sheetUrl),
      ),
    );
  }
  if (linkUrl.isNotEmpty) {
    chips.add(
      InputChip(
        avatar: const Icon(Icons.link, size: 18),
        label: Text(_linkLabel(linkUrl)),
        onPressed: () => _openExternalUrl(context, linkUrl),
        onDeleted: () => _copyToClipboard(context, linkUrl),
        deleteIcon: const Icon(Icons.copy, size: 18),
        deleteButtonTooltipMessage: 'Copiar enlace',
      ),
    );
  }

  if (chips.isEmpty && notes.isEmpty) return null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (chips.isNotEmpty)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: chips,
        ),
      if (notes.isNotEmpty) ...[
        if (chips.isNotEmpty) const SizedBox(height: 6),
        Text(notes, maxLines: 2, overflow: TextOverflow.ellipsis),
      ],
    ],
  );
}

String _linkLabel(String url) {
  try {
    final uri = Uri.parse(url.trim());
    if (uri.host.trim().isNotEmpty) return uri.host;
  } catch (_) {}
  return 'Enlace';
}

Future<void> _openExternalUrl(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final trimmed = url.trim();
  if (trimmed.isEmpty) return;
  final uri = Uri.tryParse(trimmed);
  if (uri == null) {
    messenger.showSnackBar(const SnackBar(content: Text('Enlace inválido')));
    return;
  }
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      messenger.showSnackBar(const SnackBar(content: Text('No se pudo abrir')));
    }
  } catch (_) {
    if (!context.mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('No se pudo abrir')));
  }
}

Future<void> _copyToClipboard(BuildContext context, String value) async {
  final messenger = ScaffoldMessenger.of(context);
  await Clipboard.setData(ClipboardData(text: value));
  if (!context.mounted) return;
  messenger.showSnackBar(const SnackBar(content: Text('Enlace copiado')));
}
