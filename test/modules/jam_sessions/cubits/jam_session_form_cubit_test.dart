import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/jam_sessions/cubits/jam_session_form_cubit.dart';
import 'package:upsessions/modules/jam_sessions/cubits/jam_session_form_state.dart';
import 'package:upsessions/modules/jam_sessions/models/jam_session_entity.dart';
import 'package:upsessions/modules/jam_sessions/repositories/jam_sessions_repository.dart';

class _MockJamSessionsRepository extends Mock
    implements JamSessionsRepository {}

void main() {
  late _MockJamSessionsRepository repository;

  final session = JamSessionEntity(
    id: '',
    ownerId: 'manager-1',
    title: 'Funk Jam',
    description: 'Sesión de funk abierta',
    date: DateTime(2026, 5, 20),
    time: '20:00',
    location: 'Sala Groove',
    city: 'Sevilla',
    instrumentRequirements: const ['Bajo', 'Batería'],
  
      createdAt: DateTime.now(),);

  setUpAll(() {
    registerFallbackValue(session);
  });

  setUp(() {
    repository = _MockJamSessionsRepository();
  });

  JamSessionFormCubit buildCubit() {
    return JamSessionFormCubit(repository: repository);
  }

  group('JamSessionFormCubit', () {
    test('estado inicial tiene isSaving false y success false', () {
      final cubit = buildCubit();
      expect(cubit.state.isSaving, false);
      expect(cubit.state.success, false);
      expect(cubit.state.errorMessage, isNull);
      cubit.close();
    });

    blocTest<JamSessionFormCubit, JamSessionFormState>(
      'saveSession emite saving y success cuando se guarda correctamente',
      build: () {
        when(() => repository.saveDraft(any()))
            .thenAnswer((_) async => session.copyWith(id: 'js-new'));
        return buildCubit();
      },
      act: (cubit) => cubit.saveSession(session),
      expect: () => [
        isA<JamSessionFormState>()
            .having((s) => s.isSaving, 'saving', true)
            .having((s) => s.success, 'success', false),
        isA<JamSessionFormState>()
            .having((s) => s.isSaving, 'idle', false)
            .having((s) => s.success, 'success', true),
      ],
    );

    blocTest<JamSessionFormCubit, JamSessionFormState>(
      'saveSession emite error cuando falla el guardado',
      build: () {
        when(() => repository.saveDraft(any()))
            .thenThrow(Exception('save error'));
        return buildCubit();
      },
      act: (cubit) => cubit.saveSession(session),
      expect: () => [
        isA<JamSessionFormState>()
            .having((s) => s.isSaving, 'saving', true),
        isA<JamSessionFormState>()
            .having((s) => s.isSaving, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('save error')),
      ],
    );

    blocTest<JamSessionFormCubit, JamSessionFormState>(
      'saveSession con sesión existente (update) funciona correctamente',
      build: () {
        final existing = session.copyWith(id: 'js-existing');
        when(() => repository.saveDraft(any()))
            .thenAnswer((_) async => existing);
        return buildCubit();
      },
      act: (cubit) => cubit.saveSession(session.copyWith(id: 'js-existing')),
      expect: () => [
        isA<JamSessionFormState>()
            .having((s) => s.isSaving, 'saving', true)
            .having((s) => s.success, 'success', false),
        isA<JamSessionFormState>()
            .having((s) => s.isSaving, 'idle', false)
            .having((s) => s.success, 'success', true),
      ],
    );
  });
}
