import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'cookie_consent_storage.dart';

@immutable
class CookieConsentPreferences {
  const CookieConsentPreferences({
    this.necessary = true,
    this.analytics = false,
    this.preferences = false,
    this.marketing = false,
    this.updatedAtIso8601,
  });

  final bool necessary;
  final bool analytics;
  final bool preferences;
  final bool marketing;
  final String? updatedAtIso8601;

  CookieConsentPreferences copyWith({
    bool? analytics,
    bool? preferences,
    bool? marketing,
    String? updatedAtIso8601,
  }) {
    return CookieConsentPreferences(
      necessary: true,
      analytics: analytics ?? this.analytics,
      preferences: preferences ?? this.preferences,
      marketing: marketing ?? this.marketing,
      updatedAtIso8601: updatedAtIso8601 ?? this.updatedAtIso8601,
    );
  }

  Map<String, Object?> toJson({required bool hasMadeChoice}) {
    return <String, Object?>{
      'hasMadeChoice': hasMadeChoice,
      'necessary': true,
      'analytics': analytics,
      'preferences': preferences,
      'marketing': marketing,
      'updatedAt': updatedAtIso8601,
    };
  }

  static CookieConsentPreferences fromJson(Map<String, Object?> json) {
    return CookieConsentPreferences(
      necessary: true,
      analytics: json['analytics'] == true,
      preferences: json['preferences'] == true,
      marketing: json['marketing'] == true,
      updatedAtIso8601: json['updatedAt'] as String?,
    );
  }
}

class CookieConsentService extends ChangeNotifier {
  CookieConsentService({required CookieConsentStorage storage})
    : _storage = storage;

  final CookieConsentStorage _storage;
  CookieConsentPreferences _preferences = const CookieConsentPreferences();
  bool _initialized = false;
  bool _hasMadeChoice = false;

  bool get isInitialized => _initialized;
  bool get hasMadeChoice => _hasMadeChoice;
  bool get shouldShowBanner => _initialized && !_hasMadeChoice;
  CookieConsentPreferences get preferences => _preferences;
  bool get analyticsEnabled => _preferences.analytics;
  bool get marketingEnabled => _preferences.marketing;
  bool get preferencesEnabled => _preferences.preferences;

  Future<void> init() async {
    if (_initialized) return;

    try {
      final raw = await _storage.read();
      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _preferences = CookieConsentPreferences.fromJson(
            decoded.cast<String, Object?>(),
          );
          _hasMadeChoice = decoded['hasMadeChoice'] == true;
        }
      }
    } catch (_) {
      _preferences = const CookieConsentPreferences();
      _hasMadeChoice = false;
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> acceptAll() {
    return _save(
      _preferences.copyWith(
        analytics: true,
        preferences: true,
        marketing: true,
      ),
      hasMadeChoice: true,
    );
  }

  Future<void> rejectOptional() {
    return _save(
      _preferences.copyWith(
        analytics: false,
        preferences: false,
        marketing: false,
      ),
      hasMadeChoice: true,
    );
  }

  Future<void> saveSelection({
    required bool analytics,
    required bool preferences,
    required bool marketing,
  }) {
    return _save(
      _preferences.copyWith(
        analytics: analytics,
        preferences: preferences,
        marketing: marketing,
      ),
      hasMadeChoice: true,
    );
  }

  Future<void> _save(
    CookieConsentPreferences next, {
    required bool hasMadeChoice,
  }) async {
    final updated = next.copyWith(
      updatedAtIso8601: DateTime.now().toUtc().toIso8601String(),
    );
    _preferences = updated;
    _hasMadeChoice = hasMadeChoice;

    final payload = jsonEncode(updated.toJson(hasMadeChoice: hasMadeChoice));
    await _storage.write(payload);
    notifyListeners();
  }
}
