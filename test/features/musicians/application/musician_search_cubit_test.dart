import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:upsessions/modules/musicians/cubits/musician_search_cubit.dart';
import 'package:upsessions/modules/musicians/data/musicians_repository.dart';
import 'package:upsessions/modules/musicians/domain/musician_entity.dart';

class _MockMusiciansRepository extends Mock implements MusiciansRepository {}

void main() {
  late _MockMusiciansRepository repository;
  const mockResults = [
    MusicianEntity(
      id: '1',
      ownerId: 'owner-1',
      name: 'María Rivera',
      instrument: 'Voz',
      city: 'CDMX',
      styles: ['Soul'],
      experienceYears: 8,
    ),
    MusicianEntity(
      id: '2',
      ownerId: 'owner-2',
      name: 'Juan Herrera',
      instrument: 'Guitarra',
      city: 'GDL',
      styles: ['Rock'],
      experienceYears: 12,
    ),
  ];

  setUp(() {
    repository = _MockMusiciansRepository();
  });

  group('MusicianSearchCubit', () {
    blocTest<MusicianSearchCubit, MusicianSearchState>(
      'carga resultados cuando el repositorio responde correctamente',
      build: () {
        when(
          () => repository.search(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => mockResults);
        return MusicianSearchCubit(repository: repository);
      },
      act: (cubit) => cubit.search(query: 'rock'),
      expect: () => [
        const MusicianSearchState(
          isLoading: true,
          query: 'rock',
          results: [],
          errorMessage: null,
        ),
        const MusicianSearchState(
          isLoading: false,
          query: 'rock',
          results: mockResults,
          errorMessage: null,
        ),
      ],
      verify: (cubit) {
        verify(() => repository.search(query: 'rock', limit: 50)).called(1);
      },
    );

    blocTest<MusicianSearchCubit, MusicianSearchState>(
      'emite error cuando search lanza excepción',
      build: () {
        when(
          () => repository.search(
            query: any(named: 'query'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(Exception('firestore-offline'));
        return MusicianSearchCubit(repository: repository);
      },
      act: (cubit) => cubit.search(query: 'jazz'),
      expect: () => const [
        MusicianSearchState(
          isLoading: true,
          query: 'jazz',
          results: [],
          errorMessage: null,
        ),
        MusicianSearchState(
          isLoading: false,
          query: 'jazz',
          results: [],
          errorMessage: 'No pudimos cargar los músicos. Intenta más tarde.',
        ),
      ],
    );
  });
}
