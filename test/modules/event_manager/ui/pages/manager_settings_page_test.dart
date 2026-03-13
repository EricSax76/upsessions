import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/event_manager/cubits/event_manager_auth_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/event_manager_auth_state.dart';
import 'package:upsessions/modules/event_manager/models/event_manager_entity.dart';
import 'package:upsessions/modules/event_manager/ui/pages/manager_settings_page.dart';

class _MockEventManagerAuthCubit extends MockCubit<EventManagerAuthState>
    implements EventManagerAuthCubit {}

void main() {
  late _MockEventManagerAuthCubit authCubit;

  const manager = EventManagerEntity(
    id: 'manager-1',
    ownerId: 'manager-1',
    name: 'Manager Test',
    contactEmail: 'manager@test.com',
    contactPhone: '600000000',
    city: 'Madrid',
    specialties: ['Eventos'],
  );

  const authState = EventManagerAuthState(
    status: EventManagerAuthStatus.authenticated,
    manager: manager,
  );

  Widget buildHarness() {
    return BlocProvider<EventManagerAuthCubit>.value(
      value: authCubit,
      child: const MaterialApp(home: ManagerSettingsPage()),
    );
  }

  setUp(() {
    authCubit = _MockEventManagerAuthCubit();
    when(() => authCubit.state).thenReturn(authState);
    whenListen(
      authCubit,
      const Stream<EventManagerAuthState>.empty(),
      initialState: authState,
    );
    when(() => authCubit.logout()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await authCubit.close();
  });

  testWidgets('muestra contenido real y no placeholder', (tester) async {
    await tester.pumpWidget(buildHarness());

    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('Manager Settings Page'), findsNothing);
  });

  testWidgets('permite cerrar sesión con confirmación', (tester) async {
    await tester.pumpWidget(buildHarness());

    await tester.tap(find.text('Cerrar sesión').first);
    await tester.pumpAndSettle();

    expect(
      find.text('¿Seguro que quieres cerrar tu sesión de manager?'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    verify(() => authCubit.logout()).called(1);
  });
}
