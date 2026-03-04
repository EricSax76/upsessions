import 'package:firebase_analytics/firebase_analytics.dart';

import 'cookie_consent_service.dart';

class AnalyticsService {
  AnalyticsService({
    required CookieConsentService cookieConsentService,
    FirebaseAnalytics? analytics,
  }) : _cookieConsentService = cookieConsentService,
       _analytics = analytics ?? FirebaseAnalytics.instance {
    _cookieConsentService.addListener(_syncConsent);
    _syncConsent();
  }

  final FirebaseAnalytics _analytics;
  final CookieConsentService _cookieConsentService;
  bool? _analyticsCollectionEnabled;

  Future<void> _syncConsent() async {
    final enabled = _cookieConsentService.analyticsEnabled;
    if (_analyticsCollectionEnabled == enabled) {
      return;
    }
    _analyticsCollectionEnabled = enabled;
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
    } catch (_) {
      // Analytics is optional; avoid blocking user flows when unavailable.
    }
  }

  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    await _syncConsent();
    if (!_cookieConsentService.analyticsEnabled) {
      return;
    }

    final sanitizedParameters = parameters?.entries
        .where((entry) => entry.value != null)
        .map((entry) => MapEntry(entry.key, entry.value as Object))
        .toList(growable: false);
    await _analytics.logEvent(
      name: name,
      parameters: sanitizedParameters == null
          ? null
          : Map<String, Object>.fromEntries(sanitizedParameters),
    );
  }

  Future<void> setUserId(String? userId) async {
    await _syncConsent();
    if (!_cookieConsentService.analyticsEnabled) {
      return;
    }
    await _analytics.setUserId(id: userId);
  }

  Future<void> setUserProperty({required String name, String? value}) async {
    await _syncConsent();
    if (!_cookieConsentService.analyticsEnabled) {
      return;
    }
    await _analytics.setUserProperty(name: name, value: value);
  }
}
