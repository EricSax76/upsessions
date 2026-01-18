import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/setlist_repository.dart';
import 'package:upsessions/core/utils/url_launcher_utils.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../cubits/rehearsal_entity.dart';
import '../cubits/setlist_item_entity.dart';
import 'rehearsal_helpers.dart';
import '../ui/widgets/rehearsal_detail_widgets.dart';

enum CopySetlistMode { replace, append }

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
  final loc = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminar item'),
      content: Text('Eliminar "${item.displayTitle}" del setlist?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(loc.cancel),
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

Future<void> copySetlistFromLastRehearsal({
  required BuildContext context,
  required RehearsalsRepository rehearsalsRepository,
  required SetlistRepository setlistRepository,
  required String groupId,
  required RehearsalEntity currentRehearsal,
  required List<SetlistItemEntity> currentSetlist,
}) async {
  final loc = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    final rehearsals = await rehearsalsRepository.getRehearsals(groupId);
    if (!context.mounted) return;
    final candidates =
        rehearsals.where((r) => r.id != currentRehearsal.id).toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    if (candidates.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No hay ensayos previos para copiar.')),
      );
      return;
    }

    RehearsalEntity source;
    final prior =
        candidates
            .where((r) => r.startsAt.isBefore(currentRehearsal.startsAt))
            .toList()
          ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
    source = prior.isNotEmpty ? prior.first : candidates.last;

    CopySetlistMode mode = CopySetlistMode.replace;
    if (currentSetlist.isNotEmpty) {
      final selected = await showDialog<CopySetlistMode>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Copiar setlist'),
          content: Text(
            'Copiar el setlist del ensayo ${formatDateTime(source.startsAt)} a este ensayo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(CopySetlistMode.append),
              child: const Text('Agregar al final'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(CopySetlistMode.replace),
              child: const Text('Reemplazar'),
            ),
          ],
        ),
      );
      if (selected == null) return;
      mode = selected;
    }

    await setlistRepository.copySetlist(
      groupId: groupId,
      fromRehearsalId: source.id,
      toRehearsalId: currentRehearsal.id,
      replaceExisting: mode == CopySetlistMode.replace,
    );

    if (!context.mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('Setlist copiado.')));
  } catch (error) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('No se pudo copiar el setlist: $error')),
    );
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
  await UrlLauncherUtils.launchSafeUrl(context, url);
}

Future<void> _copyToClipboard(BuildContext context, String value) async {
  final messenger = ScaffoldMessenger.of(context);
  await Clipboard.setData(ClipboardData(text: value));
  if (!context.mounted) return;
  messenger.showSnackBar(const SnackBar(content: Text('Enlace copiado')));
}
