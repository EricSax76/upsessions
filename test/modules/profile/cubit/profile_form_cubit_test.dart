import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/auth/models/profile_entity.dart';
import 'package:upsessions/modules/musicians/repositories/affinity_options_repository.dart';
import 'package:upsessions/modules/profile/cubit/profile_form_cubit.dart';

class MockAffinityOptionsRepository extends Mock implements AffinityOptionsRepository {}
class MockProfileEntity extends Mock implements ProfileEntity {}

void main() {
  group('ProfileFormCubit', () {
    late MockAffinityOptionsRepository affinityRepository;
    late ProfileEntity initialProfile;

    setUp(() {
      affinityRepository = MockAffinityOptionsRepository();
      initialProfile = const ProfileEntity(
        id: 'profile-1',
        name: 'Old Name',
        bio: 'Old Bio',
        location: 'Old Location',
        skills: ['Guitar'],
        links: {'instagram': '@oldname'},
        influences: {'Rock': ['Queen']},
      );
    });

    blocTest<ProfileFormCubit, ProfileFormState>(
      'initial state is correct',
      build: () => ProfileFormCubit(
        profile: initialProfile,
        affinityRepository: affinityRepository,
      ),
      verify: (cubit) {
        expect(cubit.state.bio, 'Old Bio');
        expect(cubit.state.location, 'Old Location');
        expect(cubit.state.influences, {'Rock': ['Queen']});
      },
    );

    blocTest<ProfileFormCubit, ProfileFormState>(
      'bioChanged updates bio',
      build: () => ProfileFormCubit(
        profile: initialProfile,
        affinityRepository: affinityRepository,
      ),
      act: (cubit) => cubit.bioChanged('New Bio'),
      expect: () => [
        isA<ProfileFormState>().having((s) => s.bio, 'bio', 'New Bio'),
      ],
    );

    blocTest<ProfileFormCubit, ProfileFormState>(
      'styleChanged updates selectedStyle and fetches options',
      setUp: () {
        when(() => affinityRepository.fetchArtistOptionsForStyle('Jazz'))
            .thenAnswer((_) async => ['Miles Davis', 'John Coltrane']);
      },
      build: () => ProfileFormCubit(
        profile: initialProfile,
        affinityRepository: affinityRepository,
      ),
      act: (cubit) => cubit.styleChanged('Jazz'),
      expect: () => [
        isA<ProfileFormState>()
            .having((s) => s.selectedStyle, 'selectedStyle', 'Jazz')
            .having((s) => s.isLoadingSuggestions, 'loading', false),
        isA<ProfileFormState>()
            .having((s) => s.selectedStyle, 'selectedStyle', 'Jazz')
            .having((s) => s.isLoadingSuggestions, 'loading', true),
        isA<ProfileFormState>()
            .having((s) => s.selectedStyle, 'selectedStyle', 'Jazz')
            .having((s) => s.suggestedArtists, 'suggestions', ['Miles Davis', 'John Coltrane'])
            .having((s) => s.isLoadingSuggestions, 'loading', false),
      ],
      verify: (_) {
         verify(() => affinityRepository.fetchArtistOptionsForStyle('Jazz')).called(1);
      }
    );
    // Note: The above test expectation might need adjustment based on exact emission order.
    // Implementation:
    // 1. emit(state.copyWithStyle(selectedStyle: normalized));
    // 2. emit(state.copyWith(isLoadingSuggestions: true, suggestedArtists: []));
    // 3. await fetch...
    // 4. emit(state.copyWith(suggestedArtists: options, isLoadingSuggestions: false));

    blocTest<ProfileFormCubit, ProfileFormState>(
      'styleChanged full flow',
      setUp: () {
        when(() => affinityRepository.fetchArtistOptionsForStyle('Jazz'))
            .thenAnswer((_) async => ['Miles Davis']);
      },
      build: () => ProfileFormCubit(
         profile: initialProfile,
         affinityRepository: affinityRepository,
      ),
      act: (cubit) => cubit.styleChanged('Jazz'),
      expect: () => [
        isA<ProfileFormState>().having((s) => s.selectedStyle, 'style', 'Jazz'),
        isA<ProfileFormState>().having((s) => s.isLoadingSuggestions, 'loading', true),
        isA<ProfileFormState>()
            .having((s) => s.suggestedArtists, 'suggestions', ['Miles Davis'])
            .having((s) => s.isLoadingSuggestions, 'loading', false),
      ],
    );

    blocTest<ProfileFormCubit, ProfileFormState>(
      'addInfluence adds artist to style',
      build: () => ProfileFormCubit(
        profile: initialProfile,
        affinityRepository: affinityRepository,
      ),
      seed: () => const ProfileFormState(
        selectedStyle: 'Rock',
        influences: {'Rock': ['Queen']},
      ),
      act: (cubit) => cubit.addInfluence('Bon Jovi'),
      expect: () => [
        isA<ProfileFormState>().having(
          (s) => s.influences,
          'influences',
          {'Rock': ['Queen', 'Bon Jovi']},
        ),
      ],
    );

    blocTest<ProfileFormCubit, ProfileFormState>(
      'removeInfluence removes artist',
      build: () => ProfileFormCubit(
        profile: initialProfile,
        affinityRepository: affinityRepository,
      ),
      seed: () => const ProfileFormState(
        influences: {'Rock': ['Queen', 'Bon Jovi']},
      ),
      act: (cubit) => cubit.removeInfluence('Rock', 'Queen'),
      expect: () => [
        isA<ProfileFormState>().having(
          (s) => s.influences,
          'influences',
          {'Rock': ['Bon Jovi']},
        ),
      ],
    );
     blocTest<ProfileFormCubit, ProfileFormState>(
      'removeInfluence removes style if empty',
      build: () => ProfileFormCubit(
        profile: initialProfile,
        affinityRepository: affinityRepository,
      ),
      seed: () => const ProfileFormState(
        influences: {'Rock': ['Queen']},
      ),
      act: (cubit) => cubit.removeInfluence('Rock', 'Queen'),
      expect: () => [
        isA<ProfileFormState>().having(
          (s) => s.influences,
          'influences',
          {},
        ),
      ],
    );
  });
}
