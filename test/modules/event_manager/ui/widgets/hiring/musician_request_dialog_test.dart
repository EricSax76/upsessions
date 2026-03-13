import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/event_manager/cubits/event_manager_auth_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/event_manager_auth_state.dart';
import 'package:upsessions/modules/event_manager/cubits/musician_requests_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/musician_requests_state.dart';
import 'package:upsessions/modules/event_manager/models/event_manager_entity.dart';
import 'package:upsessions/modules/event_manager/models/musician_request_entity.dart';
import 'package:upsessions/modules/event_manager/ui/widgets/hiring/musician_request_dialog.dart';

class _MockMusicianRequestsCubit extends MockCubit<MusicianRequestsState>
    implements MusicianRequestsCubit {}

class _MockEventManagerAuthCubit extends MockCubit<EventManagerAuthState>
    implements EventManagerAuthCubit {}

void main() {
  late _MockMusicianRequestsCubit requestsCubit;
  late _MockEventManagerAuthCubit authCubit;

  const manager = EventManagerEntity(
    id: 'manager-1',
    ownerId: 'manager-1',
    name: 'Manager Test',
    contactEmail: 'manager@test.com',
    contactPhone: '600000000',
    city: 'Madrid',
    specialties: ['General'],
  );

  const authState = EventManagerAuthState(
    status: EventManagerAuthStatus.authenticated,
    manager: manager,
  );

  Widget buildHarness() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EventManagerAuthCubit>.value(value: authCubit),
        BlocProvider<MusicianRequestsCubit>.value(value: requestsCubit),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => const MusicianRequestDialog(
                      musicianId: 'musician-1',
                      musicianName: 'Ana',
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              );
            },
          ),
        ),
      ),
    );
  }

  setUpAll(() {
    registerFallbackValue(
      MusicianRequestEntity(
        id: '',
        managerId: '',
        musicianId: '',
        status: RequestStatus.pending,
        message: '',
        createdAt: DateTime(2026, 1, 1),
      ),
    );
  });

  setUp(() {
    requestsCubit = _MockMusicianRequestsCubit();
    authCubit = _MockEventManagerAuthCubit();

    when(() => authCubit.state).thenReturn(authState);
    whenListen(
      authCubit,
      const Stream<EventManagerAuthState>.empty(),
      initialState: authState,
    );

    const requestsState = MusicianRequestsState(isLoading: false);
    when(() => requestsCubit.state).thenReturn(requestsState);
    whenListen(
      requestsCubit,
      const Stream<MusicianRequestsState>.empty(),
      initialState: requestsState,
    );
    when(() => requestsCubit.sendRequest(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await requestsCubit.close();
    await authCubit.close();
  });

  testWidgets('cierra el diálogo cuando la solicitud se envía correctamente', (
    tester,
  ) async {
    await tester.pumpWidget(buildHarness());

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hola, te invitamos.');
    await tester.tap(find.text('Enviar Solicitud'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    verify(() => requestsCubit.sendRequest(any())).called(1);
  });

  testWidgets('mantiene el diálogo abierto cuando ocurre un error', (
    tester,
  ) async {
    when(
      () => requestsCubit.state,
    ).thenReturn(const MusicianRequestsState(errorMessage: 'network'));

    await tester.pumpWidget(buildHarness());

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hola, te invitamos.');
    await tester.tap(find.text('Enviar Solicitud'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.textContaining('No se pudo enviar la solicitud'),
      findsOneWidget,
    );
    verify(() => requestsCubit.sendRequest(any())).called(1);
  });

  testWidgets(
    'no permite cerrar con atrás mientras la solicitud está enviándose',
    (tester) async {
      final completer = Completer<void>();
      when(
        () => requestsCubit.sendRequest(any()),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildHarness());

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hola, te invitamos.');
      await tester.tap(find.text('Enviar Solicitud'));
      await tester.pump();

      expect(find.text('Enviando...'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      verify(() => requestsCubit.sendRequest(any())).called(1);
    },
  );
}
