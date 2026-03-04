// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

import 'cookie_consent_storage.dart';

const String _consentStorageKey = 'upsessions_cookie_consent_v1';

class _WebCookieConsentStorage implements CookieConsentStorage {
  @override
  Future<String?> read() async {
    return html.window.localStorage[_consentStorageKey];
  }

  @override
  Future<void> write(String value) async {
    html.window.localStorage[_consentStorageKey] = value;
  }
}

CookieConsentStorage createPlatformCookieConsentStorage() {
  return _WebCookieConsentStorage();
}
