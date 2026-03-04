import 'cookie_consent_storage_stub.dart'
    if (dart.library.html) 'cookie_consent_storage_web.dart';

abstract class CookieConsentStorage {
  Future<String?> read();
  Future<void> write(String value);
}

CookieConsentStorage createCookieConsentStorage() {
  return createPlatformCookieConsentStorage();
}
