import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../features/rehearsals/data/groups_repository.dart';

class RehearsalsSidebarSection extends StatelessWidget {
  const RehearsalsSidebarSection({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = locate<GroupsRepository>();
    return StreamBuilder(
      stream: repository.watchMyGroups(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ExpansionTile(
            title: const Text('Ensayos'),
            leading: const Icon(Icons.event_note_outlined),
            childrenPadding: const EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 8,
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: const Text('Ver todos'),
                onTap: () => _go(context, AppRoutes.rehearsals),
              ),
              ListTile(
                leading: const Icon(Icons.group_add_outlined),
                title: const Text('Nuevo grupo'),
                onTap: () => _createGroup(context, repository),
              ),
              ListTile(
                leading: const Icon(Icons.login_outlined),
                title: const Text('Ir a un grupo'),
                onTap: () => _goToGroupById(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  'Error cargando grupos: ${snapshot.error}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        }
        final groups = snapshot.data ?? const [];
        return ExpansionTile(
          title: const Text('Ensayos'),
          leading: const Icon(Icons.event_note_outlined),
          childrenPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          children: [
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: const Text('Ver todos'),
              onTap: () => _go(context, AppRoutes.rehearsals),
            ),
            ListTile(
              leading: const Icon(Icons.group_add_outlined),
              title: const Text('Nuevo grupo'),
              onTap: () => _createGroup(context, repository),
            ),
            ListTile(
              leading: const Icon(Icons.login_outlined),
              title: const Text('Ir a un grupo'),
              onTap: () => _goToGroupById(context),
            ),
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  'Crea un grupo para empezar.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              for (final group in groups)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.groups_outlined),
                  title: Text(
                    group.groupName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('Rol: ${group.role}'),
                  onTap: () =>
                      _go(context, AppRoutes.groupPage(group.groupId)),
                ),
          ],
        );
      },
    );
  }

  Future<void> _createGroup(
    BuildContext context,
    GroupsRepository repository,
  ) async {
    final scaffoldState = Scaffold.maybeOf(context);
    scaffoldState?.closeDrawer();

    final controller = TextEditingController();
    try {
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
      if (result == null || result.trim().isEmpty) return;
      final groupId = await repository.createGroup(name: result);
      if (!context.mounted) return;
      GoRouter.of(context).go(AppRoutes.groupPage(groupId));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear el grupo: $error')),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _goToGroupById(BuildContext context) async {
    final controller = TextEditingController();
    final groupId = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ir a un grupo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'ID del grupo',
            hintText: 'Ej. 6qDBI5b0LnybgBSF5KHU',
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
            child: const Text('Ir'),
          ),
        ],
      ),
    );
    if (groupId == null || groupId.trim().isEmpty) return;
    if (!context.mounted) return;
    _go(context, AppRoutes.groupPage(groupId.trim()));
  }

  void _go(BuildContext context, String route) {
    final scaffoldState = Scaffold.maybeOf(context);
    scaffoldState?.closeDrawer();
    GoRouter.of(context).go(route);
  }
}
