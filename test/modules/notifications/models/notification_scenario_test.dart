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
      expect(metadata.channels, contains(NotificationChannel.push));
    });

    test('all scenarios expose unique wire keys', () {
      final keys = NotificationScenario.values.map((s) => s.wireKey).toList();
      expect(keys, everyElement(matches(r'^[a-z0-9_]+$')));
      expect(keys.toSet().length, NotificationScenario.values.length);
    });

    test('wire key round-trip parses back to the same scenario', () {
      for (final scenario in NotificationScenario.values) {
        final parsed = notificationScenarioFromWireKey(scenario.wireKey);
        expect(parsed, scenario, reason: 'wireKey=${scenario.wireKey}');
      }
      expect(notificationScenarioFromWireKey('unknown_future_key'), isNull);
    });
  });
}
