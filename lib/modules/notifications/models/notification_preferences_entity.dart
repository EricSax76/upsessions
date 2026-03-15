import 'notification_scenario.dart';
import 'quiet_hours_config.dart';

class NotificationPreferencesEntity {
  const NotificationPreferencesEntity({
    required this.scenarioChannels,
    required this.quietHours,
  });

  static const NotificationPreferencesEntity defaults =
      NotificationPreferencesEntity(
        scenarioChannels: <String, Map<String, bool>>{},
        quietHours: QuietHoursConfig.defaults,
      );

  /// Key: NotificationScenario.wireKey
  /// Value: channel map ('inApp' | 'push' | 'email') -> enabled
  final Map<String, Map<String, bool>> scenarioChannels;
  final QuietHoursConfig quietHours;

  bool isChannelEnabled(
    NotificationScenario scenario,
    NotificationChannel channel,
  ) {
    // If the scenario does not support this channel in metadata, force false.
    if (!scenario.metadata.channels.contains(channel)) {
      return false;
    }

    final scenarioMap = scenarioChannels[scenario.wireKey];
    if (scenarioMap == null) {
      // Default opt-in for supported channels when no preference was saved.
      return true;
    }
    return scenarioMap[channelFieldName(channel)] ?? true;
  }

  bool get quietHoursEnabled => quietHours.enabled;
  int get quietStartHour => quietHours.startHour;
  int get quietEndHour => quietHours.endHour;
  bool get isCurrentlyQuiet => quietHours.isQuiet();

  NotificationPreferencesEntity copyWith({
    Map<String, Map<String, bool>>? scenarioChannels,
    QuietHoursConfig? quietHours,
  }) {
    return NotificationPreferencesEntity(
      scenarioChannels: scenarioChannels ?? this.scenarioChannels,
      quietHours: quietHours ?? this.quietHours,
    );
  }

  factory NotificationPreferencesEntity.fromFirestore(
    Map<String, dynamic>? data,
  ) {
    if (data == null) return defaults;

    final rawScenarios = data['scenarios'];
    final scenarios = <String, Map<String, bool>>{};
    if (rawScenarios is Map) {
      rawScenarios.forEach((key, value) {
        if (key is! String || value is! Map) return;
        final channels = <String, bool>{};
        final rawInApp = value['inApp'];
        final rawPush = value['push'];
        final rawEmail = value['email'];
        if (rawInApp is bool) channels['inApp'] = rawInApp;
        if (rawPush is bool) channels['push'] = rawPush;
        if (rawEmail is bool) channels['email'] = rawEmail;
        scenarios[key] = channels;
      });
    }

    final rawQuietHours = data['quietHours'];
    final quietHours = rawQuietHours is Map<String, dynamic>
        ? QuietHoursConfig.fromMap(rawQuietHours)
        : (rawQuietHours is Map
              ? QuietHoursConfig.fromMap(
                  Map<String, dynamic>.from(rawQuietHours),
                )
              : QuietHoursConfig.defaults);

    return NotificationPreferencesEntity(
      scenarioChannels: scenarios,
      quietHours: quietHours,
    );
  }

  static String channelFieldName(NotificationChannel channel) {
    return switch (channel) {
      NotificationChannel.inApp => 'inApp',
      NotificationChannel.push => 'push',
      NotificationChannel.email => 'email',
    };
  }
}
