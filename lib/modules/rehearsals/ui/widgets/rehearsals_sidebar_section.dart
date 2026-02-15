import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/dialog_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../modules/groups/cubits/my_groups_cubit.dart';
import '../../../../modules/groups/cubits/my_groups_state.dart';
// import '../../../../core/locator/locator.dart'; // Removed
import '../../../groups/models/group_membership_entity.dart';
import '../../../groups/models/create_group_draft.dart';
// import '../../../groups/repositories/groups_repository.dart'; // Removed
import '../../../groups/ui/dialogs/create_group_dialog.dart';

class RehearsalsSidebarSection extends StatelessWidget {
  const RehearsalsSidebarSection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BlocBuilder<MyGroupsCubit, MyGroupsState>(
      builder: (context, state) {
        // Default values
        var groups = <GroupMembershipEntity>[];
        String? error;
        
        if (state is MyGroupsLoaded) {
          groups = state.groups;
        } else if (state is MyGroupsError) {
          error = state.message;
          // Subtly we might want to show cached groups if available, but for now strict state
        }
        
        final hasError = state is MyGroupsError;

        if (hasError) {
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
                  onTap: () => _createGroup(context),
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
                      error.toString(),
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
                onTap: () => _createGroup(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  loc.rehearsalsSidebarErrorLoading(error.toString()),
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
              onTap: () => _createGroup(context),
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
  ) async {
    final scaffoldState = Scaffold.maybeOf(context);
    scaffoldState?.closeDrawer();

    final loc = AppLocalizations.of(context);
    try {
      final result = await showDialog<CreateGroupDraft>(
        context: context,
        builder: (context) => const CreateGroupDialog(),
      );
      if (result == null || result.name.trim().isEmpty) return;
      if (!context.mounted) return;
      
      final cubit = context.read<MyGroupsCubit>();
      final groupId = await cubit.createGroup(
        name: result.name,
        genre: result.genre,
        link1: result.link1,
        link2: result.link2,
        photoBytes: result.photoBytes,
        photoFileExtension: result.photoFileExtension,
      );
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
