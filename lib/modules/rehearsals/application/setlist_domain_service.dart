import 'dart:typed_data';

import '../models/rehearsal_entity.dart';
import '../models/setlist_item_entity.dart';
import '../repositories/rehearsals_repository.dart';
import '../repositories/setlist_repository.dart';

enum SetlistCopyMode { replace, append }

class SetlistItemInput {
  const SetlistItemInput({
    required this.order,
    required this.songTitle,
    required this.keySignature,
    required this.tempoBpm,
    required this.notes,
    required this.linkUrl,
    this.sheetBytes,
    this.sheetFileExtension,
    this.removeSheet = false,
  });

  final int order;
  final String songTitle;
  final String keySignature;
  final int? tempoBpm;
  final String notes;
  final String linkUrl;
  final Uint8List? sheetBytes;
  final String? sheetFileExtension;
  final bool removeSheet;
}

class SetlistDomainService {
  SetlistDomainService({
    required RehearsalsRepository rehearsalsRepository,
    required SetlistRepository setlistRepository,
  }) : _rehearsalsRepository = rehearsalsRepository,
       _setlistRepository = setlistRepository;

  final RehearsalsRepository _rehearsalsRepository;
  final SetlistRepository _setlistRepository;

  int nextOrder(List<SetlistItemEntity> current) {
    return (current.isEmpty ? 0 : current.last.order) + 1;
  }

  Future<void> addSetlistItem({
    required String groupId,
    required String rehearsalId,
    required SetlistItemInput input,
  }) async {
    final itemId = await _setlistRepository.addSetlistItem(
      groupId: groupId,
      rehearsalId: rehearsalId,
      order: input.order,
      songTitle: input.songTitle,
      keySignature: input.keySignature,
      tempoBpm: input.tempoBpm,
      notes: input.notes,
      linkUrl: input.linkUrl,
    );
    final sheetBytes = input.sheetBytes;
    if (sheetBytes != null && sheetBytes.isNotEmpty) {
      await _setlistRepository.uploadSetlistSheet(
        groupId: groupId,
        rehearsalId: rehearsalId,
        itemId: itemId,
        bytes: sheetBytes,
        fileExtension: input.sheetFileExtension,
      );
    }
  }

  Future<void> editSetlistItem({
    required String groupId,
    required String rehearsalId,
    required SetlistItemEntity item,
    required SetlistItemInput input,
  }) async {
    await _setlistRepository.updateSetlistItem(
      groupId: groupId,
      rehearsalId: rehearsalId,
      itemId: item.id,
      order: input.order,
      songTitle: input.songTitle,
      keySignature: input.keySignature,
      tempoBpm: input.tempoBpm,
      notes: input.notes,
      linkUrl: input.linkUrl,
    );

    if (input.removeSheet) {
      await _setlistRepository.clearSetlistSheet(
        groupId: groupId,
        rehearsalId: rehearsalId,
        itemId: item.id,
        sheetPath: item.sheetPath,
      );
    }

    final sheetBytes = input.sheetBytes;
    if (sheetBytes != null && sheetBytes.isNotEmpty) {
      await _setlistRepository.uploadSetlistSheet(
        groupId: groupId,
        rehearsalId: rehearsalId,
        itemId: item.id,
        bytes: sheetBytes,
        fileExtension: input.sheetFileExtension,
      );
    }
  }

  Future<void> deleteSetlistItem({
    required String groupId,
    required String rehearsalId,
    required String itemId,
  }) {
    return _setlistRepository.deleteSetlistItem(
      groupId: groupId,
      rehearsalId: rehearsalId,
      itemId: itemId,
    );
  }

  Future<RehearsalEntity?> resolveCopySource({
    required String groupId,
    required RehearsalEntity currentRehearsal,
  }) async {
    final rehearsals = await _rehearsalsRepository.getRehearsals(groupId);
    final candidates =
        rehearsals.where((r) => r.id != currentRehearsal.id).toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    if (candidates.isEmpty) {
      return null;
    }

    final prior =
        candidates
            .where((r) => r.startsAt.isBefore(currentRehearsal.startsAt))
            .toList()
          ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
    return prior.isNotEmpty ? prior.first : candidates.last;
  }

  Future<void> copySetlist({
    required String groupId,
    required String sourceRehearsalId,
    required String targetRehearsalId,
    required SetlistCopyMode mode,
  }) {
    return _setlistRepository.copySetlist(
      groupId: groupId,
      fromRehearsalId: sourceRehearsalId,
      toRehearsalId: targetRehearsalId,
      replaceExisting: mode == SetlistCopyMode.replace,
    );
  }
}
