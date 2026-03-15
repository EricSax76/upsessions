import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/event_manager/models/musician_request_entity.dart';
import 'package:upsessions/modules/event_manager/repositories/manager_notifications_repository.dart';
import 'package:upsessions/modules/musicians/repositories/musician_notifications_repository.dart';
import 'package:upsessions/modules/notifications/cubits/notification_center_cubit.dart';
import 'package:upsessions/modules/notifications/models/manager_request_notification_entity.dart';
import 'package:upsessions/modules/notifications/models/studio_booking_notification_entity.dart';
import 'package:upsessions/modules/notifications/models/venue_activity_notification_entity.dart';
import 'package:upsessions/modules/studios/repositories/studio_notifications_repository.dart';
import 'package:upsessions/modules/venues/repositories/venue_notifications_repository.dart';

class MockMusicianNotificationsRepository extends Mock
    implements MusicianNotificationsRepository {}

class MockStudioNotificationsRepository extends Mock
    implements StudioNotificationsRepository {}

class MockManagerNotificationsRepository extends Mock
    implements ManagerNotificationsRepository {}

class MockVenueNotificationsRepository extends Mock
    implements VenueNotificationsRepository {}

void main() {
  late MockMusicianNotificationsRepository musicianRepo;
  late MockStudioNotificationsRepository studioRepo;
  late MockManagerNotificationsRepository managerRepo;
  late MockVenueNotificationsRepository venueRepo;

  setUp(() {
    musicianRepo = MockMusicianNotificationsRepository();
    studioRepo = MockStudioNotificationsRepository();
    managerRepo = MockManagerNotificationsRepository();
    venueRepo = MockVenueNotificationsRepository();
  });

  NotificationCenterCubit buildCubit({
    required UserRole role,
    bool isVenueSession = false,
  }) {
    return NotificationCenterCubit(
      role: role,
      isVenueSession: isVenueSession,
      musicianNotificationsRepository: musicianRepo,
      studioNotificationsRepository: studioRepo,
      managerNotificationsRepository: managerRepo,
      venueNotificationsRepository: venueRepo,
    );
  }

  group('NotificationCenterCubit', () {
    test('initial state is 0', () {
      when(
        () => musicianRepo.watchUnreadChatsCount(),
      ).thenAnswer((_) => Stream.value(0));
      when(
        () => musicianRepo.watchUnreadInvitesCount(),
      ).thenAnswer((_) => Stream.value(0));

      final cubit = buildCubit(role: UserRole.musician);
      expect(cubit.state, 0);
      cubit.close();
    });

    blocTest<NotificationCenterCubit, int>(
      'musician emits total unread count when streams emit',
      build: () {
        when(
          () => musicianRepo.watchUnreadChatsCount(),
        ).thenAnswer((_) => Stream.value(5));
        when(
          () => musicianRepo.watchUnreadInvitesCount(),
        ).thenAnswer((_) => Stream.value(0));
        return buildCubit(role: UserRole.musician);
      },
      expect: () => [5],
    );

    blocTest<NotificationCenterCubit, int>(
      'musician sums chats and invites',
      build: () {
        when(
          () => musicianRepo.watchUnreadChatsCount(),
        ).thenAnswer((_) => Stream.value(3));
        when(
          () => musicianRepo.watchUnreadInvitesCount(),
        ).thenAnswer((_) => Stream.value(1));
        return buildCubit(role: UserRole.musician);
      },
      expect: () => [3, 4],
    );

    blocTest<NotificationCenterCubit, int>(
      'studio counts unread pending bookings',
      build: () {
        final bookings = [
          const StudioBookingNotificationEntity(
            id: '1',
            bookingId: 'b1',
            studioId: 's1',
            roomName: 'Room A',
            startTime: null,
            totalPrice: 0,
            status: 'pending',
            read: false,
            createdAt: null,
          ),
          const StudioBookingNotificationEntity(
            id: '2',
            bookingId: 'b2',
            studioId: 's1',
            roomName: 'Room B',
            startTime: null,
            totalPrice: 0,
            status: 'pending',
            read: true,
            createdAt: null,
          ),
        ];
        when(
          () => studioRepo.watchPendingBookings(),
        ).thenAnswer((_) => Stream.value(bookings));
        return buildCubit(role: UserRole.studio);
      },
      expect: () => [1],
    );

    blocTest<NotificationCenterCubit, int>(
      'manager counts unread requests',
      build: () {
        final requests = [
          ManagerRequestNotificationEntity(
            id: 'r1',
            message: 'msg',
            status: RequestStatus.pending,
            read: false,
            createdAt: DateTime(2026, 1, 1),
          ),
          ManagerRequestNotificationEntity(
            id: 'r2',
            message: 'msg',
            status: RequestStatus.accepted,
            read: true,
            createdAt: DateTime(2026, 1, 2),
          ),
        ];
        when(
          () => managerRepo.watchRequests(),
        ).thenAnswer((_) => Stream.value(requests));
        return buildCubit(role: UserRole.manager);
      },
      expect: () => [1],
    );

    blocTest<NotificationCenterCubit, int>(
      'venue session uses venue activity stream for manager role',
      build: () {
        final activity = [
          const VenueActivityNotificationEntity(
            id: 'a1',
            sessionId: 'j1',
            venueId: 'v1',
            title: 'Jam 1',
            date: null,
            city: 'Madrid',
            isPublic: true,
            isCanceled: false,
            createdAt: null,
          ),
          const VenueActivityNotificationEntity(
            id: 'a2',
            sessionId: 'j2',
            venueId: 'v1',
            title: 'Jam 2',
            date: null,
            city: 'Madrid',
            isPublic: true,
            isCanceled: false,
            createdAt: null,
          ),
        ];
        when(
          () => venueRepo.watchVenueActivity(),
        ).thenAnswer((_) => Stream.value(activity));
        return buildCubit(role: UserRole.manager, isVenueSession: true);
      },
      expect: () => [2],
    );

    blocTest<NotificationCenterCubit, int>(
      'admin emits no unread updates',
      build: () => buildCubit(role: UserRole.admin),
      expect: () => <int>[],
      verify: (cubit) => expect(cubit.state, 0),
    );
  });
}
