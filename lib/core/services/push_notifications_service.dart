import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationsService {
  PushNotificationsService({
    required FirebaseMessaging messaging,
    required FirebaseFirestore firestore,
    String webVapidKey = '',
  })  : _messaging = messaging,
        _firestore = firestore,
        _webVapidKey = webVapidKey;

  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final String _webVapidKey;

  StreamSubscription<String>? _tokenSubscription;
  String? _lastToken;

  Future<void> registerForUser(String uid) async {
    if (!await _messaging.isSupported()) {
      return;
    }
    try {
      await _messaging.requestPermission();
    } catch (_) {
      // Ignore permission errors; registration is best-effort.
    }
    final token = await _getToken();
    if (token == null || token.trim().isEmpty) return;
    _lastToken = token;
    await _saveToken(uid, token);
    await _tokenSubscription?.cancel();
    _tokenSubscription = _messaging.onTokenRefresh.listen((newToken) async {
      _lastToken = newToken;
      await _saveToken(uid, newToken);
    });
  }

  Future<void> unregisterUser(String uid) async {
    final token = _lastToken ?? await _getToken();
    if (token != null && token.isNotEmpty) {
      await _deleteToken(uid, token);
    }
    await _tokenSubscription?.cancel();
    _tokenSubscription = null;
    _lastToken = null;
    try {
      await _messaging.deleteToken();
    } catch (_) {
      // Ignore token deletion errors.
    }
  }

  Future<String?> _getToken() async {
    try {
      if (kIsWeb) {
        if (_webVapidKey.trim().isEmpty) return null;
        return _messaging.getToken(vapidKey: _webVapidKey);
      }
      return _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    if (uid.trim().isEmpty) return;
    final ref = _firestore
        .collection('musicians')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token);
    try {
      await ref.set(
        {
          'token': token,
          'platform': _platformLabel(),
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied' || error.code == 'unauthenticated') {
        // Token registration is best-effort; don't crash the app if rules reject it.
        return;
      }
      rethrow;
    }
  }

  Future<void> _deleteToken(String uid, String token) async {
    final ref = _firestore
        .collection('musicians')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token);
    try {
      await ref.delete();
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') {
        rethrow;
      }
    }
  }

  String _platformLabel() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }
}
