import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

/// Shows a simple dialog to create a new group with just a name.
/// Returns the group name if confirmed, or null if cancelled.
Future<String?> showCreateGroupDialog(BuildContext context) async {
  final loc = AppLocalizations.of(context);
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.groups_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(loc.rehearsalsSidebarCreateGroupTitle),
        ],
      ),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Nombre',
          hintText: 'Ej. Banda X',
        ),
        autofocus: true,
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: Text(loc.create),
        ),
      ],
    ),
  );
}


