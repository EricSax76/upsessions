import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../cubits/rehearsal_entity.dart';
import '../repositories/rehearsals_repository.dart';
// Wait, this might cause circular import
import '../controllers/rehearsal_dialog.dart';

Future<void> confirmDeleteRehearsal({
  required BuildContext context,
  required RehearsalsRepository repository,
  required String groupId,
  required String rehearsalId,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Eliminar ensayo'),
      content: const Text(
        'Se eliminar\u00e1 el ensayo y su setlist. \u00bfContinuar?',
      ),
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

  if (confirmed != true) return;

  try {
    await repository.deleteRehearsal(
      groupId: groupId,
      rehearsalId: rehearsalId,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ensayo eliminado.')));
    context.go(AppRoutes.rehearsalsGroupRehearsals(groupId));
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo eliminar el ensayo: $error')),
    );
  }
}

Future<void> editRehearsal({
  required BuildContext context,
  required RehearsalsRepository repository,
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
    await repository.updateRehearsal(
      groupId: groupId,
      rehearsalId: rehearsal.id,
      startsAt: draft.startsAt,
      endsAt: draft.endsAt,
      location: draft.location,
      notes: draft.notes,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ensayo actualizado.')));
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo actualizar el ensayo: $error')),
    );
  }
}
