import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../core/services/dialog_service.dart';
import '../models/rehearsal_entity.dart';
import '../models/setlist_item_entity.dart';
import '../repositories/rehearsals_repository.dart';
import '../repositories/setlist_repository.dart';
import '../utils/rehearsal_date_utils.dart';
import '../ui/pages/setlist_item_dialog.dart';

enum CopySetlistMode { replace, append }

class SetlistActionsService {
  SetlistActionsService({
    required RehearsalsRepository rehearsalsRepository,
    required SetlistRepository setlistRepository,
  })  : _rehearsalsRepository = rehearsalsRepository,
        _setlistRepository = setlistRepository;

  final RehearsalsRepository _rehearsalsRepository;
  final SetlistRepository _setlistRepository;

  Future<void> addSetlistItem({
    required BuildContext context,
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
      final itemId = await _setlistRepository.addSetlistItem(
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
        await _setlistRepository.uploadSetlistSheet(
          groupId: groupId,
          rehearsalId: rehearsalId,
          itemId: itemId,
          bytes: sheetBytes,
          fileExtension: draft.sheetFileExtension,
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      DialogService.showError(context, 'No se pudo agregar: $error');
    }
  }

  Future<void> editSetlistItem({
    required BuildContext context,
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
      await _setlistRepository.updateSetlistItem(
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
        await _setlistRepository.clearSetlistSheet(
          groupId: groupId,
          rehearsalId: rehearsalId,
          itemId: item.id,
          sheetPath: item.sheetPath,
        );
      }

      final sheetBytes = draft.sheetBytes;
      if (sheetBytes != null && sheetBytes.isNotEmpty) {
        await _setlistRepository.uploadSetlistSheet(
          groupId: groupId,
          rehearsalId: rehearsalId,
          itemId: item.id,
          bytes: sheetBytes,
          fileExtension: draft.sheetFileExtension,
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      DialogService.showError(context, 'No se pudo actualizar: $error');
    }
  }

  Future<void> confirmDeleteSetlistItem({
    required BuildContext context,
    required String groupId,
    required String rehearsalId,
    required SetlistItemEntity item,
  }) async {
    final loc = AppLocalizations.of(context);
    final ok = await DialogService.showConfirmation(
      context: context,
      title: 'Eliminar item',
      message: 'Eliminar "${item.displayTitle}" del setlist?',
      confirmText: 'Eliminar',
      cancelText: loc.cancel,
      isDangerous: true,
    );
    if (!ok) return;
    try {
      await _setlistRepository.deleteSetlistItem(
        groupId: groupId,
        rehearsalId: rehearsalId,
        itemId: item.id,
      );
    } catch (error) {
      if (!context.mounted) return;
      DialogService.showError(context, 'No se pudo eliminar: $error');
    }
  }

  Future<void> copySetlistFromLastRehearsal({
    required BuildContext context,
    required String groupId,
    required RehearsalEntity currentRehearsal,
    required List<SetlistItemEntity> currentSetlist,
  }) async {
    final loc = AppLocalizations.of(context);
    try {
      final rehearsals = await _rehearsalsRepository.getRehearsals(groupId);
      if (!context.mounted) return;
      final candidates =
          rehearsals.where((r) => r.id != currentRehearsal.id).toList()
            ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

      if (candidates.isEmpty) {
        DialogService.showError(
          context,
          'No hay ensayos previos para copiar.',
        );
        return;
      }

      final prior =
          candidates
              .where((r) => r.startsAt.isBefore(currentRehearsal.startsAt))
              .toList()
            ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
      final source = prior.isNotEmpty ? prior.first : candidates.last;

      var mode = CopySetlistMode.replace;
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

      await _setlistRepository.copySetlist(
        groupId: groupId,
        fromRehearsalId: source.id,
        toRehearsalId: currentRehearsal.id,
        replaceExisting: mode == CopySetlistMode.replace,
      );

      if (!context.mounted) return;
      DialogService.showSuccess(context, 'Setlist copiado.');
    } catch (error) {
      if (!context.mounted) return;
      DialogService.showError(
        context,
        'No se pudo copiar el setlist: $error',
      );
    }
  }
}
