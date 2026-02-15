import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:upsessions/modules/musicians/cubits/musician_detail_cubit.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/musicians/models/musician_entity.dart';
import 'package:upsessions/features/messaging/models/chat_thread.dart';
import 'package:upsessions/features/messaging/models/chat_message.dart';

class _MockChatRepository extends Mock implements ChatRepository {}
class _MockGroupsRepository extends Mock implements GroupsRepository {}

void main() {
  late _MockChatRepository chatRepository;
  late _MockGroupsRepository groupsRepository;

  const mockMusician = MusicianEntity(
    id: '1',
    ownerId: 'owner-1',
    name: 'Test Musician',
    instrument: 'Bass',
    city: 'CDMX',
    styles: ['Jazz'],
    experienceYears: 5,
  );

  setUp(() {
    chatRepository = _MockChatRepository();
    groupsRepository = _MockGroupsRepository();
  });

  group('MusicianDetailCubit', () {
    blocTest<MusicianDetailCubit, MusicianDetailState>(
      'emit contact success with threadId on successful contact',
      build: () {
        when(() => chatRepository.ensureThreadWithParticipant(
          participantId: 'owner-1',
          participantName: 'Test Musician',
        )).thenAnswer((_) async => ChatThread(
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
        ));
        return MusicianDetailCubit(
          chatRepository: chatRepository,
          groupsRepository: groupsRepository,
        );
      },
      act: (cubit) => cubit.contactMusician(mockMusician),
      expect: () => [
        const MusicianDetailContacting(),
        const MusicianDetailContactSuccess('thread-123'),
      ],
      verify: (cubit) {
        verify(() => chatRepository.ensureThreadWithParticipant(
          participantId: 'owner-1',
          participantName: 'Test Musician',
        )).called(1);
      },
    );

    blocTest<MusicianDetailCubit, MusicianDetailState>(
      'emit contact error on failure',
      build: () {
        when(() => chatRepository.ensureThreadWithParticipant(
          participantId: any(named: 'participantId'),
          participantName: any(named: 'participantName'),
        )).thenThrow(Exception('Network error'));
        return MusicianDetailCubit(
          chatRepository: chatRepository,
          groupsRepository: groupsRepository,
        );
      },
      act: (cubit) => cubit.contactMusician(mockMusician),
      expect: () => [
        const MusicianDetailContacting(),
        const MusicianDetailError('Exception: Network error'),
      ],
    );

    test('getParticipantId returns ownerId if present', () {
      final cubit = MusicianDetailCubit(
        chatRepository: chatRepository,
        groupsRepository: groupsRepository,
      );
      expect(cubit.getParticipantId(mockMusician), 'owner-1');
    });

    test('getParticipantId returns id if ownerId is empty', () {
      final cubit = MusicianDetailCubit(
        chatRepository: chatRepository,
        groupsRepository: groupsRepository,
      );
      const musicianNoOwner = MusicianEntity(
        id: 'user-123',
        ownerId: '',
        name: 'Test',
        instrument: 'Drums',
        city: 'CDMX',
        styles: [],
        experienceYears: 1,
      );
      expect(cubit.getParticipantId(musicianNoOwner), 'user-123');
    });
  });
}
