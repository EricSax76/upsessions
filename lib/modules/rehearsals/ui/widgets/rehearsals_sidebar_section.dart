import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../groups/repositories/groups_repository.dart';
import '../../../groups/ui/widgets/group_dialogs.dart';

class RehearsalsSidebarSection extends StatelessWidget {
  const RehearsalsSidebarSection({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = locate<GroupsRepository>();
    final loc = AppLocalizations.of(context);
    return StreamBuilder(
      stream: repository.watchMyGroups(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ExpansionTile(
            title: Text(loc.navRehearsals),
            leading: const Icon(Icons.event_note_outlined),
            childrenPadding: const EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: 8,
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: Text(loc.viewAll),
                onTap: () => _go(context, AppRoutes.rehearsals),
              ),
              ListTile(
                leading: const Icon(Icons.group_add_outlined),
                title: Text(loc.rehearsalsSidebarNewGroupLabel),
                onTap: () => _createGroup(context, repository),
              ),
              ListTile(
                leading: const Icon(Icons.login_outlined),
                title: Text(loc.rehearsalsGroupsGoToGroupTitle),
                onTap: () => _goToGroupById(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  loc.rehearsalsSidebarErrorLoading(
                    snapshot.error.toString(),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        }
        final groups = snapshot.data ?? const [];
        return ExpansionTile(
          title: Text(loc.navRehearsals),
          leading: const Icon(Icons.event_note_outlined),
          childrenPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          children: [
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: Text(loc.viewAll),
              onTap: () => _go(context, AppRoutes.rehearsals),
            ),
            ListTile(
              leading: const Icon(Icons.group_add_outlined),
              title: Text(loc.rehearsalsSidebarNewGroupLabel),
              onTap: () => _createGroup(context, repository),
            ),
            ListTile(
              leading: const Icon(Icons.login_outlined),
              title: Text(loc.rehearsalsGroupsGoToGroupTitle),
              onTap: () => _goToGroupById(context),
            ),
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  loc.rehearsalsSidebarEmptyPrompt,
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
                  subtitle: Text(loc.rehearsalsSidebarRoleLabel(group.role)),
                  onTap: () => _go(context, AppRoutes.groupPage(group.groupId)),
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

    final loc = AppLocalizations.of(context);
    try {
      final result = await showCreateGroupDialog(context);
      if (result == null || result.trim().isEmpty) return;
      final groupId = await repository.createGroup(name: result);
      if (!context.mounted) return;
      GoRouter.of(context).go(AppRoutes.groupPage(groupId));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.rehearsalsGroupsCreateGroupError(error.toString())),
        ),
      );
    }
  }

  Future<void> _goToGroupById(BuildContext context) async {
    final groupId = await showGoToGroupDialog(context);
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
