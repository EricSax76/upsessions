import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/gap.dart';
import '../../../../../core/widgets/section_title.dart';
import '../../../../../core/widgets/sm_avatar.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../../core/constants/app_routes.dart';
import '../../../../../core/locator/locator.dart';
import '../../../../auth/cubits/auth_cubit.dart';
import '../../../cubits/group_members_cubit.dart';
import '../../../cubits/group_members_state.dart';
import '../../../models/group_dtos.dart';
import '../../../models/group_member.dart';
import '../../../repositories/groups_repository.dart';

class GroupInfoTab extends StatelessWidget {
  const GroupInfoTab({super.key, required this.group});

  final GroupDoc group;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupMembersCubit(groupId: group.id),
      child: _GroupInfoContent(group: group),
    );
  }
}

class _GroupInfoContent extends StatelessWidget {
  const _GroupInfoContent({required this.group});

  final GroupDoc group;

  @override
  Widget build(BuildContext context) {
    final userId = context.select((AuthCubit cubit) => cubit.state.user?.id);
    final isOwner = userId != null && userId == group.ownerId;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (group.link1.isNotEmpty || group.link2.isNotEmpty) ...[
          const SectionTitle(text: 'Enlaces y Redes'),
          const VSpace(12),
          if (group.link1.isNotEmpty)
            InfoTile(icon: Icons.link, label: group.link1),
          if (group.link2.isNotEmpty)
            InfoTile(icon: Icons.link, label: group.link2),
          const VSpace(24),
        ],
        const SectionTitle(text: 'Miembros'),
        const VSpace(12),
        const _MembersList(),
        const VSpace(24),
        const SectionTitle(text: 'Configuración'),
        const VSpace(12),
        InfoTile(
          icon: Icons.admin_panel_settings_outlined,
          label: 'ID del grupo: ${group.id}',
        ),
        if (isOwner) ...[
          const VSpace(24),
          const SectionTitle(text: 'Acciones'),
          const VSpace(12),
          AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(0),
            child: ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Eliminar grupo',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
              subtitle: const Text('Esta acci\u00f3n no se puede deshacer.'),
              onTap: () => _confirmDeleteGroup(context, group.id),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmDeleteGroup(BuildContext context, String groupId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar grupo'),
        content: const Text(
          'Se eliminar\u00e1 el grupo y su informaci\u00f3n asociada. \u00bfContinuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final repository = locate<GroupsRepository>();
    try {
      await repository.deleteGroup(groupId: groupId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Grupo eliminado.')),
      );
      context.go(AppRoutes.rehearsals);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el grupo: $error')),
      );
    }
  }
}

class _MembersList extends StatelessWidget {
  const _MembersList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupMembersCubit, GroupMembersState>(
      builder: (context, state) {
        if (state is GroupMembersLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: LoadingIndicator()),
          );
        }
        if (state is GroupMembersError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is GroupMembersLoaded) {
          if (state.members.isEmpty) {
            return const Center(child: Text('No hay miembros en este grupo.'));
          }
          return Column(
            children: state.members.map((member) => _MemberTile(member: member)).toList(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final GroupMember member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ListTile(
        leading: SmAvatar(
          radius: 20,
          imageUrl: member.photoUrl,
          initials: member.name.isNotEmpty ? member.name.substring(0, 1) : '?',
        ),
        title: Text(member.name, style: theme.textTheme.bodyMedium),
        subtitle: Text(
          _formatSubtitle(member),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: _buildRoleBadge(context, member.role),
      ),
    );
  }

  String _formatSubtitle(GroupMember member) {
    if (member.instrument != null && member.instrument!.isNotEmpty) {
      return member.instrument!;
    }
    return 'Músico';
  }

  Widget? _buildRoleBadge(BuildContext context, String role) {
    if (role == 'owner') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Admin',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      );
    }
    return null;
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(0),
      child: ListTile(
        leading: Icon(icon, size: 20),
        title: Text(label, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
