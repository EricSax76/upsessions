import 'package:flutter/material.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/setlist_repository.dart';

import '../../../../core/locator/locator.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/rehearsal_entity.dart';
import '../../domain/setlist_item_entity.dart';
import 'rehearsal_detail_widgets.dart';
import 'setlist_actions.dart';

class RehearsalDetailView extends StatelessWidget {
  const RehearsalDetailView({
    super.key,
    required this.groupId,
    required this.rehearsalId,
    this.rehearsalsRepository,
    this.setlistRepository,
  });

  final String groupId;
  final String rehearsalId;
  final RehearsalsRepository? rehearsalsRepository;
  final SetlistRepository? setlistRepository;

  @override
  Widget build(BuildContext context) {
    final rehearsalsRepository =
        this.rehearsalsRepository ?? locate<RehearsalsRepository>();
    final setlistRepository =
        this.setlistRepository ?? locate<SetlistRepository>();

    return StreamBuilder<RehearsalEntity?>(
      stream: rehearsalsRepository.watchRehearsal(
        groupId: groupId,
        rehearsalId: rehearsalId,
      ),
      builder: (context, rehearsalSnapshot) {
        if (rehearsalSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        if (rehearsalSnapshot.hasError) {
          return Center(child: Text('Error: ${rehearsalSnapshot.error}'));
        }
        final rehearsal = rehearsalSnapshot.data;
        if (rehearsal == null) {
          return const Center(child: Text('Ensayo no encontrado.'));
        }

        return StreamBuilder<List<SetlistItemEntity>>(
          stream: setlistRepository.watchSetlist(
            groupId: groupId,
            rehearsalId: rehearsalId,
          ),
          builder: (context, setlistSnapshot) {
            if (setlistSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingIndicator();
            }
            if (setlistSnapshot.hasError) {
              return Center(child: Text('Error: ${setlistSnapshot.error}'));
            }
            final setlist = setlistSnapshot.data ?? const [];
            return _RehearsalDetailContent(
              rehearsal: rehearsal,
              setlist: setlist,
              onAddSong: () => addSetlistItem(
                context: context,
                repository: setlistRepository,
                groupId: groupId,
                rehearsalId: rehearsalId,
                current: setlist,
              ),
              onEditSong: (item) => editSetlistItem(
                context: context,
                repository: setlistRepository,
                groupId: groupId,
                rehearsalId: rehearsalId,
                item: item,
              ),
              onDeleteSong: (item) => confirmDeleteSetlistItem(
                context: context,
                repository: setlistRepository,
                groupId: groupId,
                rehearsalId: rehearsalId,
                item: item,
              ),
            );
          },
        );
      },
    );
  }
}

class _RehearsalDetailContent extends StatelessWidget {
  const _RehearsalDetailContent({
    required this.rehearsal,
    required this.setlist,
    required this.onAddSong,
    required this.onEditSong,
    required this.onDeleteSong,
  });

  final RehearsalEntity rehearsal;
  final List<SetlistItemEntity> setlist;
  final VoidCallback onAddSong;
  final ValueChanged<SetlistItemEntity> onEditSong;
  final ValueChanged<SetlistItemEntity> onDeleteSong;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 88),
      children: [
        Text('Ensayo', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        RehearsalInfoCard(rehearsal: rehearsal),
        const SizedBox(height: 20),
        SetlistHeader(count: setlist.length, onAddSong: onAddSong),
        const SizedBox(height: 12),
        _SetlistItems(
          setlist: setlist,
          onEditSong: onEditSong,
          onDeleteSong: onDeleteSong,
        ),
      ],
    );
  }
}

class _SetlistItems extends StatelessWidget {
  const _SetlistItems({
    required this.setlist,
    required this.onEditSong,
    required this.onDeleteSong,
  });

  final List<SetlistItemEntity> setlist;
  final ValueChanged<SetlistItemEntity> onEditSong;
  final ValueChanged<SetlistItemEntity> onDeleteSong;

  @override
  Widget build(BuildContext context) {
    if (setlist.isEmpty) {
      return const Text('Aun no hay canciones. Agrega la primera.');
    }
    return Column(
      children: [
        for (final item in setlist)
          SetlistItemCard(
            item: item,
            subtitle: setlistSubtitleFor(context, item),
            onTap: () => onEditSong(item),
            onDelete: () => onDeleteSong(item),
          ),
      ],
    );
  }
}
