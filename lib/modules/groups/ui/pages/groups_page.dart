import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/layout/searchable_list_page.dart';
import '../../../../home/ui/pages/user_shell_page.dart';

import '../../models/group_membership_entity.dart';
import '../../repositories/groups_repository.dart';
import '../widgets/groups_widgets.dart';
import '../widgets/groups_list/groups_hero_section.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserShellPage(child: _GroupsView());
  }
}

class _GroupsView extends StatefulWidget {
  const _GroupsView();

  @override
  State<_GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<_GroupsView> {
  late final GroupsRepository _repository;
  late final Stream<List<GroupMembershipEntity>> _groupsStream;

  @override
  void initState() {
    super.initState();
    _repository = locate<GroupsRepository>();
    _groupsStream = _repository.watchMyGroups();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GroupMembershipEntity>>(
      stream: _groupsStream,
      builder: (context, snapshot) {
        final groups = snapshot.data ?? const <GroupMembershipEntity>[];
        final shouldShowBlockingError = snapshot.hasError && groups.isEmpty;
        return SearchableListPage<GroupMembershipEntity>(
          items: groups,
          isLoading: snapshot.connectionState == ConnectionState.waiting,
          errorMessage: shouldShowBlockingError ? '${snapshot.error}' : null,
          onRetry: () => _repository.authRepository.refreshIdToken(),
          onRefresh: () => _repository.authRepository.refreshIdToken(),
          searchEnabled: false,
          sortComparator: _compareGroups,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          gridLayout: true,
          gridSpacing: 24,
          headerBuilder: (context, total, visible) => GroupsHeroSection(
            groupCount: total,
            onCreateGroup: () => _showCreateGroupDialog(context, _repository),
          ),
          emptyBuilder: (context, isSearchEmpty) {
            if (groups.isEmpty) {
              return const GroupsEmptyState();
            }
            if (isSearchEmpty) {
              return EmptyStateCard(
                icon: Icons.search_off_outlined,
                title: 'No hay resultados',
                subtitle: 'Prueba con otro nombre o limpia la búsqueda.',
              );
            }
            return EmptyStateCard(
              icon: Icons.groups_outlined,
              title: 'No tienes grupos',
              subtitle: 'Crea uno o únete a un grupo existente',
            );
          },
          itemBuilder: (group, index) => GroupCard(
            groupId: group.groupId,
            groupName: group.groupName,
            role: group.role,
            photoUrl: group.photoUrl,
            onTap: () => context.go(AppRoutes.groupPage(group.groupId)),
          ),
          footerBuilder: (context) {
            if (!snapshot.hasError || groups.isEmpty) {
              return const SizedBox.shrink();
            }
            final textTheme = Theme.of(context).textTheme;
            final errorColor = Theme.of(context).colorScheme.error;
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Error al actualizar grupos: ${snapshot.error}',
                style: textTheme.bodySmall?.copyWith(color: errorColor),
              ),
            );
          },
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
      DialogService.showError(context, 'No se pudo crear el grupo: $error');
    }
  }
}

int _compareGroups(GroupMembershipEntity a, GroupMembershipEntity b) {
  final ap = _rolePriority(a.role);
  final bp = _rolePriority(b.role);
  if (ap != bp) return ap.compareTo(bp);
  return a.groupName.toLowerCase().compareTo(b.groupName.toLowerCase());
}

int _rolePriority(String role) {
  switch (role) {
    case 'owner':
      return 0;
    case 'admin':
      return 1;
    default:
      return 2;
  }
}
