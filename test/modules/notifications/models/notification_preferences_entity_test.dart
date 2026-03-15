import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/notifications/models/notification_preferences_entity.dart';
import 'package:upsessions/modules/notifications/models/notification_scenario.dart';

void main() {
  group('NotificationPreferencesEntity', () {
    test(
      'defaults to enabled for supported channels when no overrides exist',
      () {
        const prefs = NotificationPreferencesEntity.defaults;

        expect(
          prefs.isChannelEnabled(
            NotificationScenario.studioBookingPending,
            NotificationChannel.push,
          ),
          isTrue,
        );
        expect(
          prefs.isChannelEnabled(
            NotificationScenario.studioBookingPending,
            NotificationChannel.email,
          ),
          isTrue,
        );
      },
    );

    test('forces false for channels not supported by metadata', () {
      const prefs = NotificationPreferencesEntity.defaults;

      expect(
        prefs.isChannelEnabled(
          NotificationScenario.studioBookingConfirmed,
          NotificationChannel.push,
        ),
        isFalse,
      );
      expect(
        prefs.isChannelEnabled(
          NotificationScenario.studioBookingConfirmed,
          NotificationChannel.email,
        ),
        isFalse,
      );
    });

    test('applies Firestore overrides for specific scenario/channel', () {
      final prefs = NotificationPreferencesEntity.fromFirestore({
        'scenarios': {
          'studio_booking_pending': {'push': false, 'email': true},
        },
      });

      expect(
        prefs.isChannelEnabled(
          NotificationScenario.studioBookingPending,
          NotificationChannel.push,
        ),
        isFalse,
      );
      expect(
        prefs.isChannelEnabled(
          NotificationScenario.studioBookingPending,
          NotificationChannel.email,
        ),
        isTrue,
      );
      expect(
        prefs.isChannelEnabled(
          NotificationScenario.studioBookingPending,
          NotificationChannel.inApp,
        ),
        isTrue,
      );
    });

    test('exposes quiet-hours getters from config', () {
      final prefs = NotificationPreferencesEntity.fromFirestore({
        'quietHours': {
          'enabled': true,
          'startHour': 22,
          'endHour': 8,
          'timezone': 'Europe/Madrid',
        },
      });

      expect(prefs.quietHoursEnabled, isTrue);
      expect(prefs.quietStartHour, 22);
      expect(prefs.quietEndHour, 8);
      expect(prefs.isCurrentlyQuiet, isA<bool>());
    });
  });
}
