import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/events/models/event_entity.dart';
import 'package:upsessions/features/events/models/event_enums.dart';
import 'package:upsessions/modules/event_manager/cubits/manager_event_form_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/manager_event_form_state.dart';
import 'package:upsessions/modules/event_manager/repositories/manager_events_repository.dart';

class _MockManagerEventsRepository extends Mock
    implements ManagerEventsRepository {}

void main() {
  late _MockManagerEventsRepository repository;

  final event = EventEntity(
    id: 'e1',
    ownerId: 'owner-1',
    title: 'Jazz Night',
    city: 'Valencia',
    venue: 'Blue Note',
    start: DateTime(2026, 3, 1),
    end: DateTime(2026, 3, 2),
    description: 'desc',
    organizer: 'org',
    contactEmail: 'e@e.com',
    contactPhone: '123',
    lineup: const [],
    tags: const [],
    ticketInfo: '',
    capacity: 100,
    resources: const [],
    isPublic: true,
    isFree: false,
    updatedAt: DateTime(2026, 3, 1),
    status: EventStatus.draft,
  );

  setUpAll(() {
    registerFallbackValue(event);
  });

  setUp(() {
    repository = _MockManagerEventsRepository();
  });

  ManagerEventFormCubit buildCubit() {
    return ManagerEventFormCubit(repository: repository);
  }

  group('ManagerEventFormCubit', () {
    test('estado inicial tiene isSaving false y success false', () {
      final cubit = buildCubit();
      expect(cubit.state.isSaving, false);
      expect(cubit.state.success, false);
      expect(cubit.state.errorMessage, isNull);
      cubit.close();
    });

    blocTest<ManagerEventFormCubit, ManagerEventFormState>(
      'saveEvent emite saving y success cuando se guarda correctamente',
      build: () {
        when(() => repository.saveDraft(any()))
            .thenAnswer((_) async => event);
        return buildCubit();
      },
      act: (cubit) => cubit.saveEvent(event),
      expect: () => [
        isA<ManagerEventFormState>()
            .having((s) => s.isSaving, 'saving', true)
            .having((s) => s.success, 'success', false),
        isA<ManagerEventFormState>()
            .having((s) => s.isSaving, 'idle', false)
            .having((s) => s.success, 'success', true),
      ],
    );

    blocTest<ManagerEventFormCubit, ManagerEventFormState>(
      'saveEvent emite error cuando falla el guardado',
      build: () {
        when(() => repository.saveDraft(any()))
            .thenThrow(Exception('save error'));
        return buildCubit();
      },
      act: (cubit) => cubit.saveEvent(event),
      expect: () => [
        isA<ManagerEventFormState>()
            .having((s) => s.isSaving, 'saving', true),
        isA<ManagerEventFormState>()
            .having((s) => s.isSaving, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('save error')),
      ],
    );
  });
}
