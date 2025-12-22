import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../data/groups_repository.dart';

class RehearsalsGroupsPage extends StatelessWidget {
  const RehearsalsGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserShellPage(child: _RehearsalsGroupsView());
  }
}

class _RehearsalsGroupsView extends StatelessWidget {
  const _RehearsalsGroupsView();

  @override
  Widget build(BuildContext context) {
    final repository = locate<GroupsRepository>();
    return StreamBuilder(
      stream: repository.watchMyGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        final groups = snapshot.data ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Row(
              children: [
                Text(
                  'Ensayos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () =>
                      _showCreateGroupDialog(context, repository),
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Nuevo grupo'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (groups.isEmpty)
              const Text('Aún no tienes grupos de ensayos.')
            else
              ...groups.map(
                (group) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.groups_outlined),
                    title: Text(group.groupName),
                    subtitle: Text('Rol: ${group.role}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.go(AppRoutes.rehearsalsGroup(group.groupId)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showCreateGroupDialog(
    BuildContext context,
    GroupsRepository repository,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear grupo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            hintText: 'Ej. Banda X',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty) {
      return;
    }
    try {
      final groupId = await repository.createGroup(name: result);
      if (!context.mounted) return;
      context.go(AppRoutes.rehearsalsGroup(groupId));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear el grupo: $error')),
      );
    }
  }
}
