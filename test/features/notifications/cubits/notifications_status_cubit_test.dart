import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/features/notifications/repositories/invite_notifications_repository.dart';
import 'package:upsessions/features/notifications/cubits/notifications_status_cubit.dart';
import 'package:upsessions/features/notifications/models/invite_notification_entity.dart';

class MockChatRepository extends Mock implements ChatRepository {}
class MockInviteNotificationsRepository extends Mock implements InviteNotificationsRepository {}

void main() {
  late MockChatRepository mockChatRepository;
  late MockInviteNotificationsRepository mockInviteNotificationsRepository;

  setUp(() {
    mockChatRepository = MockChatRepository();
    mockInviteNotificationsRepository = MockInviteNotificationsRepository();
  });

  group('NotificationsStatusCubit', () {
    test('initial state is 0', () {
      when(() => mockChatRepository.watchUnreadTotal()).thenAnswer((_) => Stream.value(0));
      when(() => mockInviteNotificationsRepository.watchMyInvites()).thenAnswer((_) => Stream.value([]));
      
      final cubit = NotificationsStatusCubit(
        chatRepository: mockChatRepository,
        inviteNotificationsRepository: mockInviteNotificationsRepository,
      );
      expect(cubit.state, 0);
      cubit.close();
    });

    blocTest<NotificationsStatusCubit, int>(
      'emits total unread count when streams emit',
      build: () {
        when(() => mockChatRepository.watchUnreadTotal()).thenAnswer((_) => Stream.value(5));
        when(() => mockInviteNotificationsRepository.watchMyInvites()).thenAnswer((_) => Stream.value([]));
        
        return NotificationsStatusCubit(
          chatRepository: mockChatRepository,
          inviteNotificationsRepository: mockInviteNotificationsRepository,
        );
      },
      expect: () => [5],
    );

     blocTest<NotificationsStatusCubit, int>(
      'sums up chats and invites',
      build: () {
        when(() => mockChatRepository.watchUnreadTotal()).thenAnswer((_) => Stream.value(3));
        when(() => mockInviteNotificationsRepository.watchMyInvites()).thenAnswer((_) => Stream.value([
          const InviteNotificationEntity(
            id: '1', 
            groupId: 'G1', 
            groupName: 'Group 1', 
            inviteId: 'inv1', 
            createdBy: 'User A', 
            createdAt: null,
            status: 'pending',
            read: false,
          ), 
          const InviteNotificationEntity(
            id: '2', 
            groupId: 'G1', 
            groupName: 'Group 1', 
            inviteId: 'inv2', 
            createdBy: 'User A', 
            createdAt: null,
            status: 'pending',
            read: true, // Read, should not count
          ),
        ]));
        
        return NotificationsStatusCubit(
          chatRepository: mockChatRepository,
          inviteNotificationsRepository: mockInviteNotificationsRepository,
        );
      },
      expect: () => [3, 4], // 3 from chat, then +1 unread invite = 4
    );
  });
}
