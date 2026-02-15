import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/matching/cubits/matching_cubit.dart';
import 'package:upsessions/modules/matching/repositories/matching_repository.dart';
import 'package:upsessions/modules/musicians/models/musician_entity.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';

class MockMatchingRepository extends Mock implements MatchingRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockMusiciansRepository extends Mock implements MusiciansRepository {}
class MockUser extends Mock implements UserEntity {}
class MockMusician extends Mock implements MusicianEntity {}

void main() {
  group('MatchingCubit', () {
    late MockMatchingRepository matchingRepository;
    late MockAuthRepository authRepository;
    late MockMusiciansRepository musiciansRepository;
    late MockUser user;
    late MockMusician musician;

    setUp(() {
      matchingRepository = MockMatchingRepository();
      authRepository = MockAuthRepository();
      musiciansRepository = MockMusiciansRepository();
      user = MockUser();
      musician = MockMusician();

      when(() => user.id).thenReturn('user-1');
      when(() => musician.influences).thenReturn({'rock': ['Queen']});
    });

    blocTest<MatchingCubit, MatchingState>(
      'loadMatches emits success with matches when user has profile',
      setUp: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(() => musiciansRepository.findById('user-1')).thenAnswer((_) async => musician);
        when(() => matchingRepository.findMatches(
          myInfluences: any(named: 'myInfluences'),
          myId: 'user-1',
        )).thenAnswer((_) async => []);
      },
      build: () => MatchingCubit(
        matchingRepository: matchingRepository,
        authRepository: authRepository,
        musiciansRepository: musiciansRepository,
      ),
      act: (cubit) => cubit.loadMatches(),
      expect: () => [
        const MatchingState(status: MatchingStatus.loading),
        const MatchingState(status: MatchingStatus.success, matches: []),
      ],
    );

    blocTest<MatchingCubit, MatchingState>(
      'loadMatches emits success with empty matches when user has no profile',
      setUp: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(() => musiciansRepository.findById('user-1')).thenAnswer((_) async => null);
      },
      build: () => MatchingCubit(
        matchingRepository: matchingRepository,
        authRepository: authRepository,
        musiciansRepository: musiciansRepository,
      ),
      act: (cubit) => cubit.loadMatches(),
      expect: () => [
        const MatchingState(status: MatchingStatus.loading),
        const MatchingState(status: MatchingStatus.success, matches: []),
      ],
    );

    blocTest<MatchingCubit, MatchingState>(
      'loadMatches emits failure when not authenticated',
      setUp: () {
        when(() => authRepository.currentUser).thenReturn(null);
      },
      build: () => MatchingCubit(
        matchingRepository: matchingRepository,
        authRepository: authRepository,
        musiciansRepository: musiciansRepository,
      ),
      act: (cubit) => cubit.loadMatches(),
      expect: () => [
        const MatchingState(status: MatchingStatus.loading),
        const MatchingState(status: MatchingStatus.failure, errorMessage: 'User not authenticated'),
      ],
    );

    blocTest<MatchingCubit, MatchingState>(
        'loadMatches emits failure on error',
        setUp: () {
          when(() => authRepository.currentUser).thenReturn(user);
          when(() => musiciansRepository.findById('user-1')).thenThrow(Exception('DB Error'));
        },
        build: () => MatchingCubit(
          matchingRepository: matchingRepository,
          authRepository: authRepository,
          musiciansRepository: musiciansRepository,
        ),
        act: (cubit) => cubit.loadMatches(),
        expect: () => [
          const MatchingState(status: MatchingStatus.loading),
          const MatchingState(status: MatchingStatus.failure, errorMessage: 'Exception: DB Error'),
        ],
    );
  });
}
