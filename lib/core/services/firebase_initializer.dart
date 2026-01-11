import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kDebugMode, kIsWeb;
import '../../firebase_options.dart';

class FirebaseInitializer {
  const FirebaseInitializer();

  static Completer<void>? _initializing;
  static bool _appCheckActivated = false;
  static const String _appCheckDebugToken =
      String.fromEnvironment('FIREBASE_APP_CHECK_DEBUG_TOKEN');

  Future<void> init() async {
    if (Firebase.apps.isNotEmpty) {
      _logFirebaseContext();
      return;
    }
    if (_initializing != null) {
      return _initializing!.future;
    }
    final completer = Completer<void>();
    _initializing = completer;
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      await _activateAppCheckIfNeeded();
      _logFirebaseContext();
      completer.complete();
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      _initializing = null;
    }
  }

  Future<void> _activateAppCheckIfNeeded() async {
    if (_appCheckActivated || kIsWeb) {
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? (_appCheckDebugToken.isNotEmpty
                ? AndroidDebugProvider(debugToken: _appCheckDebugToken)
                : const AndroidDebugProvider())
            : const AndroidPlayIntegrityProvider(),
      );
      _appCheckActivated = true;

      if (kDebugMode && _appCheckDebugToken.isNotEmpty) {
        print('[AppCheck] Using debug token: $_appCheckDebugToken');
      }
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await FirebaseAppCheck.instance.activate(
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleDeviceCheckProvider(),
      );
      _appCheckActivated = true;
      return;
    }
  }

  void _logFirebaseContext() {
    final options = Firebase.app().options;
    print(
      '[Firebase] appId=${options.appId} projectId=${options.projectId} '
      'storageBucket=${options.storageBucket}',
    );
    final user = FirebaseAuth.instance.currentUser;
    print(
      '[FirebaseAuth] uid=${user?.uid ?? "null"} email=${user?.email ?? "null"}',
    );
    print('[Firestore] databaseId=${FirebaseFirestore.instance.databaseId}');
  }
}
