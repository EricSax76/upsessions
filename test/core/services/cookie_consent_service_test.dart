import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/core/services/cookie_consent_service.dart';
import 'package:upsessions/core/services/cookie_consent_storage.dart';

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
  group('CookieConsentService', () {
    test(
      'starts with no optional consent and shows banner after init',
      () async {
        final storage = _InMemoryCookieConsentStorage();
        final service = CookieConsentService(storage: storage);

        expect(service.isInitialized, isFalse);
        expect(service.hasMadeChoice, isFalse);

        await service.init();

        expect(service.isInitialized, isTrue);
        expect(service.hasMadeChoice, isFalse);
        expect(service.shouldShowBanner, isTrue);
        expect(service.preferences.necessary, isTrue);
        expect(service.preferences.analytics, isFalse);
        expect(service.preferences.preferences, isFalse);
        expect(service.preferences.marketing, isFalse);
      },
    );

    test('acceptAll persists and hides banner', () async {
      final storage = _InMemoryCookieConsentStorage();
      final service = CookieConsentService(storage: storage);

      await service.init();
      await service.acceptAll();

      expect(service.hasMadeChoice, isTrue);
      expect(service.shouldShowBanner, isFalse);
      expect(service.preferences.analytics, isTrue);
      expect(service.preferences.preferences, isTrue);
      expect(service.preferences.marketing, isTrue);

      final saved = await storage.read();
      expect(saved, contains('"hasMadeChoice":true'));
      expect(saved, contains('"analytics":true'));
      expect(saved, contains('"preferences":true'));
      expect(saved, contains('"marketing":true'));
    });

    test('loads an existing stored selection', () async {
      final storage = _InMemoryCookieConsentStorage();
      await storage.write(
        '{"hasMadeChoice":true,"necessary":true,"analytics":false,"preferences":true,"marketing":false,"updatedAt":"2026-03-04T00:00:00.000Z"}',
      );

      final service = CookieConsentService(storage: storage);
      await service.init();

      expect(service.hasMadeChoice, isTrue);
      expect(service.shouldShowBanner, isFalse);
      expect(service.preferences.analytics, isFalse);
      expect(service.preferences.preferences, isTrue);
      expect(service.preferences.marketing, isFalse);
    });
  });
}
