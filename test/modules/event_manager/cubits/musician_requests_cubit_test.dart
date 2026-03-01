import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/event_manager/cubits/musician_requests_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/musician_requests_state.dart';
import 'package:upsessions/modules/event_manager/models/musician_request_entity.dart';
import 'package:upsessions/modules/event_manager/repositories/musician_requests_repository.dart';

class _MockMusicianRequestsRepository extends Mock
    implements MusicianRequestsRepository {}

void main() {
  late _MockMusicianRequestsRepository repository;

  final requests = [
    MusicianRequestEntity(
      id: 'r1',
      managerId: 'manager-1',
      musicianId: 'musician-1',
      status: RequestStatus.pending,
      message: 'Te invitamos a tocar',
      createdAt: DateTime(2026, 3, 1),
    ),
    MusicianRequestEntity(
      id: 'r2',
      managerId: 'manager-1',
      musicianId: 'musician-2',
      status: RequestStatus.accepted,
      message: 'Ven a la jam',
      createdAt: DateTime(2026, 3, 2),
    ),
  ];

  final newRequest = MusicianRequestEntity(
    id: '',
    managerId: 'manager-1',
    musicianId: 'musician-3',
    status: RequestStatus.pending,
    message: 'Nuevo request',
    createdAt: DateTime(2026, 3, 5),
  );

  setUpAll(() {
    registerFallbackValue(newRequest);
  });

  setUp(() {
    repository = _MockMusicianRequestsRepository();
  });

  MusicianRequestsCubit buildCubit() {
    return MusicianRequestsCubit(repository: repository);
  }

  group('MusicianRequestsCubit', () {
    test('estado inicial tiene isLoading true y lista vacía', () {
      final cubit = buildCubit();
      expect(cubit.state.isLoading, true);
      expect(cubit.state.requests, isEmpty);
      cubit.close();
    });

    // -- loadRequests --

    blocTest<MusicianRequestsCubit, MusicianRequestsState>(
      'loadRequests carga las solicitudes del manager',
      build: () {
        when(() => repository.fetchManagerRequests())
            .thenAnswer((_) async => requests);
        return buildCubit();
      },
      act: (cubit) => cubit.loadRequests(),
      expect: () => [
        isA<MusicianRequestsState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<MusicianRequestsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.requests.length, 'count', 2),
      ],
    );

    blocTest<MusicianRequestsCubit, MusicianRequestsState>(
      'loadRequests emite error cuando falla el repositorio',
      build: () {
        when(() => repository.fetchManagerRequests())
            .thenThrow(Exception('fetch error'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadRequests(),
      expect: () => [
        isA<MusicianRequestsState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<MusicianRequestsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('fetch error')),
      ],
    );

    // -- sendRequest --

    blocTest<MusicianRequestsCubit, MusicianRequestsState>(
      'sendRequest envía solicitud y recarga la lista',
      build: () {
        when(() => repository.sendRequest(any()))
            .thenAnswer((_) async => newRequest.copyWith(id: 'r3'));
        when(() => repository.fetchManagerRequests())
            .thenAnswer((_) async => [...requests, newRequest.copyWith(id: 'r3')]);
        return buildCubit();
      },
      act: (cubit) => cubit.sendRequest(newRequest),
      expect: () => [
        // sendRequest + loadRequests both emit loading, bloc suppresses duplicate
        isA<MusicianRequestsState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<MusicianRequestsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.requests.length, 'count', 3),
      ],
    );

    blocTest<MusicianRequestsCubit, MusicianRequestsState>(
      'sendRequest emite error cuando falla el envío',
      build: () {
        when(() => repository.sendRequest(any()))
            .thenThrow(Exception('send error'));
        return buildCubit();
      },
      act: (cubit) => cubit.sendRequest(newRequest),
      expect: () => [
        isA<MusicianRequestsState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<MusicianRequestsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('send error')),
      ],
    );

    // -- cancelRequest --

    blocTest<MusicianRequestsCubit, MusicianRequestsState>(
      'cancelRequest elimina la solicitud y actualiza la lista',
      build: () {
        when(() => repository.deleteRequest('r1')).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => MusicianRequestsState(isLoading: false, requests: requests),
      act: (cubit) => cubit.cancelRequest('r1'),
      expect: () => [
        isA<MusicianRequestsState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<MusicianRequestsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.requests.length, 'count', 1)
            .having((s) => s.requests.first.id, 'remaining', 'r2'),
      ],
    );

    blocTest<MusicianRequestsCubit, MusicianRequestsState>(
      'cancelRequest emite error cuando falla la cancelación',
      build: () {
        when(() => repository.deleteRequest('r1'))
            .thenThrow(Exception('cancel error'));
        return buildCubit();
      },
      seed: () => MusicianRequestsState(isLoading: false, requests: requests),
      act: (cubit) => cubit.cancelRequest('r1'),
      expect: () => [
        isA<MusicianRequestsState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<MusicianRequestsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('cancel error')),
      ],
    );
  });
}
