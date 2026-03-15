import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:upsessions/features/messaging/models/chat_message.dart';
import 'package:upsessions/features/messaging/models/chat_thread.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/musicians/cubits/musician_detail_cubit.dart';
import 'package:upsessions/modules/musicians/models/artist_image_info.dart';
import 'package:upsessions/modules/musicians/models/musician_compliance_info.dart';
import 'package:upsessions/modules/musicians/models/musician_entity.dart';
import 'package:upsessions/modules/musicians/models/musician_professional_info.dart';
import 'package:upsessions/modules/musicians/repositories/artist_image_repository.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

class _MockGroupsRepository extends Mock implements GroupsRepository {}

class _MockMusiciansRepository extends Mock implements MusiciansRepository {}

class _MockArtistImageRepository extends Mock
    implements ArtistImageRepository {}

void main() {
  late _MockChatRepository chatRepository;
  late _MockGroupsRepository groupsRepository;
  late _MockMusiciansRepository musiciansRepository;
  late _MockArtistImageRepository artistImageRepository;

  final mockMusician = MusicianEntity(
    id: '1',
    ownerId: 'owner-1',
    name: 'Test Musician',
    instrument: 'Bass',
    city: 'CDMX',
    styles: ['Jazz'],
    experienceYears: 5,
    compliance: MusicianComplianceInfo(updatedAt: DateTime.now()),
    professional: const MusicianProfessionalInfo(),
    influences: const {
      'Rock': ['Muse', 'Radiohead'],
      'Alternative': [' radiohead ', 'Muse', ''],
    },
  );

  MusicianDetailCubit buildCubit() {
    return MusicianDetailCubit(
      chatRepository: chatRepository,
      groupsRepository: groupsRepository,
      musiciansRepository: musiciansRepository,
      artistImageRepository: artistImageRepository,
    );
  }

  setUp(() {
    chatRepository = _MockChatRepository();
    groupsRepository = _MockGroupsRepository();
    musiciansRepository = _MockMusiciansRepository();
    artistImageRepository = _MockArtistImageRepository();
  });

  group('MusicianDetailCubit', () {
    blocTest<MusicianDetailCubit, MusicianDetailState>(
      'loadMusician loads profile and resolves deduplicated affinities',
      build: () {
        when(() => musiciansRepository.findById('1')).thenAnswer(
          (_) async => mockMusician.copyWith(name: 'Loaded Musician'),
        );
        when(() => artistImageRepository.resolveArtists(any())).thenAnswer((
          _,
        ) async {
          return const {
            'muse': ArtistImageInfo(
              imageUrl: 'https://img.muse',
              spotifyUrl: 'https://spotify.muse',
            ),
            'radiohead': ArtistImageInfo(
              imageUrl: 'https://img.radiohead',
              spotifyUrl: 'https://spotify.radiohead',
            ),
          };
        });
        return buildCubit();
      },
      act: (cubit) => cubit.loadMusician(mockMusician, currentUserId: 'viewer'),
      expect: () => [
        isA<MusicianDetailState>()
            .having((state) => state.isLoading, 'isLoading', true)
            .having((state) => state.currentUserId, 'currentUserId', 'viewer')
            .having((state) => state.isOwnProfile, 'isOwnProfile', false)
            .having(
              (state) => state.musician?.name,
              'musician.name',
              'Test Musician',
            ),
        isA<MusicianDetailState>()
            .having((state) => state.isLoading, 'isLoading', false)
            .having(
              (state) => state.musician?.name,
              'musician.name',
              'Loaded Musician',
            ),
        isA<MusicianDetailState>().having(
          (state) => state.areAffinityArtistsLoading,
          'areAffinityArtistsLoading',
          true,
        ),
        isA<MusicianDetailState>()
            .having(
              (state) => state.areAffinityArtistsLoading,
              'areAffinityArtistsLoading',
              false,
            )
            .having(
              (state) => state.spotifyAffinityByArtist.length,
              'spotifyAffinityByArtist.length',
              2,
            ),
      ],
      verify: (_) {
        verify(() => musiciansRepository.findById('1')).called(1);

        final captured =
            verify(
                  () => artistImageRepository.resolveArtists(captureAny()),
                ).captured.single
                as Iterable<String>;

        final normalized = captured
            .map((artist) => artist.trim().toLowerCase())
            .where((artist) => artist.isNotEmpty)
            .toSet();
        expect(normalized, {'muse', 'radiohead'});
        expect(captured.length, 2);
      },
    );

    blocTest<MusicianDetailCubit, MusicianDetailState>(
      'reuses affinity cache across loads with same influence set',
      build: () {
        when(
          () => musiciansRepository.findById(any()),
        ).thenAnswer((_) async => mockMusician);
        when(
          () => artistImageRepository.resolveArtists(any()),
        ).thenAnswer((_) async => const <String, ArtistImageInfo>{});
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadMusician(mockMusician, currentUserId: 'viewer');
        await cubit.loadMusician(mockMusician, currentUserId: 'viewer');
      },
      verify: (_) {
        verify(() => artistImageRepository.resolveArtists(any())).called(1);
      },
    );

    test('isOwnProfile resolves permission by ownerId or musician id', () {
      final cubit = buildCubit();
      expect(cubit.isOwnProfile(mockMusician, 'owner-1'), isTrue);
      expect(cubit.isOwnProfile(mockMusician, '1'), isTrue);
      expect(cubit.isOwnProfile(mockMusician, 'viewer'), isFalse);
      expect(cubit.isOwnProfile(mockMusician, ''), isFalse);
    });

    test('loadMusician computes isOwnProfile into state', () async {
      when(
        () => musiciansRepository.findById('1'),
      ).thenAnswer((_) async => mockMusician);
      when(
        () => artistImageRepository.resolveArtists(any()),
      ).thenAnswer((_) async => const <String, ArtistImageInfo>{});

      final cubit = buildCubit();
      await cubit.loadMusician(mockMusician, currentUserId: 'owner-1');
      expect(cubit.state.isOwnProfile, isTrue);
    });

    blocTest<MusicianDetailCubit, MusicianDetailState>(
      'emit contact error and skip repository when trying to contact yourself',
      build: () => buildCubit(),
      act: (cubit) =>
          cubit.contactMusician(mockMusician, currentUserId: 'owner-1'),
      expect: () => [
        isA<MusicianDetailState>()
            .having((state) => state.isContacting, 'isContacting', false)
            .having(
              (state) => state.contactErrorMessage,
              'contactErrorMessage',
              'No puedes iniciar un chat contigo mismo.',
            ),
      ],
      verify: (_) {
        verifyNever(
          () => chatRepository.ensureThreadWithParticipant(
            participantId: any(named: 'participantId'),
            participantName: any(named: 'participantName'),
          ),
        );
      },
    );

    blocTest<MusicianDetailCubit, MusicianDetailState>(
      'emit navigateToThreadId on successful contact',
      build: () {
        when(
          () => chatRepository.ensureThreadWithParticipant(
            participantId: 'owner-1',
            participantName: 'Test Musician',
          ),
        ).thenAnswer(
          (_) async => ChatThread(
            id: 'thread-123',
            participants: const [],
            participantLabels: const {},
            lastMessage: ChatMessage(
              id: 'msg-1',
              sender: 'sender',
              body: 'body',
              sentAt: DateTime.now(),
            ),
            unreadCount: 0,
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.contactMusician(mockMusician),
      expect: () => [
        isA<MusicianDetailState>()
            .having((state) => state.isContacting, 'isContacting', true)
            .having(
              (state) => state.contactErrorMessage,
              'contactErrorMessage',
              isNull,
            )
            .having(
              (state) => state.navigateToThreadId,
              'navigateToThreadId',
              isNull,
            ),
        isA<MusicianDetailState>()
            .having((state) => state.isContacting, 'isContacting', false)
            .having(
              (state) => state.navigateToThreadId,
              'navigateToThreadId',
              'thread-123',
            ),
      ],
      verify: (_) {
        verify(
          () => chatRepository.ensureThreadWithParticipant(
            participantId: 'owner-1',
            participantName: 'Test Musician',
          ),
        ).called(1);
      },
    );

    blocTest<MusicianDetailCubit, MusicianDetailState>(
      'emit contact error on failure',
      build: () {
        when(
          () => chatRepository.ensureThreadWithParticipant(
            participantId: any(named: 'participantId'),
            participantName: any(named: 'participantName'),
          ),
        ).thenThrow(Exception('Network error'));
        return buildCubit();
      },
      act: (cubit) => cubit.contactMusician(mockMusician),
      expect: () => [
        isA<MusicianDetailState>().having(
          (state) => state.isContacting,
          'isContacting',
          true,
        ),
        isA<MusicianDetailState>()
            .having((state) => state.isContacting, 'isContacting', false)
            .having(
              (state) => state.contactErrorMessage,
              'contactErrorMessage',
              'Exception: Network error',
            ),
      ],
    );

    test('getParticipantId returns ownerId if present', () {
      final cubit = buildCubit();
      expect(cubit.getParticipantId(mockMusician), 'owner-1');
    });

    test('getParticipantId returns id if ownerId is empty', () {
      final cubit = buildCubit();
      final musicianNoOwner = MusicianEntity(
        id: 'user-123',
        ownerId: '',
        name: 'Test',
        instrument: 'Drums',
        city: 'CDMX',
        styles: const [],
        experienceYears: 1,
        compliance: MusicianComplianceInfo(updatedAt: DateTime.now()),
        professional: const MusicianProfessionalInfo(),
      );
      expect(cubit.getParticipantId(musicianNoOwner), 'user-123');
    });
  });
}
