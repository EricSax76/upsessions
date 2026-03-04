import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/core/services/analytics_service.dart';
import 'package:upsessions/core/services/cookie_consent_service.dart';
import 'package:upsessions/core/services/cookie_consent_storage.dart';
import 'package:upsessions/core/widgets/legal/cookie_consent_layer.dart';

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
  group('CookieConsentLayer web e2e flow', () {
    late _MockFirebaseAnalytics analytics;
    late CookieConsentService consentService;
    late AnalyticsService analyticsService;

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
      analyticsService = AnalyticsService(
        cookieConsentService: consentService,
        analytics: analytics,
      );
    });

    Future<void> pumpCmp(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CookieConsentLayer(
            cookieConsentService: consentService,
            isWebOverride: true,
            child: const Scaffold(body: Center(child: Text('Home test'))),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'banner -> reject -> re-enable analytics -> revoke and block events',
      (tester) async {
        await pumpCmp(tester);

        expect(find.textContaining('Usamos cookies'), findsOneWidget);
        expect(find.text('Rechazar'), findsOneWidget);
        expect(find.text('Privacidad y cookies'), findsOneWidget);

        await tester.tap(find.text('Rechazar'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Usamos cookies'), findsNothing);

        await analyticsService.logEvent(name: 'event_after_reject');
        verify(() => analytics.setAnalyticsCollectionEnabled(false)).called(1);
        verifyNever(
          () => analytics.logEvent(
            name: 'event_after_reject',
            parameters: any(named: 'parameters'),
          ),
        );

        await tester.tap(find.text('Privacidad y cookies'));
        await tester.pumpAndSettle();

        final analyticsTile = find.widgetWithText(
          SwitchListTile,
          'Cookies analíticas',
        );
        expect(analyticsTile, findsOneWidget);
        await tester.tap(analyticsTile);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Guardar selección'));
        await tester.pumpAndSettle();

        await analyticsService.logEvent(name: 'event_after_opt_in');
        verify(() => analytics.setAnalyticsCollectionEnabled(true)).called(1);
        verify(
          () => analytics.logEvent(
            name: 'event_after_opt_in',
            parameters: any(named: 'parameters'),
          ),
        ).called(1);

        await tester.tap(find.text('Privacidad y cookies'));
        await tester.pumpAndSettle();

        final analyticsTileRevoke = find.widgetWithText(
          SwitchListTile,
          'Cookies analíticas',
        );
        await tester.tap(analyticsTileRevoke);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Guardar selección'));
        await tester.pumpAndSettle();

        await analyticsService.logEvent(name: 'event_after_revoke');
        verify(() => analytics.setAnalyticsCollectionEnabled(false)).called(1);
        verifyNever(
          () => analytics.logEvent(
            name: 'event_after_revoke',
            parameters: any(named: 'parameters'),
          ),
        );
      },
    );
  });
}
