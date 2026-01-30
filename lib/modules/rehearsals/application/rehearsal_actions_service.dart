import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/dialog_service.dart';
import '../models/rehearsal_entity.dart';
import '../repositories/rehearsals_repository.dart';
import '../controllers/rehearsal_dialog.dart';

class RehearsalActionsService {
  RehearsalActionsService({required RehearsalsRepository repository})
      : _repository = repository;

  final RehearsalsRepository _repository;

  Future<void> confirmDeleteRehearsal({
    required BuildContext context,
    required String groupId,
    required String rehearsalId,
  }) async {
    final loc = AppLocalizations.of(context);
    final confirmed = await DialogService.showConfirmation(
      context: context,
      title: 'Eliminar ensayo',
      message: 'Se eliminará el ensayo y su setlist. ¿Continuar?',
      confirmText: 'Eliminar',
      cancelText: loc.cancel,
      isDangerous: true,
    );

    if (!confirmed) return;

    try {
      await _repository.deleteRehearsal(
        groupId: groupId,
        rehearsalId: rehearsalId,
      );
      if (!context.mounted) return;
      DialogService.showSuccess(context, 'Ensayo eliminado.');
      context.go(AppRoutes.rehearsalsGroupRehearsals(groupId));
    } catch (error) {
      if (!context.mounted) return;
      DialogService.showError(
        context,
        'No se pudo eliminar el ensayo: $error',
      );
    }
  }

  Future<void> editRehearsal({
    required BuildContext context,
    required String groupId,
    required RehearsalEntity rehearsal,
  }) async {
    final draft = await showDialog<RehearsalDraft?>(
      context: context,
      builder: (context) => RehearsalDialog(
        initial: RehearsalDraft(
          startsAt: rehearsal.startsAt,
          endsAt: rehearsal.endsAt,
          location: rehearsal.location,
          notes: rehearsal.notes,
        ),
        title: 'Editar ensayo',
        submitLabel: 'Guardar',
      ),
    );
    if (draft == null) return;

    try {
      await _repository.updateRehearsal(
        groupId: groupId,
        rehearsalId: rehearsal.id,
        startsAt: draft.startsAt,
        endsAt: draft.endsAt,
        location: draft.location,
        notes: draft.notes,
      );
      if (!context.mounted) return;
      DialogService.showSuccess(context, 'Ensayo actualizado.');
    } catch (error) {
      if (!context.mounted) return;
      DialogService.showError(
        context,
        'No se pudo actualizar el ensayo: $error',
      );
    }
  }
}
