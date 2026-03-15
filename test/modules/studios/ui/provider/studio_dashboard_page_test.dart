import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/studios/cubits/my_studio_cubit.dart';
import 'package:upsessions/modules/studios/cubits/studios_state.dart';
import 'package:upsessions/modules/studios/cubits/studios_status.dart';
import 'package:upsessions/modules/studios/ui/provider/studio_dashboard_page.dart';
import 'package:upsessions/modules/studios/ui/widgets/empty_states/no_studio_empty_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockMyStudioCubit extends MockCubit<StudiosState>
    implements MyStudioCubit {}

void main() {
  late _MockAuthRepository authRepository;
  late _MockMyStudioCubit myStudioCubit;

  setUp(() async {
    authRepository = _MockAuthRepository();
    myStudioCubit = _MockMyStudioCubit();
    const state = StudiosState(status: StudiosStatus.success);
    when(() => myStudioCubit.state).thenReturn(state);
    whenListen(
      myStudioCubit,
      const Stream<StudiosState>.empty(),
      initialState: state,
    );
    await getIt.reset();
    getIt.registerSingleton<AuthRepository>(authRepository);
  });

  tearDown(() async {
    await myStudioCubit.close();
    await getIt.reset();
  });

  GoRouter routerForTest() {
    return GoRouter(
      initialLocation: AppRoutes.studiosDashboard,
      routes: [
        GoRoute(
          path: AppRoutes.studiosDashboard,
          builder: (context, state) {
            return BlocProvider<MyStudioCubit>.value(
              value: myStudioCubit,
              child: const StudioDashboardPage(),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.studiosLogin,
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Studio Login Route'))),
        ),
      ],
    );
  }

  testWidgets(
    'redirects to studios login when there is no authenticated user',
    (tester) async {
      when(() => authRepository.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: routerForTest(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Studio Login Route'), findsOneWidget);
    },
  );

  testWidgets('shows dashboard empty state when user is authenticated', (
    tester,
  ) async {
    when(() => authRepository.currentUser).thenReturn(
      UserEntity(
        id: 'studio-user',
        email: 'studio@test.com',
        displayName: 'Studio User',
        createdAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: routerForTest(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pump();

    expect(find.byType(NoStudioEmptyState), findsOneWidget);
    expect(find.text('Studio Login Route'), findsNothing);
  });
}
