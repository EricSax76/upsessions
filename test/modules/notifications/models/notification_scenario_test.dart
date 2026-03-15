import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/notifications/models/notification_scenario.dart';

void main() {
  group('NotificationScenario catalog', () {
    test('returns scenarios for every audience', () {
      for (final audience in NotificationAudience.values) {
        final scenarios = scenariosForAudience(audience);
        expect(scenarios, isNotEmpty, reason: 'audience=$audience');
      }
    });

    test('musician group invite is actionable and push-enabled', () {
      final metadata = NotificationScenario.musicianGroupInvite.metadata;
      expect(metadata.audience, NotificationAudience.musician);
      expect(metadata.actionable, isTrue);
      expect(metadata.channels, contains(NotificationChannel.push));
    });

    test('studio pending booking uses warning severity', () {
      final metadata = NotificationScenario.studioBookingPending.metadata;
      expect(metadata.audience, NotificationAudience.studio);
      expect(metadata.severity, NotificationSeverity.warning);
      expect(metadata.actionable, isTrue);
    });

    test('manager accepted request uses success severity', () {
      final metadata = NotificationScenario.managerRequestAccepted.metadata;
      expect(metadata.audience, NotificationAudience.eventManager);
      expect(metadata.severity, NotificationSeverity.success);
    });

    test('venue cancelled session uses warning severity', () {
      final metadata = NotificationScenario.venueJamSessionCancelled.metadata;
      expect(metadata.audience, NotificationAudience.venue);
      expect(metadata.severity, NotificationSeverity.warning);
    });
  });
}
