import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../data/groups_repository.dart';
import '../widgets/rehearsals_groups_widgets.dart';

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
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final groups = snapshot.data ?? const [];
        return ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            const RehearsalsGroupsHeader(),
            const SizedBox(height: 16),
            RehearsalsGroupsActions(
              onGoToGroup: () => _showGoToGroupDialog(context),
              onCreateGroup: () => _showCreateGroupDialog(context, repository),
            ),
            const SizedBox(height: 20),
            if (groups.isEmpty)
              const RehearsalsGroupsEmptyState()
            else
              ...groups.map(
                (group) => GroupCard(
                  groupName: group.groupName,
                  role: group.role,
                  onTap: () => context.go(AppRoutes.groupPage(group.groupId)),
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
    final result = await showDialog<CreateGroupDraft>(
      context: context,
      builder: (context) => const CreateGroupDialog(),
    );
    if (result == null || result.name.trim().isEmpty) {
      return;
    }
    try {
      final groupId = await repository.createGroup(
        name: result.name,
        genre: result.genre,
        link1: result.link1,
        link2: result.link2,
        photoBytes: result.photoBytes,
        photoFileExtension: result.photoFileExtension,
      );
      if (!context.mounted) return;
      context.go(AppRoutes.groupPage(groupId));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear el grupo: $error')),
      );
    }
  }

  Future<void> _showGoToGroupDialog(BuildContext context) async {
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
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Ir'),
          ),
        ],
      ),
    );
    if (groupId == null || groupId.trim().isEmpty) return;
    if (!context.mounted) return;
    context.go(AppRoutes.groupPage(groupId.trim()));
  }
}
