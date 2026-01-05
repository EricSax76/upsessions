import 'package:flutter/material.dart';

class RehearsalsGroupsActions extends StatelessWidget {
  const RehearsalsGroupsActions({
    super.key,
    required this.onGoToGroup,
    required this.onCreateGroup,
  });

  final VoidCallback onGoToGroup;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        OutlinedButton.icon(
          onPressed: onGoToGroup,
          icon: const Icon(Icons.login_outlined),
          label: const Text('Ir a un grupo'),
        ),
        FilledButton.icon(
          onPressed: onCreateGroup,
          icon: const Icon(Icons.group_add_outlined),
          label: const Text('Nuevo grupo'),
        ),
      ],
    );
  }
}
