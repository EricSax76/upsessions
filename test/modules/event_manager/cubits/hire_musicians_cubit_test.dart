import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/event_manager/cubits/hire_musicians_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/hire_musicians_state.dart';
import 'package:upsessions/modules/musicians/models/musician_entity.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';

class _MockMusiciansRepository extends Mock implements MusiciansRepository {}

void main() {
  late _MockMusiciansRepository repository;

  final musicians = [
    const MusicianEntity(
      id: 'm1',
      ownerId: 'm1',
      name: 'Carlos López',
      instrument: 'Guitarra',
      city: 'Madrid',
      styles: ['Rock', 'Blues'],
      experienceYears: 5,
      availableForHire: true,
    ),
    const MusicianEntity(
      id: 'm2',
      ownerId: 'm2',
      name: 'Ana García',
      instrument: 'Batería',
      city: 'Barcelona',
      styles: ['Jazz', 'Funk'],
      experienceYears: 8,
      availableForHire: true,
    ),
  ];

  setUp(() {
    repository = _MockMusiciansRepository();
  });

  HireMusiciansCubit buildCubit() {
    return HireMusiciansCubit(repository: repository);
  }

  group('HireMusiciansCubit', () {
    test('estado inicial tiene isLoading false y lista vacía', () {
      final cubit = buildCubit();
      expect(cubit.state.isLoading, false);
      expect(cubit.state.musicians, isEmpty);
      expect(cubit.state.searchQuery, '');
      expect(cubit.state.error, isNull);
      cubit.close();
    });

    // -- loadMusicians --

    blocTest<HireMusiciansCubit, HireMusiciansState>(
      'loadMusicians carga músicos disponibles para contratar',
      build: () {
        when(() => repository.searchAvailableForHire(query: ''))
            .thenAnswer((_) async => musicians);
        return buildCubit();
      },
      act: (cubit) => cubit.loadMusicians(),
      expect: () => [
        isA<HireMusiciansState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<HireMusiciansState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.musicians.length, 'count', 2),
      ],
    );

    blocTest<HireMusiciansCubit, HireMusiciansState>(
      'loadMusicians emite error cuando falla',
      build: () {
        when(() => repository.searchAvailableForHire(query: ''))
            .thenThrow(Exception('load error'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadMusicians(),
      expect: () => [
        isA<HireMusiciansState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<HireMusiciansState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.error, 'err', contains('load error')),
      ],
    );

    // -- search --

    blocTest<HireMusiciansCubit, HireMusiciansState>(
      'search filtra músicos por query',
      build: () {
        when(() => repository.searchAvailableForHire(query: 'guitarra'))
            .thenAnswer((_) async => [musicians.first]);
        return buildCubit();
      },
      act: (cubit) => cubit.search('guitarra'),
      expect: () => [
        isA<HireMusiciansState>()
            .having((s) => s.isLoading, 'loading', true)
            .having((s) => s.searchQuery, 'query', 'guitarra'),
        isA<HireMusiciansState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.musicians.length, 'count', 1)
            .having((s) => s.musicians.first.name, 'name', 'Carlos López'),
      ],
    );

    blocTest<HireMusiciansCubit, HireMusiciansState>(
      'search emite error cuando falla la búsqueda',
      build: () {
        when(() => repository.searchAvailableForHire(query: 'test'))
            .thenThrow(Exception('search error'));
        return buildCubit();
      },
      act: (cubit) => cubit.search('test'),
      expect: () => [
        isA<HireMusiciansState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<HireMusiciansState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.error, 'err', contains('search error')),
      ],
    );
  });
}
