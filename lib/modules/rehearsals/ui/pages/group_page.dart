import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../repositories/groups_repository.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return UserShellPage(child: _GroupView(groupId: groupId));
  }
}

class _GroupView extends StatelessWidget {
  const _GroupView({required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    final groupsRepository = locate<GroupsRepository>();
    return StreamBuilder<String>(
      stream: groupsRepository.watchGroupName(groupId),
      builder: (context, groupNameSnapshot) {
        final groupName = groupNameSnapshot.data ?? 'Grupo';
        return StreamBuilder<String?>(
          stream: groupsRepository.watchMyRole(groupId),
          builder: (context, roleSnapshot) {
            final role = roleSnapshot.data ?? '';
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                Text(
                  groupName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  role.isEmpty ? 'Mi grupo' : 'Rol: $role',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.event_available_outlined),
                    title: const Text('Ensayos'),
                    subtitle: const Text('Ver todos los ensayos del grupo'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go(
                      AppRoutes.rehearsalsGroupRehearsals(groupId),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
