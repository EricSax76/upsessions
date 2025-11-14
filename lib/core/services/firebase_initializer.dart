import 'dart:async';

class FirebaseInitializer {
  const FirebaseInitializer();

  Future<void> init() async {
    // Firebase will be configured later. This keeps the API ready.
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
