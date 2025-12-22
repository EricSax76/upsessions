import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/contacts/application/liked_musicians_controller.dart';
import 'package:upsessions/features/contacts/domain/liked_musician.dart';
import 'package:upsessions/features/rehearsals/data/groups_repository.dart';
import 'package:upsessions/features/rehearsals/presentation/pages/rehearsal_detail_page.dart';
import 'package:upsessions/features/rehearsals/data/rehearsals_repository.dart';
import 'package:upsessions/features/rehearsals/data/setlist_repository.dart';
import 'package:upsessions/features/rehearsals/domain/rehearsal_entity.dart';
import 'package:upsessions/features/rehearsals/domain/group_membership_entity.dart';
import 'package:upsessions/features/rehearsals/domain/setlist_item_entity.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/auth/domain/user_entity.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockRehearsalsRepository extends Mock implements RehearsalsRepository {}

class MockSetlistRepository extends Mock implements SetlistRepository {}

class MockGroupsRepository extends Mock implements GroupsRepository {}

class FakeLikedMusiciansController extends ChangeNotifier
    implements LikedMusiciansController {
  @override
  List<LikedMusician> get contacts => const [];

  @override
  bool isLiked(String id) => false;

  @override
  int get total => 0;

  @override
  Future<void> toggleLike(LikedMusician musician) async {}

  @override
  Future<void> remove(String musicianId) async {}

  @override
  void sync(LikedMusician musician) {}
}

void main() {
  late MockAuthCubit authCubit;
  late MockRehearsalsRepository rehearsalsRepository;
  late MockSetlistRepository setlistRepository;
  late MockGroupsRepository groupsRepository;

  setUp(() async {
    authCubit = MockAuthCubit();
    final authState = AuthState(
      status: AuthStatus.authenticated,
      user: const UserEntity(
        id: 'u1',
        email: 'test@example.com',
        displayName: 'Test User',
      ),
    );
    when(() => authCubit.state).thenReturn(authState);
    whenListen(authCubit, const Stream<AuthState>.empty(), initialState: authState);

    rehearsalsRepository = MockRehearsalsRepository();
    when(
      () => rehearsalsRepository.watchRehearsal(
        groupId: any(named: 'groupId'),
        rehearsalId: any(named: 'rehearsalId'),
      ),
    ).thenAnswer(
      (_) => Stream.value(
        RehearsalEntity(
          id: '1',
          startsAt: DateTime(2024, 1, 1, 19),
          endsAt: null,
          location: '',
          notes: '',
          createdBy: 'u1',
        ),
      ),
    );

    setlistRepository = MockSetlistRepository();
    when(
      () => setlistRepository.watchSetlist(
        groupId: any(named: 'groupId'),
        rehearsalId: any(named: 'rehearsalId'),
      ),
    ).thenAnswer((_) => Stream.value(const <SetlistItemEntity>[]));

    groupsRepository = MockGroupsRepository();
    when(() => groupsRepository.watchMyGroups())
        .thenAnswer((_) => Stream.value(const <GroupMembershipEntity>[]));

    await getIt.reset();
    getIt
      ..registerSingleton<RehearsalsRepository>(rehearsalsRepository)
      ..registerSingleton<SetlistRepository>(setlistRepository)
      ..registerSingleton<GroupsRepository>(groupsRepository)
      ..registerSingleton<LikedMusiciansController>(FakeLikedMusiciansController());
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('RehearsalDetailPage can be built', (WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.rehearsalDetail(groupId: '1', rehearsalId: '1'),
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const SizedBox.shrink(),
        ),
        GoRoute(
          path: '/rehearsals/groups/:groupId/rehearsals/:rehearsalId',
          builder: (context, state) {
            final groupId = state.pathParameters['groupId'] ?? '';
            final rehearsalId = state.pathParameters['rehearsalId'] ?? '';
            return RehearsalDetailPage(groupId: groupId, rehearsalId: rehearsalId);
          },
        ),
      ],
    );

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
    expect(find.byType(RehearsalDetailPage), findsOneWidget);
  });
}
