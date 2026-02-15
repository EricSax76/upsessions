import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/my_groups_cubit.dart';
import '../../cubits/my_groups_state.dart';
import '../../../../core/constants/app_routes.dart';
// import '../../../../core/locator/locator.dart'; // Removed
import '../../../../core/services/dialog_service.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/layout/searchable_list_page.dart';
import '../../../../home/ui/pages/user_shell_page.dart';

import '../../models/group_membership_entity.dart';
import '../../../../modules/groups/repositories/groups_repository.dart';
import '../../../../features/messaging/repositories/chat_repository.dart';
import '../../../../features/notifications/repositories/invite_notifications_repository.dart';
import '../../../../features/contacts/cubits/liked_musicians_cubit.dart';
import '../widgets/groups_widgets.dart';
import '../widgets/groups_list/groups_hero_section.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({
    super.key,
    required this.groupsRepository,
    required this.chatRepository,
    required this.inviteNotificationsRepository,
    required this.likedMusiciansCubit,
  });

  final GroupsRepository groupsRepository;
  final ChatRepository chatRepository;
  final InviteNotificationsRepository inviteNotificationsRepository;
  final LikedMusiciansCubit likedMusiciansCubit;

  @override
  Widget build(BuildContext context) {
    return UserShellPage(
      groupsRepository: groupsRepository,
      chatRepository: chatRepository,
      inviteNotificationsRepository: inviteNotificationsRepository,
      likedMusiciansCubit: likedMusiciansCubit,
      child: const _GroupsView(),
    );
  }
}

class _GroupsView extends StatelessWidget {
  const _GroupsView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyGroupsCubit, MyGroupsState>(
      builder: (context, state) {
        // Default to empty list if not loaded yet
        final groups = state is MyGroupsLoaded ? state.groups : const <GroupMembershipEntity>[];
        final isLoading = state is MyGroupsLoading;
        final error = state is MyGroupsError ? state.message : null;
        
        return SearchableListPage<GroupMembershipEntity>(
          items: groups,
          isLoading: isLoading,
          errorMessage: error,
          // onRetry/onRefresh logic might need adjustment if we want to force re-fetch in Cubit, 
          // but for now the stream in Cubit should auto-update.
          // We can leave them empty or trigger a refresh method if we add one to Cubit.
          onRetry: () {}, 
          onRefresh: () async {},
          searchEnabled: false,
          sortComparator: _compareGroups,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          gridLayout: true,
          gridSpacing: 24,
          headerBuilder: (context, total, visible) => GroupsHeroSection(
            groupCount: total,
            onCreateGroup: () => _showCreateGroupDialog(context),
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
             if (error == null || groups.isEmpty) {
              return const SizedBox.shrink();
            }
            final textTheme = Theme.of(context).textTheme;
            final errorColor = Theme.of(context).colorScheme.error;
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Error al actualizar grupos: $error',
                style: textTheme.bodySmall?.copyWith(color: errorColor),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateGroupDialog(BuildContext context) async {
    final result = await showDialog<CreateGroupDraft>(
      context: context,
      builder: (context) => const CreateGroupDialog(),
    );
    if (result == null || result.name.trim().isEmpty) {
      return;
    }
    
    // Check if mounted before using context
    if (!context.mounted) return;

    try {
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
