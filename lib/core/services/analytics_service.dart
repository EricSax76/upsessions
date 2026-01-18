import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  const AnalyticsService();

  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) {
    final sanitizedParameters = parameters?.entries
        .where((entry) => entry.value != null)
        .map((entry) => MapEntry(entry.key, entry.value as Object))
        .toList(growable: false);
    return _analytics.logEvent(
      name: name,
      parameters: sanitizedParameters == null
          ? null
          : Map<String, Object>.fromEntries(sanitizedParameters),
    );
  }

  Future<void> setUserId(String? userId) {
    return _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty({
    required String name,
    String? value,
  }) {
    return _analytics.setUserProperty(name: name, value: value);
  }
}
