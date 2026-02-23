import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../core/services/dialog_service.dart';
import '../models/rehearsal_entity.dart';
import '../models/setlist_item_entity.dart';
import '../utils/rehearsal_date_utils.dart';
import '../ui/pages/setlist_item_dialog.dart';
import 'setlist_domain_service.dart';

class SetlistActionsService {
  SetlistActionsService({required SetlistDomainService domainService})
    : _domainService = domainService;

  final SetlistDomainService _domainService;

  Future<void> addSetlistItem({
    required BuildContext context,
    required String groupId,
    required String rehearsalId,
    required List<SetlistItemEntity> current,
  }) async {
    final nextOrder = _domainService.nextOrder(current);
    final draft = await showDialog<SetlistDraft>(
      context: context,
      builder: (context) => SetlistItemDialog(initialOrder: nextOrder),
    );
    if (draft == null) return;
    try {
      await _domainService.addSetlistItem(
        groupId: groupId,
        rehearsalId: rehearsalId,
        input: _toInput(draft),
      );
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
      await _domainService.editSetlistItem(
        groupId: groupId,
        rehearsalId: rehearsalId,
        item: item,
        input: _toInput(draft),
      );
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
      await _domainService.deleteSetlistItem(
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
      final source = await _domainService.resolveCopySource(
        groupId: groupId,
        currentRehearsal: currentRehearsal,
      );
      if (!context.mounted) return;
      if (source == null) {
        DialogService.showError(context, 'No hay ensayos previos para copiar.');
        return;
      }

      var mode = SetlistCopyMode.replace;
      if (currentSetlist.isNotEmpty) {
        final selected = await showDialog<SetlistCopyMode>(
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
                    Navigator.of(context).pop(SetlistCopyMode.append),
                child: const Text('Agregar al final'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(SetlistCopyMode.replace),
                child: const Text('Reemplazar'),
              ),
            ],
          ),
        );
        if (selected == null) return;
        mode = selected;
      }

      await _domainService.copySetlist(
        groupId: groupId,
        sourceRehearsalId: source.id,
        targetRehearsalId: currentRehearsal.id,
        mode: mode,
      );

      if (!context.mounted) return;
      DialogService.showSuccess(context, 'Setlist copiado.');
    } catch (error) {
      if (!context.mounted) return;
      DialogService.showError(context, 'No se pudo copiar el setlist: $error');
    }
  }

  SetlistItemInput _toInput(SetlistDraft draft) {
    return SetlistItemInput(
      order: draft.order,
      songTitle: draft.songTitle,
      keySignature: draft.keySignature,
      tempoBpm: draft.tempoBpm,
      notes: draft.notes,
      linkUrl: draft.linkUrl,
      sheetBytes: draft.sheetBytes,
      sheetFileExtension: draft.sheetFileExtension,
      removeSheet: draft.removeSheet,
    );
  }
}
