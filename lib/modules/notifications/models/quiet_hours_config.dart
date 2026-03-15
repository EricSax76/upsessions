import 'package:equatable/equatable.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Timezone-aware quiet-hours preference.
///
/// Mirror of QuietHours in functions/src/notifications/quietHours.ts.
/// Both sides must produce identical results for the same document values.
///
/// Schema (Firestore field "quietHours"):
///   enabled:   bool
///   startHour: int  0–23  (inclusive start)
///   endHour:   int  0–23  (exclusive end)
///   timezone:  String  IANA identifier, e.g. "Europe/Madrid"
class QuietHoursConfig extends Equatable {
  const QuietHoursConfig({
    required this.enabled,
    required this.startHour,
    required this.endHour,
    required this.timezone,
  }) : assert(startHour >= 0 && startHour <= 23),
       assert(endHour >= 0 && endHour <= 23);

  final bool enabled;

  /// Inclusive start of quiet period. Integer 0–23.
  final int startHour;

  /// Exclusive end of quiet period. Integer 0–23.
  final int endHour;

  /// IANA timezone identifier. Defaults to "UTC" when absent in Firestore.
  final String timezone;

  static const QuietHoursConfig defaults = QuietHoursConfig(
    enabled: false,
    startHour: 22,
    endHour: 8,
    timezone: 'UTC',
  );

  static bool _timeZonesReady = false;

  // -------------------------------------------------------------------------
  // Serialisation
  // -------------------------------------------------------------------------

  factory QuietHoursConfig.fromMap(Map<String, dynamic> map) {
    final startHour = _clampHour(map['startHour']);
    final endHour = _clampHour(map['endHour']);
    final rawTz = map['timezone'];
    final timezone = (rawTz is String && rawTz.trim().isNotEmpty)
        ? rawTz.trim()
        : 'UTC';

    return QuietHoursConfig(
      enabled: map['enabled'] == true,
      startHour: startHour,
      endHour: endHour,
      timezone: timezone,
    );
  }

  Map<String, dynamic> toMap() => {
    'enabled': enabled,
    'startHour': startHour,
    'endHour': endHour,
    'timezone': timezone,
  };

  // -------------------------------------------------------------------------
  // Quiet-hours check
  //
  // Mirror of isQuiet() in functions/src/notifications/quietHours.ts.
  // -------------------------------------------------------------------------

  /// Returns true if [now] falls within this quiet period.
  ///
  /// Supports overnight ranges: startHour=22, endHour=8 means
  /// "quiet from 22:00 until 08:00 the next morning".
  bool isQuiet([DateTime? now]) {
    if (!enabled) return false;
    if (startHour == endHour) return false; // degenerate: no quiet period

    final h = _localHour(timezone, now ?? DateTime.now());

    // Same-day range: e.g. 02–06
    if (startHour < endHour) {
      return h >= startHour && h < endHour;
    }

    // Overnight range: e.g. 22–08 → quiet if h ≥ 22 OR h < 8
    return h >= startHour || h < endHour;
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  QuietHoursConfig copyWith({
    bool? enabled,
    int? startHour,
    int? endHour,
    String? timezone,
  }) => QuietHoursConfig(
    enabled: enabled ?? this.enabled,
    startHour: startHour ?? this.startHour,
    endHour: endHour ?? this.endHour,
    timezone: timezone ?? this.timezone,
  );

  static int _clampHour(dynamic value) {
    if (value is! num) return 0;
    return value.toInt().clamp(0, 23);
  }

  static int _localHour(String timezone, DateTime now) {
    _ensureTimeZonesReady();
    try {
      final location = tz.getLocation(timezone);
      return tz.TZDateTime.from(now.toUtc(), location).hour;
    } catch (_) {
      return now.toUtc().hour;
    }
  }

  static void _ensureTimeZonesReady() {
    if (_timeZonesReady) return;
    tz_data.initializeTimeZones();
    _timeZonesReady = true;
  }

  @override
  List<Object?> get props => [enabled, startHour, endHour, timezone];
}
