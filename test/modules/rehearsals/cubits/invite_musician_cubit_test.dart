import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/musicians/models/musician_compliance_info.dart';
import 'package:upsessions/modules/musicians/models/musician_entity.dart';
import 'package:upsessions/modules/musicians/models/musician_professional_info.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'package:upsessions/modules/rehearsals/cubits/invite_musician_cubit.dart';
import 'package:upsessions/modules/rehearsals/cubits/invite_musician_state.dart';

class _MockMusiciansRepository extends Mock implements MusiciansRepository {}

class _MockGroupsRepository extends Mock implements GroupsRepository {}

void main() {
  late _MockMusiciansRepository musiciansRepository;
  late _MockGroupsRepository groupsRepository;

  MusicianEntity musician({
    required String id,
    required String ownerId,
    required String name,
  }) {
    return MusicianEntity(
      id: id,
      ownerId: ownerId,
      name: name,
      instrument: 'Guitarra',
      city: 'Madrid',
      styles: const ['Rock'],
      experienceYears: 5,
      compliance: MusicianComplianceInfo(updatedAt: DateTime(2026, 1, 1)),
      professional: const MusicianProfessionalInfo(),
    );
  }

  setUp(() {
    musiciansRepository = _MockMusiciansRepository();
    groupsRepository = _MockGroupsRepository();
  });

  blocTest<InviteMusicianCubit, InviteMusicianState>(
    'onQueryChanged trims query and emits loading then results',
    build: () {
      when(() => musiciansRepository.search(query: 'ana')).thenAnswer(
        (_) async => [musician(id: '1', ownerId: 'u1', name: 'Ana')],
      );

      return InviteMusicianCubit(
        groupId: 'group-1',
        musiciansRepository: musiciansRepository,
        groupsRepository: groupsRepository,
      );
    },
    act: (cubit) => cubit.onQueryChanged('  ana  '),
    expect: () => [
      isA<InviteMusicianState>()
          .having((s) => s.query, 'query', 'ana')
          .having((s) => s.isLoading, 'isLoading', true)
          .having((s) => s.results, 'results', isEmpty),
      isA<InviteMusicianState>()
          .having((s) => s.query, 'query', 'ana')
          .having((s) => s.isLoading, 'isLoading', false)
          .having((s) => s.results.length, 'results.length', 1),
    ],
    verify: (_) {
      verify(() => musiciansRepository.search(query: 'ana')).called(1);
    },
  );

  blocTest<InviteMusicianCubit, InviteMusicianState>(
    'onQueryChanged with empty query clears state and skips search',
    build: () => InviteMusicianCubit(
      groupId: 'group-1',
      musiciansRepository: musiciansRepository,
      groupsRepository: groupsRepository,
    ),
    seed: () => InviteMusicianState(
      query: 'prev',
      isLoading: true,
      results: [musician(id: '1', ownerId: 'u1', name: 'Ana')],
    ),
    act: (cubit) => cubit.onQueryChanged('   '),
    expect: () => [
      isA<InviteMusicianState>()
          .having((s) => s.query, 'query', '')
          .having((s) => s.isLoading, 'isLoading', false)
          .having((s) => s.results, 'results', isEmpty),
    ],
    verify: (_) {
      verifyNever(() => musiciansRepository.search(query: any(named: 'query')));
    },
  );

  test(
    'ignores stale search responses when a newer query finishes first',
    () async {
      final slow = Completer<List<MusicianEntity>>();
      final fast = Completer<List<MusicianEntity>>();

      when(
        () => musiciansRepository.search(query: 'a'),
      ).thenAnswer((_) => slow.future);
      when(
        () => musiciansRepository.search(query: 'ab'),
      ).thenAnswer((_) => fast.future);

      final cubit = InviteMusicianCubit(
        groupId: 'group-1',
        musiciansRepository: musiciansRepository,
        groupsRepository: groupsRepository,
      );

      final first = cubit.onQueryChanged('a');
      await Future<void>.delayed(Duration.zero);
      final second = cubit.onQueryChanged('ab');

      fast.complete([musician(id: '2', ownerId: 'u2', name: 'Abel')]);
      await second;

      slow.complete([musician(id: '1', ownerId: 'u1', name: 'Ana')]);
      await first;
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.query, 'ab');
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.results, hasLength(1));
      expect(cubit.state.results.single.id, '2');

      await cubit.close();
    },
  );

  test('invite delegates to groups repository', () async {
    when(
      () => groupsRepository.createInvite(
        groupId: 'group-1',
        targetUid: 'target-1',
      ),
    ).thenAnswer((_) async => 'invite-123');

    final cubit = InviteMusicianCubit(
      groupId: 'group-1',
      musiciansRepository: musiciansRepository,
      groupsRepository: groupsRepository,
    );

    final inviteId = await cubit.invite('target-1');

    expect(inviteId, 'invite-123');
    verify(
      () => groupsRepository.createInvite(
        groupId: 'group-1',
        targetUid: 'target-1',
      ),
    ).called(1);

    await cubit.close();
  });
}
