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

Future<bool> showRequestPrivacyRightDialog(
  BuildContext context, {
  required String rightTitle,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(rightTitle),
      content: const Text(
        'Registraremos una solicitud formal para su revisión. '
        'El equipo de privacidad puede solicitar información adicional para verificar tu identidad.',
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

Future<String?> showUpdatePrivacyRequestStatusDialog(
  BuildContext context, {
  required String requestTypeLabel,
  required String currentStatusLabel,
  required String nextStatusLabel,
}) async {
  final reasonController = TextEditingController();
  final reason = await showDialog<String?>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Cambiar a "$nextStatusLabel"'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Solicitud: $requestTypeLabel'),
          const SizedBox(height: 4),
          Text('Estado actual: $currentStatusLabel'),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            maxLines: 4,
            minLines: 2,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Motivo interno (opcional)',
              hintText: 'Contexto para trazabilidad de la decisión.',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(null),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(reasonController.text.trim()),
          child: const Text('Actualizar estado'),
        ),
      ],
    ),
  );
  reasonController.dispose();
  return reason;
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
