import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/contacts/logic/liked_musicians_controller.dart';
import 'package:upsessions/features/contacts/models/liked_musician.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/features/notifications/models/invite_notification_entity.dart';
import 'package:upsessions/features/notifications/repositories/invite_notifications_repository.dart';
import 'package:upsessions/modules/studios/repositories/studios_repository.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/groups/models/group_dtos.dart';
import 'package:upsessions/modules/rehearsals/ui/pages/rehearsal_detail_page.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/setlist_repository.dart';
import 'package:upsessions/modules/rehearsals/models/rehearsal_entity.dart';
import 'package:upsessions/modules/groups/models/group_membership_entity.dart';
import 'package:upsessions/modules/rehearsals/models/setlist_item_entity.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/profile/cubit/profile_cubit.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

class MockRehearsalsRepository extends Mock implements RehearsalsRepository {}

class MockSetlistRepository extends Mock implements SetlistRepository {}

class MockGroupsRepository extends Mock implements GroupsRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockInviteNotificationsRepository extends Mock
    implements InviteNotificationsRepository {}

class MockStudiosRepository extends Mock implements StudiosRepository {}

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
  late MockProfileCubit profileCubit;
  late MockRehearsalsRepository rehearsalsRepository;
  late MockSetlistRepository setlistRepository;
  late MockGroupsRepository groupsRepository;
  late MockChatRepository chatRepository;
  late MockInviteNotificationsRepository invitesRepository;
  late MockStudiosRepository studiosRepository;

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
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: authState,
    );

    profileCubit = MockProfileCubit();
    const profileState = ProfileState();
    when(() => profileCubit.state).thenReturn(profileState);
    whenListen(
      profileCubit,
      const Stream<ProfileState>.empty(),
      initialState: profileState,
    );

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
          groupId: '1',
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
    when(
      () => groupsRepository.watchMyGroups(),
    ).thenAnswer((_) => Stream.value(const <GroupMembershipEntity>[]));
    when(() => groupsRepository.watchGroup(any())).thenAnswer(
      (_) => Stream.value(
        const GroupDoc(id: '1', name: 'Test Group', ownerId: 'u1'),
      ),
    );

    chatRepository = MockChatRepository();
    when(
      () => chatRepository.watchUnreadTotal(),
    ).thenAnswer((_) => Stream.value(0));

    invitesRepository = MockInviteNotificationsRepository();
    studiosRepository = MockStudiosRepository();
    when(() => studiosRepository.getStudioByOwner(any())).thenAnswer(
      (_) async => null,
    );
    when(() => invitesRepository.watchMyInvites()).thenAnswer(
      (_) => Stream<List<InviteNotificationEntity>>.value(
        const <InviteNotificationEntity>[],
      ),
    );

    await getIt.reset();
    getIt
      ..registerSingleton<RehearsalsRepository>(rehearsalsRepository)
      ..registerSingleton<SetlistRepository>(setlistRepository)
      ..registerSingleton<GroupsRepository>(groupsRepository)
      ..registerSingleton<ChatRepository>(chatRepository)
      ..registerSingleton<InviteNotificationsRepository>(invitesRepository)
      ..registerSingleton<StudiosRepository>(studiosRepository)
      ..registerSingleton<LikedMusiciansController>(
        FakeLikedMusiciansController(),
      );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('RehearsalDetailPage can be built', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = GoRouter(
      initialLocation: AppRoutes.rehearsalDetail(
        groupId: '1',
        rehearsalId: '1',
      ),
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
            return RehearsalDetailPage(
              groupId: groupId,
              rehearsalId: rehearsalId,
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<ProfileCubit>.value(value: profileCubit),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(RehearsalDetailPage), findsOneWidget);
  });
}
