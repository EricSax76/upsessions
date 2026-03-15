import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/notifications/models/quiet_hours_config.dart';

void main() {
  group('QuietHoursConfig', () {
    test('fromMap falls back to UTC when timezone is missing', () {
      final config = QuietHoursConfig.fromMap({
        'enabled': true,
        'startHour': 22,
        'endHour': 8,
      });

      expect(config.timezone, 'UTC');
    });

    test('evaluates quiet hours using configured IANA timezone', () {
      final config = QuietHoursConfig(
        enabled: true,
        startHour: 22,
        endHour: 8,
        timezone: 'Europe/Madrid',
      );

      final nowUtc = DateTime.utc(2026, 1, 15, 21, 30); // 22:30 in Madrid.
      expect(config.isQuiet(nowUtc), isTrue);
    });

    test('handles overnight ranges with local hour in configured timezone', () {
      final config = QuietHoursConfig(
        enabled: true,
        startHour: 22,
        endHour: 8,
        timezone: 'Europe/Madrid',
      );

      final nowUtc = DateTime.utc(2026, 1, 15, 7, 30); // 08:30 in Madrid.
      expect(config.isQuiet(nowUtc), isFalse);
    });

    test('falls back to UTC when timezone is invalid', () {
      final config = QuietHoursConfig(
        enabled: true,
        startHour: 22,
        endHour: 8,
        timezone: 'Invalid/Timezone',
      );

      final nowUtc = DateTime.utc(2026, 1, 15, 23, 0);
      expect(config.isQuiet(nowUtc), isTrue);
    });
  });
}
