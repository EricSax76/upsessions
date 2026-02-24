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
      create:
          (_) => GroupMembersCubit(
            groupId: group.id,
            groupsRepository: locate<GroupsRepository>(),
          ),
      child: _GroupInfoContent(group: group),
    );
  }
}

class _GroupInfoContent extends StatelessWidget {
  const _GroupInfoContent({required this.group});

  final GroupDoc group;

  @override
  Widget build(BuildContext context) {
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
        const _CenteredSectionTitle(text: 'Miembros'),
        const VSpace(12),
        const _MembersList(),
      ],
    );
  }
}

class _CenteredSectionTitle extends StatelessWidget {
  const _CenteredSectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
    );
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
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width < 440 ? 3 : width < 760 ? 4 : 6;
              const horizontalSpacing = 12.0;
              final tileWidth =
                  (width - (horizontalSpacing * (crossAxisCount - 1))) /
                  crossAxisCount;

              return Wrap(
                alignment: WrapAlignment.center,
                spacing: horizontalSpacing,
                runSpacing: 18,
                children: state.members
                    .map(
                      (member) => SizedBox(
                        width: tileWidth,
                        child: _MemberAvatarTile(member: member),
                      ),
                    )
                    .toList(),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _MemberAvatarTile extends StatelessWidget {
  const _MemberAvatarTile({required this.member});

  final GroupMember member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final initials = _initials(member.name);
    final isOwner = member.role == 'owner';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _openMusicianDetail(context),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: SmAvatar(
                  radius: 34,
                  imageUrl: member.photoUrl,
                  initials: initials,
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
              ),
              if (isOwner)
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                      border: Border.all(color: colorScheme.surface, width: 1.5),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 12,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          member.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _initials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _openMusicianDetail(BuildContext context) {
    final musicianId = member.id.trim();
    if (musicianId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el perfil del músico.')),
      );
      return;
    }

    context.push(
      AppRoutes.musicianDetailPath(
        musicianId: musicianId,
        musicianName: member.name,
      ),
    );
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
