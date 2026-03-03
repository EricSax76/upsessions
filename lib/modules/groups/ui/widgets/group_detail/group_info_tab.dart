import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/locator/locator.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/gap.dart';
import '../../../../../core/widgets/section_title.dart';
import '../../../cubits/group_members_cubit.dart';
import '../../../models/group_dtos.dart';
import '../../../repositories/groups_repository.dart';
import 'members_list.dart';

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
    final theme = Theme.of(context);

    // Links: prioriza el nuevo Map, fallback a los strings legacy
    final allLinks = group.links.isNotEmpty
        ? group.links
        : {
            if (group.link1.isNotEmpty) 'Enlace 1': group.link1,
            if (group.link2.isNotEmpty) 'Enlace 2': group.link2,
          };

    // Géneros: prioriza genres List, fallback a genre String
    final displayGenres = group.genres.isNotEmpty
        ? group.genres
        : (group.genre.isNotEmpty ? [group.genre] : <String>[]);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ── Descripción ──────────────────────────────────────────
        if (group.description.isNotEmpty) ...[
          const SectionTitle(text: 'Sobre el grupo'),
          const VSpace(8),
          Text(group.description, style: theme.textTheme.bodyMedium),
          const VSpace(24),
        ],

        // ── Géneros ───────────────────────────────────────────────
        if (displayGenres.isNotEmpty) ...[
          const SectionTitle(text: 'Géneros'),
          const VSpace(8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: displayGenres.map((g) => Chip(label: Text(g))).toList(),
          ),
          const VSpace(24),
        ],

        // ── Ciudad ────────────────────────────────────────────────
        if (group.city != null && group.city!.isNotEmpty) ...[
          InfoTile(
            icon: Icons.location_on_outlined,
            label: [group.city, group.province]
                .whereType<String>()
                .where((s) => s.isNotEmpty)
                .join(', '),
          ),
          const VSpace(24),
        ],

        // ── SGAE ──────────────────────────────────────────────────
        if (group.sgaeGroupCode != null &&
            group.sgaeGroupCode!.isNotEmpty) ...[
          InfoTile(
            icon: Icons.music_note_outlined,
            label: 'SGAE: ${group.sgaeGroupCode}',
          ),
          const VSpace(24),
        ],

        // ── Links ─────────────────────────────────────────────────
        if (allLinks.isNotEmpty) ...[
          const SectionTitle(text: 'Enlaces y Redes'),
          const VSpace(12),
          for (final entry in allLinks.entries)
            InfoTile(icon: Icons.link, label: entry.value),
          const VSpace(24),
        ],

        // ── Miembros ──────────────────────────────────────────────
        const _CenteredSectionTitle(text: 'Miembros'),
        const VSpace(12),
        const MembersList(),
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
