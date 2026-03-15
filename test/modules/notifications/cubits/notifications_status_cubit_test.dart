import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/notifications/cubits/notifications_status_cubit.dart';
import 'package:upsessions/modules/musicians/repositories/musician_notifications_repository.dart';

class MockMusicianNotificationsRepository extends Mock
    implements MusicianNotificationsRepository {}

void main() {
  late MockMusicianNotificationsRepository mockMusicianNotificationsRepository;

  setUp(() {
    mockMusicianNotificationsRepository = MockMusicianNotificationsRepository();
  });

  group('NotificationsStatusCubit', () {
    test('initial state is 0', () {
      when(
        () => mockMusicianNotificationsRepository.watchUnreadChatsCount(),
      ).thenAnswer((_) => Stream.value(0));
      when(
        () => mockMusicianNotificationsRepository.watchUnreadInvitesCount(),
      ).thenAnswer((_) => Stream.value(0));

      final cubit = NotificationsStatusCubit(
        musicianNotificationsRepository: mockMusicianNotificationsRepository,
      );
      expect(cubit.state, 0);
      cubit.close();
    });

    blocTest<NotificationsStatusCubit, int>(
      'emits total unread count when streams emit',
      build: () {
        when(
          () => mockMusicianNotificationsRepository.watchUnreadChatsCount(),
        ).thenAnswer((_) => Stream.value(5));
        when(
          () => mockMusicianNotificationsRepository.watchUnreadInvitesCount(),
        ).thenAnswer((_) => Stream.value(0));

        return NotificationsStatusCubit(
          musicianNotificationsRepository: mockMusicianNotificationsRepository,
        );
      },
      expect: () => [5],
    );

    blocTest<NotificationsStatusCubit, int>(
      'sums up chats and invites',
      build: () {
        when(
          () => mockMusicianNotificationsRepository.watchUnreadChatsCount(),
        ).thenAnswer((_) => Stream.value(3));
        when(
          () => mockMusicianNotificationsRepository.watchUnreadInvitesCount(),
        ).thenAnswer((_) => Stream.value(1));

        return NotificationsStatusCubit(
          musicianNotificationsRepository: mockMusicianNotificationsRepository,
        );
      },
      expect: () => [3, 4],
    );
  });
}
