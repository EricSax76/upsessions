import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/core/constants/app_link_scheme.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/musicians/cubits/invite_to_group_cubit.dart';

class _MockGroupsRepository extends Mock implements GroupsRepository {}

void main() {
  late _MockGroupsRepository groupsRepository;

  setUp(() {
    groupsRepository = _MockGroupsRepository();
  });

  group('InviteToGroupCubit', () {
    blocTest<InviteToGroupCubit, InviteToGroupState>(
      'emite error inmediato con parámetros inválidos',
      build: () => InviteToGroupCubit(groupsRepository: groupsRepository),
      act: (cubit) => cubit.createInvite(groupId: 'group-1', targetUid: ' '),
      expect: () => [
        const InviteToGroupError('Datos de invitación inválidos.'),
      ],
      verify: (_) {
        verifyNever(
          () => groupsRepository.createInvite(
            groupId: any(named: 'groupId'),
            targetUid: any(named: 'targetUid'),
          ),
        );
      },
    );

    blocTest<InviteToGroupCubit, InviteToGroupState>(
      'emite loading y success cuando createInvite responde',
      build: () {
        when(
          () => groupsRepository.createInvite(
            groupId: 'group-1',
            targetUid: 'target-uid',
          ),
        ).thenAnswer((_) async => 'invite-123');
        return InviteToGroupCubit(groupsRepository: groupsRepository);
      },
      act: (cubit) =>
          cubit.createInvite(groupId: 'group-1', targetUid: 'target-uid'),
      expect: () => [
        const InviteToGroupLoading(),
        InviteToGroupSuccess(
          invitePath: AppRoutes.invitePath(
            groupId: 'group-1',
            inviteId: 'invite-123',
          ),
          link:
              '$appLinkScheme://${AppRoutes.invitePath(groupId: 'group-1', inviteId: 'invite-123')}',
        ),
      ],
    );

    blocTest<InviteToGroupCubit, InviteToGroupState>(
      'emite loading y error cuando createInvite falla',
      build: () {
        when(
          () => groupsRepository.createInvite(
            groupId: any(named: 'groupId'),
            targetUid: any(named: 'targetUid'),
          ),
        ).thenThrow(Exception('permission-denied'));
        return InviteToGroupCubit(groupsRepository: groupsRepository);
      },
      act: (cubit) =>
          cubit.createInvite(groupId: 'group-1', targetUid: 'target-uid'),
      expect: () => [
        const InviteToGroupLoading(),
        isA<InviteToGroupError>().having(
          (state) => state.message,
          'message',
          contains('No se pudo crear la invitación'),
        ),
      ],
    );

    blocTest<InviteToGroupCubit, InviteToGroupState>(
      'reset vuelve al estado inicial',
      build: () => InviteToGroupCubit(groupsRepository: groupsRepository),
      seed: () => const InviteToGroupError('fallo'),
      act: (cubit) => cubit.reset(),
      expect: () => [const InviteToGroupInitial()],
    );
  });
}
