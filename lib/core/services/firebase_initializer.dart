import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import '../../firebase_options.dart';

class FirebaseInitializer {
  const FirebaseInitializer();

  static Completer<void>? _initializing;
  static bool _appCheckActivated = false;
  static const bool _useAppCheck = bool.fromEnvironment(
    'USE_FIREBASE_APP_CHECK',
    defaultValue: false,
  );

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
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
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
    if (!_useAppCheck) {
      return;
    }
    if (_appCheckActivated) {
      return;
    }

    // Use a placeholder for the reCAPTCHA V3 site key.
    const reCaptchaKey = String.fromEnvironment(
      'RECAPTCHA_V3_SITE_KEY',
      defaultValue: 'TU_SITE_KEY_AQUI',
    );

    // To get the debug token for Android, run your app in debug mode and check the logs.
    // You will see a message like:
    // D/DebugAppCheckProvider( 12345): Enter this debug secret into the allow list in the Firebase Console for your project: 123a4567-b89c-12d3-e456-789012345678
    // For more information, see: https://firebase.google.com/docs/app-check/flutter/debug-provider
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleAppAttestProvider(),
      providerWeb: ReCaptchaV3Provider(reCaptchaKey),
    );
    _appCheckActivated = true;
    debugPrint(
      '[AppCheck] activate: kDebugMode=$kDebugMode '
      'androidProvider=${kDebugMode ? "AndroidDebugProvider" : "AndroidPlayIntegrityProvider"}',
    );
    if (kDebugMode) {
      debugPrint(
        '[AppCheck] Check Logcat for "DebugAppCheckProvider" to find the debug secret. '
        'Add it to the Firebase Console allowlist.',
      );
      try {
        final token = await FirebaseAppCheck.instance.getToken(true);
        debugPrint('[AppCheck] Debug token retrieved: ${token ?? "null"}');
      } catch (error) {
        debugPrint(
          '\n⚠️ APP CHECK SETUP REQUIRED ⚠️\n'
          'El "Debug Secret" se genera en nativo y a veces no se muestra si la app ya estaba instalada.\n'
          'INTENTA ESTO:\n'
          '1. Desinstala la app de tu dispositivo.\n'
          '2. Ejecuta en terminal: adb logcat | grep DebugAppCheckProvider\n'
          '3. Instala y corre la app de nuevo.\n'
          'Error original: $error',
        );
      }
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
