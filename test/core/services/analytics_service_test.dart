import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/core/services/analytics_service.dart';
import 'package:upsessions/core/services/cookie_consent_service.dart';
import 'package:upsessions/core/services/cookie_consent_storage.dart';

class _MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class _InMemoryCookieConsentStorage implements CookieConsentStorage {
  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String value) async {
    _value = value;
  }
}

void main() {
  group('AnalyticsService consent gate', () {
    late _MockFirebaseAnalytics analytics;
    late CookieConsentService consentService;

    setUp(() async {
      analytics = _MockFirebaseAnalytics();
      when(
        () => analytics.setAnalyticsCollectionEnabled(any()),
      ).thenAnswer((_) async {});
      when(
        () => analytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async {});

      consentService = CookieConsentService(
        storage: _InMemoryCookieConsentStorage(),
      );
      await consentService.init();
    });

    test('keeps analytics disabled and blocks events before opt-in', () async {
      final service = AnalyticsService(
        cookieConsentService: consentService,
        analytics: analytics,
      );

      await service.logEvent(name: 'pre_consent_event');

      verify(() => analytics.setAnalyticsCollectionEnabled(false)).called(1);
      verifyNever(
        () => analytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      );
    });

    test('stops logging after revocation', () async {
      await consentService.acceptAll();
      final service = AnalyticsService(
        cookieConsentService: consentService,
        analytics: analytics,
      );

      await service.logEvent(name: 'before_revoke');
      await consentService.saveSelection(
        analytics: false,
        preferences: true,
        marketing: false,
      );
      await service.logEvent(name: 'after_revoke');

      verify(() => analytics.setAnalyticsCollectionEnabled(true)).called(1);
      verify(() => analytics.setAnalyticsCollectionEnabled(false)).called(1);
      verify(
        () => analytics.logEvent(
          name: 'before_revoke',
          parameters: any(named: 'parameters'),
        ),
      ).called(1);
      verifyNever(
        () => analytics.logEvent(
          name: 'after_revoke',
          parameters: any(named: 'parameters'),
        ),
      );
    });
  });
}
