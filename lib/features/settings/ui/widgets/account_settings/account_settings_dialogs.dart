import 'package:flutter/material.dart';

Future<bool> showRequestAccountDeletionDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Solicitar eliminación de cuenta'),
      content: const Text(
        'Registraremos una solicitud formal de eliminación. '
        'Nuestro equipo revisará la petición y te contactará si necesita validaciones adicionales.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Solicitar'),
        ),
      ],
    ),
  );

  return confirmed == true;
}

Future<bool> showDeleteGroupDialog(
  BuildContext context, {
  required String groupName,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Eliminar grupo'),
      content: Text(
        'Se eliminará "$groupName" y su información asociada. '
        '¿Continuar?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  return confirmed == true;
}
