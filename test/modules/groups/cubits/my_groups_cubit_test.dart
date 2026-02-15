import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/groups/cubits/my_groups_cubit.dart';
import 'package:upsessions/modules/groups/cubits/my_groups_state.dart';
import 'package:upsessions/modules/groups/models/group_membership_entity.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';

class MockGroupsRepository extends Mock implements GroupsRepository {}

void main() {
  late MockGroupsRepository mockGroupsRepository;

  setUp(() {
    mockGroupsRepository = MockGroupsRepository();
  });

  group('MyGroupsCubit', () {
    final tGroups = [
      const GroupMembershipEntity(
        groupId: '1',
        groupName: 'Test Group',
        groupOwnerId: 'owner1',
        role: 'admin',
      ),
    ];

    test('initial state is MyGroupsLoading (since it starts in constructor)', () {
      when(() => mockGroupsRepository.watchMyGroups()).thenAnswer((_) => Stream.value([]));
      final cubit = MyGroupsCubit(groupsRepository: mockGroupsRepository);
      expect(cubit.state, isA<MyGroupsLoading>());
      cubit.close();
    });

    blocTest<MyGroupsCubit, MyGroupsState>(
      'emits [MyGroupsLoaded] when subscription events arrive',
      build: () {
        when(() => mockGroupsRepository.watchMyGroups()).thenAnswer((_) => Stream.value(tGroups));
        return MyGroupsCubit(groupsRepository: mockGroupsRepository);
      },
      expect: () => [
        // MyGroupsLoading is emitted in constructor, so blocTest misses it
        MyGroupsLoaded(tGroups),
      ],
    );

    blocTest<MyGroupsCubit, MyGroupsState>(
      'emits [MyGroupsError] when subscription fails',
      build: () {
        when(() => mockGroupsRepository.watchMyGroups()).thenAnswer((_) => Stream.error(Exception('Error')));
        return MyGroupsCubit(groupsRepository: mockGroupsRepository);
      },
      expect: () => [
        // MyGroupsLoading is emitted in constructor
        const MyGroupsError('Exception: Error'),
      ],
    );

    test('createGroup calls repository', () async {
      when(() => mockGroupsRepository.watchMyGroups()).thenAnswer((_) => Stream.value([]));
      final cubit = MyGroupsCubit(groupsRepository: mockGroupsRepository);
      
      when(() => mockGroupsRepository.createGroup(
        name: any(named: 'name'),
        genre: any(named: 'genre'),
        link1: any(named: 'link1'),
        link2: any(named: 'link2'),
        photoBytes: any(named: 'photoBytes'),
        photoFileExtension: any(named: 'photoFileExtension'),
      )).thenAnswer((_) async => 'new-group-id');

      final result = await cubit.createGroup(name: 'New Group', genre: 'Rock');
      
      expect(result, 'new-group-id');
      verify(() => mockGroupsRepository.createGroup(
        name: 'New Group',
        genre: 'Rock',
      )).called(1);
      
      cubit.close();
    });
  });
}
