import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/messaging/models/chat_message.dart';
import 'package:upsessions/features/messaging/models/chat_thread.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/modules/announcements/cubits/announcement_detail_cubit.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  group('AnnouncementDetailCubit', () {
    late MockChatRepository chatRepository;

    setUp(() {
      chatRepository = MockChatRepository();
    });

    blocTest<AnnouncementDetailCubit, AnnouncementDetailState>(
      'contactAuthor success',
      setUp: () {
        final thread = ChatThread(
          id: 'thread-1',
          participants: const ['current-user', 'author-1'],
          participantLabels: const {
            'current-user': 'Me',
            'author-1': 'Author Name',
          },
          lastMessage: ChatMessage(
            id: 'message-1',
            sender: 'author-1',
            body: 'Hola',
            sentAt: DateTime(2024, 1, 1),
            isMine: false,
          ),
          unreadCount: 0,
        );
        when(() => chatRepository.ensureThreadWithParticipant(
          participantId: 'author-1',
          participantName: 'Author Name',
        )).thenAnswer((_) async => thread);
      },
      build: () => AnnouncementDetailCubit(chatRepository: chatRepository),
      act: (cubit) => cubit.contactAuthor(authorId: 'author-1', authorName: 'Author Name'),
      expect: () => [
        const AnnouncementDetailState(status: AnnouncementDetailStatus.contacting),
        const AnnouncementDetailState(status: AnnouncementDetailStatus.success, threadId: 'thread-1'),
      ],
    );

    blocTest<AnnouncementDetailCubit, AnnouncementDetailState>(
      'contactAuthor failure',
      setUp: () {
        when(() => chatRepository.ensureThreadWithParticipant(
          participantId: 'author-1',
          participantName: 'Author Name',
        )).thenThrow(Exception('Network error'));
      },
      build: () => AnnouncementDetailCubit(chatRepository: chatRepository),
      act: (cubit) => cubit.contactAuthor(authorId: 'author-1', authorName: 'Author Name'),
      expect: () => [
        const AnnouncementDetailState(status: AnnouncementDetailStatus.contacting),
        const AnnouncementDetailState(status: AnnouncementDetailStatus.failure, errorMessage: 'Exception: Network error'),
      ],
    );
  });
}
