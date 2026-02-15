import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/groups/cubits/group_members_cubit.dart';
import 'package:upsessions/modules/groups/cubits/group_members_state.dart';
import 'package:upsessions/modules/groups/models/group_member.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';

class MockGroupsRepository extends Mock implements GroupsRepository {}

void main() {
  late MockGroupsRepository mockGroupsRepository;
  const groupId = 'test-group-id';

  setUp(() {
    mockGroupsRepository = MockGroupsRepository();
  });

  group('GroupMembersCubit', () {
    final tMembers = [
      const GroupMember(
        id: '1',
        name: 'User 1',
        role: 'admin',
        status: 'active',
      ),
    ];

    test('initial state is GroupMembersLoading', () {
      when(() => mockGroupsRepository.watchGroupMembers(groupId))
          .thenAnswer((_) => Stream.value([]));
      final cubit = GroupMembersCubit(
        groupId: groupId,
        groupsRepository: mockGroupsRepository,
      );
      expect(cubit.state, isA<GroupMembersLoading>());
      cubit.close();
    });

    blocTest<GroupMembersCubit, GroupMembersState>(
      'emits [GroupMembersLoaded] when subscription events arrive',
      build: () {
        when(() => mockGroupsRepository.watchGroupMembers(groupId))
            .thenAnswer((_) => Stream.value(tMembers));
        return GroupMembersCubit(
          groupId: groupId,
          groupsRepository: mockGroupsRepository,
        );
      },
      expect: () => [
        GroupMembersLoaded(tMembers),
      ],
    );

    blocTest<GroupMembersCubit, GroupMembersState>(
      'emits [GroupMembersError] when subscription fails',
      build: () {
        when(() => mockGroupsRepository.watchGroupMembers(groupId))
            .thenAnswer((_) => Stream.error(Exception('Error')));
        return GroupMembersCubit(
          groupId: groupId,
          groupsRepository: mockGroupsRepository,
        );
      },
      expect: () => [
        const GroupMembersError('Exception: Error'),
      ],
    );
  });
}
