import 'cookie_consent_storage.dart';

String? _cachedConsentValue;

class _InMemoryCookieConsentStorage implements CookieConsentStorage {
  @override
  Future<String?> read() async {
    return _cachedConsentValue;
  }

  @override
  Future<void> write(String value) async {
    _cachedConsentValue = value;
  }
}

CookieConsentStorage createPlatformCookieConsentStorage() {
  return _InMemoryCookieConsentStorage();
}
