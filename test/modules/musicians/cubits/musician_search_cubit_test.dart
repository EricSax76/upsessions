import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:upsessions/modules/musicians/cubits/musician_search_cubit.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'package:upsessions/modules/musicians/models/musician_entity.dart';
import 'package:upsessions/home/repositories/user_home_repository.dart';

class _MockMusiciansRepository extends Mock implements MusiciansRepository {}
class _MockUserHomeRepository extends Mock implements UserHomeRepository {}

void main() {
  late _MockMusiciansRepository repository;
  late _MockUserHomeRepository userHomeRepository;
  
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
    userHomeRepository = _MockUserHomeRepository();
  });

  group('MusicianSearchCubit', () {
    blocTest<MusicianSearchCubit, MusicianSearchState>(
      'carga resultados cuando el repositorio responde correctamente',
      build: () {
        when(
          () => repository.search(
            query: any(named: 'query'),
            instrument: any(named: 'instrument'),
            style: any(named: 'style'),
            province: any(named: 'province'),
            city: any(named: 'city'),
            profileType: any(named: 'profileType'),
            gender: any(named: 'gender'),
          ),
        ).thenAnswer((_) async => mockResults);
        return MusicianSearchCubit(
          repository: repository,
          userHomeRepository: userHomeRepository,
        );
      },
      act: (cubit) => cubit.search(query: 'rock'),
      expect: () => [
        const MusicianSearchState(
          isLoading: true,
          query: 'rock',
          results: [],
        ),
        const MusicianSearchState(
          isLoading: false,
          query: 'rock',
          results: mockResults,
        ),
      ],
      verify: (cubit) {
        verify(() => repository.search(
          query: 'rock',
          instrument: '',
          style: '',
          province: '',
          city: '',
          profileType: '',
          gender: '',
        )).called(1);
      },
    );

    blocTest<MusicianSearchCubit, MusicianSearchState>(
      'emite error cuando search lanza excepción',
      build: () {
        when(
          () => repository.search(
            query: any(named: 'query'),
            instrument: any(named: 'instrument'),
            style: any(named: 'style'),
            province: any(named: 'province'),
            city: any(named: 'city'),
            profileType: any(named: 'profileType'),
            gender: any(named: 'gender'),
          ),
        ).thenThrow(Exception('firestore-offline'));
        return MusicianSearchCubit(
          repository: repository,
          userHomeRepository: userHomeRepository,
        );
      },
      act: (cubit) => cubit.search(query: 'jazz'),
      expect: () => const [
        MusicianSearchState(
          isLoading: true,
          query: 'jazz',
          results: [],
        ),
        MusicianSearchState(
          isLoading: false,
          query: 'jazz',
          results: [],
          errorMessage: 'No pudimos cargar los músicos. Intenta más tarde.',
        ),
      ],
    );

    blocTest<MusicianSearchCubit, MusicianSearchState>(
      'actualiza filtros y realiza búsqueda con filtros',
      build: () {
        when(
          () => repository.search(
            query: any(named: 'query'),
            instrument: any(named: 'instrument'),
            style: any(named: 'style'),
            province: any(named: 'province'),
            city: any(named: 'city'),
            profileType: any(named: 'profileType'),
            gender: any(named: 'gender'),
          ),
        ).thenAnswer((_) async => []); // Retorna vacio para simplificar
        return MusicianSearchCubit(
          repository: repository,
          userHomeRepository: userHomeRepository,
        );
      },
      act: (cubit) async {
        cubit.setInstrument('Guitarra');
        await cubit.search();
      },
      expect: () => const [
        MusicianSearchState(instrument: 'Guitarra'),
        MusicianSearchState(
          isLoading: true,
          instrument: 'Guitarra',
          results: [],
        ),
        MusicianSearchState(
          isLoading: false,
          instrument: 'Guitarra',
          results: [],
        ),
      ],
      verify: (cubit) {
        verify(() => repository.search(
          query: '',
          instrument: 'Guitarra',
          style: '',
          province: '',
          city: '',
          profileType: '',
          gender: '',
        )).called(1);
      },
    );
  });
}
