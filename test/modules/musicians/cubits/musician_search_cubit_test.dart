import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:upsessions/modules/musicians/cubits/musician_search_cubit.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'package:upsessions/modules/musicians/models/musician_compliance_info.dart';
import 'package:upsessions/modules/musicians/models/musician_entity.dart';
import 'package:upsessions/modules/musicians/models/musician_professional_info.dart';
import 'package:upsessions/features/home/repositories/home_metadata_repository.dart';

class _MockMusiciansRepository extends Mock implements MusiciansRepository {}

class _MockHomeMetadataRepository extends Mock
    implements HomeMetadataRepository {}

void main() {
  late _MockMusiciansRepository repository;
  late _MockHomeMetadataRepository metadataRepository;

  final mockResults = [
    MusicianEntity(
      id: '1',
      ownerId: 'owner-1',
      name: 'María Rivera',
      instrument: 'Voz',
      city: 'CDMX',
      styles: ['Soul'],
      experienceYears: 8,
      compliance: MusicianComplianceInfo(updatedAt: DateTime.now()),
      professional: const MusicianProfessionalInfo(),
    ),
    MusicianEntity(
      id: '2',
      ownerId: 'owner-2',
      name: 'Juan Herrera',
      instrument: 'Guitarra',
      city: 'GDL',
      styles: ['Rock'],
      experienceYears: 12,
      compliance: MusicianComplianceInfo(updatedAt: DateTime.now()),
      professional: const MusicianProfessionalInfo(),
    ),
  ];

  setUp(() {
    repository = _MockMusiciansRepository();
    metadataRepository = _MockHomeMetadataRepository();
  });

  group('MusicianSearchCubit', () {
    test('copyWith allows clearing errorMessage explicitly', () {
      const stateWithError = MusicianSearchState(
        errorMessage: 'No pudimos cargar los músicos. Intenta más tarde.',
      );

      final cleared = stateWithError.copyWith(errorMessage: null);
      expect(cleared.errorMessage, isNull);
    });

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
          metadataRepository: metadataRepository,
        );
      },
      act: (cubit) => cubit.search(query: 'rock'),
      expect: () => [
        const MusicianSearchState(isLoading: true, query: 'rock', results: []),
        MusicianSearchState(
          isLoading: false,
          query: 'rock',
          results: mockResults,
        ),
      ],
      verify: (cubit) {
        verify(
          () => repository.search(
            query: 'rock',
            instrument: '',
            style: '',
            province: '',
            city: '',
            profileType: '',
            gender: '',
          ),
        ).called(1);
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
          metadataRepository: metadataRepository,
        );
      },
      act: (cubit) => cubit.search(query: 'jazz'),
      expect: () => const [
        MusicianSearchState(isLoading: true, query: 'jazz', results: []),
        MusicianSearchState(
          isLoading: false,
          query: 'jazz',
          results: [],
          errorMessage: 'No pudimos cargar los músicos. Intenta más tarde.',
        ),
      ],
    );

    blocTest<MusicianSearchCubit, MusicianSearchState>(
      'limpia errorMessage cuando una búsqueda posterior sí responde',
      build: () {
        var callCount = 0;
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
        ).thenAnswer((_) async {
          if (callCount++ == 0) {
            throw Exception('firestore-offline');
          }
          return mockResults;
        });
        return MusicianSearchCubit(
          repository: repository,
          metadataRepository: metadataRepository,
        );
      },
      act: (cubit) async {
        await cubit.search(query: 'jazz');
        await cubit.search(query: 'rock');
      },
      expect: () => [
        const MusicianSearchState(isLoading: true, query: 'jazz', results: []),
        const MusicianSearchState(
          isLoading: false,
          query: 'jazz',
          results: [],
          errorMessage: 'No pudimos cargar los músicos. Intenta más tarde.',
        ),
        const MusicianSearchState(isLoading: true, query: 'rock', results: []),
        MusicianSearchState(
          isLoading: false,
          query: 'rock',
          results: mockResults,
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
          metadataRepository: metadataRepository,
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
        verify(
          () => repository.search(
            query: '',
            instrument: 'Guitarra',
            style: '',
            province: '',
            city: '',
            profileType: '',
            gender: '',
          ),
        ).called(1);
      },
    );

    blocTest<MusicianSearchCubit, MusicianSearchState>(
      'clearFilters limpia query y filtros, y busca sin criterios',
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
        ).thenAnswer((_) async => const []);
        return MusicianSearchCubit(
          repository: repository,
          metadataRepository: metadataRepository,
        );
      },
      act: (cubit) async {
        cubit.onQueryChanged('rock');
        cubit.setInstrument('Guitarra');
        await cubit.clearFilters();
      },
      expect: () => const [
        MusicianSearchState(query: 'rock'),
        MusicianSearchState(query: 'rock', instrument: 'Guitarra'),
        MusicianSearchState(
          query: '',
          instrument: '',
          style: '',
          province: '',
          city: '',
          profileType: '',
          gender: '',
          cities: [],
        ),
        MusicianSearchState(isLoading: true, query: '', results: []),
        MusicianSearchState(isLoading: false, query: '', results: []),
      ],
      verify: (_) {
        verify(
          () => repository.search(
            query: '',
            instrument: '',
            style: '',
            province: '',
            city: '',
            profileType: '',
            gender: '',
          ),
        ).called(1);
      },
    );

    blocTest<MusicianSearchCubit, MusicianSearchState>(
      'onQueryChanged aplica debounce y solo busca con el último valor',
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
          metadataRepository: metadataRepository,
        );
      },
      act: (cubit) {
        cubit.onQueryChanged('ja');
        cubit.onQueryChanged('jazz');
      },
      wait: const Duration(milliseconds: 650),
      expect: () => [
        const MusicianSearchState(query: 'ja'),
        const MusicianSearchState(query: 'jazz'),
        const MusicianSearchState(isLoading: true, query: 'jazz', results: []),
        MusicianSearchState(
          isLoading: false,
          query: 'jazz',
          results: mockResults,
        ),
      ],
      verify: (_) {
        verify(
          () => repository.search(
            query: 'jazz',
            instrument: '',
            style: '',
            province: '',
            city: '',
            profileType: '',
            gender: '',
          ),
        ).called(1);
      },
    );

    blocTest<MusicianSearchCubit, MusicianSearchState>(
      'searchNow cancela debounce pendiente',
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
          metadataRepository: metadataRepository,
        );
      },
      act: (cubit) async {
        cubit.onQueryChanged('rock');
        await cubit.searchNow(query: 'metal');
      },
      wait: const Duration(milliseconds: 650),
      expect: () => [
        const MusicianSearchState(query: 'rock'),
        const MusicianSearchState(isLoading: true, query: 'metal', results: []),
        MusicianSearchState(
          isLoading: false,
          query: 'metal',
          results: mockResults,
        ),
      ],
      verify: (_) {
        verify(
          () => repository.search(
            query: 'metal',
            instrument: '',
            style: '',
            province: '',
            city: '',
            profileType: '',
            gender: '',
          ),
        ).called(1);
      },
    );
  });
}
