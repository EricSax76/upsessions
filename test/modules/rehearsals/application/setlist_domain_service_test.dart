import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/rehearsals/application/setlist_domain_service.dart';
import 'package:upsessions/modules/rehearsals/models/rehearsal_entity.dart';
import 'package:upsessions/modules/rehearsals/models/setlist_item_entity.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/setlist_repository.dart';

class MockRehearsalsRepository extends Mock implements RehearsalsRepository {}

class MockSetlistRepository extends Mock implements SetlistRepository {}

void main() {
  late MockRehearsalsRepository rehearsalsRepository;
  late MockSetlistRepository setlistRepository;
  late SetlistDomainService service;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    rehearsalsRepository = MockRehearsalsRepository();
    setlistRepository = MockSetlistRepository();
    service = SetlistDomainService(
      rehearsalsRepository: rehearsalsRepository,
      setlistRepository: setlistRepository,
    );
  });

  test('nextOrder returns last order plus one', () {
    final current = [
      _item(id: 'a', order: 0),
      _item(id: 'b', order: 1),
      _item(id: 'c', order: 2),
    ];

    expect(service.nextOrder(current), 3);
    expect(service.nextOrder(const []), 1);
  });

  test('addSetlistItem persists and uploads sheet when provided', () async {
    when(
      () => setlistRepository.addSetlistItem(
        groupId: 'g1',
        rehearsalId: 'r1',
        order: 3,
        songTitle: 'Song',
        keySignature: 'C',
        tempoBpm: 120,
        notes: 'notes',
        linkUrl: 'https://song',
      ),
    ).thenAnswer((_) async => 'item-1');
    when(
      () => setlistRepository.uploadSetlistSheet(
        groupId: 'g1',
        rehearsalId: 'r1',
        itemId: 'item-1',
        bytes: any(named: 'bytes'),
        fileExtension: 'png',
      ),
    ).thenAnswer((_) async => 'url');

    await service.addSetlistItem(
      groupId: 'g1',
      rehearsalId: 'r1',
      input: SetlistItemInput(
        order: 3,
        songTitle: 'Song',
        keySignature: 'C',
        tempoBpm: 120,
        notes: 'notes',
        linkUrl: 'https://song',
        sheetBytes: Uint8List.fromList([1, 2, 3]),
        sheetFileExtension: 'png',
      ),
    );

    verify(
      () => setlistRepository.addSetlistItem(
        groupId: 'g1',
        rehearsalId: 'r1',
        order: 3,
        songTitle: 'Song',
        keySignature: 'C',
        tempoBpm: 120,
        notes: 'notes',
        linkUrl: 'https://song',
      ),
    ).called(1);
    verify(
      () => setlistRepository.uploadSetlistSheet(
        groupId: 'g1',
        rehearsalId: 'r1',
        itemId: 'item-1',
        bytes: any(named: 'bytes'),
        fileExtension: 'png',
      ),
    ).called(1);
  });

  test('editSetlistItem updates, clears and uploads sheet', () async {
    final existing = _item(id: 'item-1', order: 3, sheetPath: 'old/path');

    when(
      () => setlistRepository.updateSetlistItem(
        groupId: 'g1',
        rehearsalId: 'r1',
        itemId: 'item-1',
        order: 4,
        songTitle: 'Edited',
        keySignature: 'Dm',
        tempoBpm: 110,
        notes: 'edited notes',
        linkUrl: 'https://edited',
      ),
    ).thenAnswer((_) async {});
    when(
      () => setlistRepository.clearSetlistSheet(
        groupId: 'g1',
        rehearsalId: 'r1',
        itemId: 'item-1',
        sheetPath: 'old/path',
      ),
    ).thenAnswer((_) async {});
    when(
      () => setlistRepository.uploadSetlistSheet(
        groupId: 'g1',
        rehearsalId: 'r1',
        itemId: 'item-1',
        bytes: any(named: 'bytes'),
        fileExtension: 'jpg',
      ),
    ).thenAnswer((_) async => 'url');

    await service.editSetlistItem(
      groupId: 'g1',
      rehearsalId: 'r1',
      item: existing,
      input: SetlistItemInput(
        order: 4,
        songTitle: 'Edited',
        keySignature: 'Dm',
        tempoBpm: 110,
        notes: 'edited notes',
        linkUrl: 'https://edited',
        removeSheet: true,
        sheetBytes: Uint8List.fromList([9, 8, 7]),
        sheetFileExtension: 'jpg',
      ),
    );

    verify(
      () => setlistRepository.updateSetlistItem(
        groupId: 'g1',
        rehearsalId: 'r1',
        itemId: 'item-1',
        order: 4,
        songTitle: 'Edited',
        keySignature: 'Dm',
        tempoBpm: 110,
        notes: 'edited notes',
        linkUrl: 'https://edited',
      ),
    ).called(1);
    verify(
      () => setlistRepository.clearSetlistSheet(
        groupId: 'g1',
        rehearsalId: 'r1',
        itemId: 'item-1',
        sheetPath: 'old/path',
      ),
    ).called(1);
    verify(
      () => setlistRepository.uploadSetlistSheet(
        groupId: 'g1',
        rehearsalId: 'r1',
        itemId: 'item-1',
        bytes: any(named: 'bytes'),
        fileExtension: 'jpg',
      ),
    ).called(1);
  });

  test('resolveCopySource returns most recent prior rehearsal', () async {
    final current = _rehearsal(id: 'current', startsAt: DateTime(2026, 1, 10));
    final old1 = _rehearsal(id: 'old1', startsAt: DateTime(2026, 1, 5));
    final old2 = _rehearsal(id: 'old2', startsAt: DateTime(2026, 1, 8));
    final future = _rehearsal(id: 'future', startsAt: DateTime(2026, 1, 20));

    when(
      () => rehearsalsRepository.getRehearsals('g1'),
    ).thenAnswer((_) async => [current, old1, old2, future]);

    final source = await service.resolveCopySource(
      groupId: 'g1',
      currentRehearsal: current,
    );

    expect(source?.id, 'old2');
  });

  test(
    'resolveCopySource falls back to latest candidate when no prior',
    () async {
      final current = _rehearsal(
        id: 'current',
        startsAt: DateTime(2026, 1, 10),
      );
      final next1 = _rehearsal(id: 'next1', startsAt: DateTime(2026, 1, 11));
      final next2 = _rehearsal(id: 'next2', startsAt: DateTime(2026, 1, 12));

      when(
        () => rehearsalsRepository.getRehearsals('g1'),
      ).thenAnswer((_) async => [current, next1, next2]);

      final source = await service.resolveCopySource(
        groupId: 'g1',
        currentRehearsal: current,
      );

      expect(source?.id, 'next2');
    },
  );

  test('copySetlist maps append mode to replaceExisting false', () async {
    when(
      () => setlistRepository.copySetlist(
        groupId: 'g1',
        fromRehearsalId: 'source',
        toRehearsalId: 'target',
        replaceExisting: false,
      ),
    ).thenAnswer((_) async {});

    await service.copySetlist(
      groupId: 'g1',
      sourceRehearsalId: 'source',
      targetRehearsalId: 'target',
      mode: SetlistCopyMode.append,
    );

    verify(
      () => setlistRepository.copySetlist(
        groupId: 'g1',
        fromRehearsalId: 'source',
        toRehearsalId: 'target',
        replaceExisting: false,
      ),
    ).called(1);
  });
}

SetlistItemEntity _item({
  required String id,
  required int order,
  String sheetPath = '',
}) {
  return SetlistItemEntity(
    id: id,
    order: order,
    songId: null,
    songTitle: 'Song',
    keySignature: '',
    tempoBpm: null,
    notes: '',
    linkUrl: '',
    sheetUrl: '',
    sheetPath: sheetPath,
  );
}

RehearsalEntity _rehearsal({required String id, required DateTime startsAt}) {
  return RehearsalEntity(
    id: id,
    groupId: 'g1',
    startsAt: startsAt,
    endsAt: null,
    location: '',
    notes: '',
    createdBy: 'u1',
  );
}
