import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/onboarding/cubits/musician_onboarding_cubit.dart';
import 'package:upsessions/features/onboarding/cubits/musician_onboarding_state.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';

class MockMusiciansRepository extends Mock implements MusiciansRepository {}

void main() {
  late MockMusiciansRepository repository;
  
  setUp(() {
    repository = MockMusiciansRepository();
  });

  group('MusicianOnboardingCubit', () {
    test('initial state is correct', () {
      final cubit = MusicianOnboardingCubit(repository: repository);
      expect(cubit.state.currentStep, 0);
      expect(cubit.state.status, MusicianOnboardingStatus.idle);
      expect(cubit.state.influences, isEmpty);
      cubit.close();
    });

    blocTest<MusicianOnboardingCubit, MusicianOnboardingState>(
      'nextStep increments currentStep',
      build: () => MusicianOnboardingCubit(repository: repository),
      act: (cubit) {
        cubit.nextStep();
        cubit.nextStep();
      },
      expect: () => [
        isA<MusicianOnboardingState>()
            .having((s) => s.currentStep, 'step', 1),
        isA<MusicianOnboardingState>()
            .having((s) => s.currentStep, 'step', 2),
      ],
    );

    blocTest<MusicianOnboardingCubit, MusicianOnboardingState>(
      'previousStep decrements currentStep but not below 0',
      build: () => MusicianOnboardingCubit(repository: repository),
      act: (cubit) {
        cubit.nextStep(); // step 1
        cubit.previousStep(); // step 0
        cubit.previousStep(); // still 0
      },
      expect: () => [
        isA<MusicianOnboardingState>()
            .having((s) => s.currentStep, 'step', 1),
        isA<MusicianOnboardingState>()
            .having((s) => s.currentStep, 'step', 0),
      ],
    );

    blocTest<MusicianOnboardingCubit, MusicianOnboardingState>(
      'addInfluence adds artist to style',
      build: () => MusicianOnboardingCubit(repository: repository),
      act: (cubit) {
        cubit.addInfluence('Rock', 'Led Zeppelin');
        cubit.addInfluence('Rock', 'Pink Floyd');
        cubit.addInfluence('Jazz', 'Miles Davis');
      },
      expect: () => [
        isA<MusicianOnboardingState>().having(
          (s) => s.influences,
          'influences',
          {
            'Rock': ['Led Zeppelin'],
          },
        ),
        isA<MusicianOnboardingState>().having(
          (s) => s.influences,
          'influences',
          {
            'Rock': ['Led Zeppelin', 'Pink Floyd'],
          },
        ),
        isA<MusicianOnboardingState>().having(
          (s) => s.influences,
          'influences',
          {
            'Rock': ['Led Zeppelin', 'Pink Floyd'],
            'Jazz': ['Miles Davis'],
          },
        ),
      ],
    );

    blocTest<MusicianOnboardingCubit, MusicianOnboardingState>(
      'addInfluence ignores duplicates (case insensitive)',
      build: () => MusicianOnboardingCubit(repository: repository),
      seed: () => const MusicianOnboardingState(influences: {
        'Rock': ['Led Zeppelin'],
      }),
      act: (cubit) => cubit.addInfluence('Rock', 'led zeppelin'),
      expect: () => <MusicianOnboardingState>[],
    );

    blocTest<MusicianOnboardingCubit, MusicianOnboardingState>(
      'removeInfluence removes artist and cleans empty style',
      build: () => MusicianOnboardingCubit(repository: repository),
      seed: () => const MusicianOnboardingState(influences: {
        'Rock': ['Led Zeppelin'],
        'Jazz': ['Miles Davis', 'Coltrane'],
      }),
      act: (cubit) {
        cubit.removeInfluence('Rock', 'Led Zeppelin');
        cubit.removeInfluence('Jazz', 'Miles Davis');
      },
      expect: () => [
        isA<MusicianOnboardingState>().having(
          (s) => s.influences,
          'influences',
          {
            'Jazz': ['Miles Davis', 'Coltrane'],
          },
        ),
        isA<MusicianOnboardingState>().having(
          (s) => s.influences,
          'influences',
          {
            'Jazz': ['Coltrane'],
          },
        ),
      ],
    );

    group('submit', () {
      late MockMusiciansRepository repository;

      setUp(() {
        repository = MockMusiciansRepository();
      });

      blocTest<MusicianOnboardingCubit, MusicianOnboardingState>(
        'emits saving then saved on success',
        build: () {
          when(() => repository.saveProfile(
                musicianId: any(named: 'musicianId'),
                name: any(named: 'name'),
                instrument: any(named: 'instrument'),
                city: any(named: 'city'),
                styles: any(named: 'styles'),
                experienceYears: any(named: 'experienceYears'),
                photoUrl: any(named: 'photoUrl'),
                bio: any(named: 'bio'),
                influences: any(named: 'influences'),
              )).thenAnswer((_) async {});
          return MusicianOnboardingCubit(repository: repository);
        },
        act: (cubit) => cubit.submit(
          // repository param removed
          musicianId: 'id-1',
          name: 'John',
          instrument: 'Guitar',
          city: 'NYC',
          styles: ['Rock'],
          experienceYears: 5,
        ),
        expect: () => [
          isA<MusicianOnboardingState>()
              .having((s) => s.status, 'saving', MusicianOnboardingStatus.saving),
          isA<MusicianOnboardingState>()
              .having((s) => s.status, 'saved', MusicianOnboardingStatus.saved),
        ],
      );

        blocTest<MusicianOnboardingCubit, MusicianOnboardingState>(
        'emits error on failure',
        build: () {
          when(() => repository.saveProfile(
                musicianId: any(named: 'musicianId'),
                name: any(named: 'name'),
                instrument: any(named: 'instrument'),
                city: any(named: 'city'),
                styles: any(named: 'styles'),
                experienceYears: any(named: 'experienceYears'),
                photoUrl: any(named: 'photoUrl'),
                bio: any(named: 'bio'),
                influences: any(named: 'influences'),
              )).thenThrow(Exception('Save failed'));
          return MusicianOnboardingCubit(repository: repository);
        },
        act: (cubit) => cubit.submit(
          // repository param removed
          musicianId: 'id-1',
          name: 'John',
          instrument: 'Guitar',
          city: 'NYC',
          styles: ['Rock'],
          experienceYears: 5,
        ),
        expect: () => [
          isA<MusicianOnboardingState>()
              .having((s) => s.status, 'saving', MusicianOnboardingStatus.saving),
          isA<MusicianOnboardingState>()
              .having((s) => s.status, 'error', MusicianOnboardingStatus.error)
              .having((s) => s.errorMessage, 'msg', contains('Save failed')),
        ],
      );
    });
  });
}
