import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/locator/locator.dart';
import '../../../groups/models/group_membership_entity.dart';
import '../../../groups/repositories/groups_repository.dart';
import '../../../groups/ui/widgets/group_dialogs.dart';

class RehearsalsSidebarSection extends StatefulWidget {
  const RehearsalsSidebarSection({super.key});

  @override
  State<RehearsalsSidebarSection> createState() =>
      _RehearsalsSidebarSectionState();
}

class _RehearsalsSidebarSectionState extends State<RehearsalsSidebarSection> {
  late final GroupsRepository _repository;
  late final Stream<List<GroupMembershipEntity>> _groupsStream;

  @override
  void initState() {
    super.initState();
    _repository = locate<GroupsRepository>();
    _groupsStream = _repository.watchMyGroups();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return StreamBuilder<List<GroupMembershipEntity>>(
      stream: _groupsStream,
      builder: (context, snapshot) {
        final groups = snapshot.data ?? const <GroupMembershipEntity>[];
        if (snapshot.hasError) {
          if (groups.isNotEmpty) {
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
                  onTap: () => _createGroup(context, _repository),
                ),
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
                    onTap: () =>
                        _go(context, AppRoutes.groupPage(group.groupId)),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    loc.rehearsalsSidebarErrorLoading(
                      snapshot.error.toString(),
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            );
          }
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
                onTap: () => _createGroup(context, _repository),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  loc.rehearsalsSidebarErrorLoading(snapshot.error.toString()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        }
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
              onTap: () => _createGroup(context, _repository),
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
      DialogService.showError(
        context,
        loc.rehearsalsGroupsCreateGroupError(error.toString()),
      );
    }
  }

  void _go(BuildContext context, String route) {
    final scaffoldState = Scaffold.maybeOf(context);
    scaffoldState?.closeDrawer();
    GoRouter.of(context).go(route);
  }
}
