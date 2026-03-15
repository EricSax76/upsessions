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
    final loc = AppLocalizations.of(context);
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
      DialogService.showError(context, loc.setlistAddError(error.toString()));
    }
  }

  Future<void> editSetlistItem({
    required BuildContext context,
    required String groupId,
    required String rehearsalId,
    required SetlistItemEntity item,
  }) async {
    final loc = AppLocalizations.of(context);
    final draft = await showDialog<SetlistDraft>(
      context: context,
      builder: (context) => SetlistItemDialog(
        initialOrder: item.order,
        dialogTitle: loc.setlistEditSongTitle,
        submitLabel: loc.saveAction,
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
      DialogService.showError(
        context,
        loc.setlistUpdateError(error.toString()),
      );
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
      title: loc.setlistDeleteItemTitle,
      message: loc.setlistDeleteItemMessage(item.displayTitle),
      confirmText: loc.deleteAction,
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
      DialogService.showError(
        context,
        loc.setlistDeleteError(error.toString()),
      );
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
        DialogService.showError(context, loc.setlistCopyNoPrevious);
        return;
      }

      var mode = SetlistCopyMode.replace;
      if (currentSetlist.isNotEmpty) {
        final selected = await showDialog<SetlistCopyMode>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(loc.setlistCopyDialogTitle),
            content: Text(
              loc.setlistCopyDialogMessage(formatDateTime(source.startsAt)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(loc.cancel),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(SetlistCopyMode.append),
                child: Text(loc.setlistCopyAppendAction),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(context).pop(SetlistCopyMode.replace),
                child: Text(loc.setlistCopyReplaceAction),
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
      DialogService.showSuccess(context, loc.setlistCopySuccess);
    } catch (error) {
      if (!context.mounted) return;
      DialogService.showError(context, loc.setlistCopyError(error.toString()));
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
