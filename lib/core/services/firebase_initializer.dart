import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

class FirebaseInitializer {
  const FirebaseInitializer();

  static Completer<void>? _initializing;

  Future<void> init() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }
    if (_initializing != null) {
      return _initializing!.future;
    }
    final completer = Completer<void>();
    _initializing = completer;
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      completer.complete();
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      _initializing = null;
    }
  }
}
