import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

class FirebaseInitializer {
  const FirebaseInitializer();

  static Completer<void>? _initializing;

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
      _logFirebaseContext();
      completer.complete();
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      _initializing = null;
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
