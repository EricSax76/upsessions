import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/firebase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await const FirebaseInitializer().init();
  runApp(const MusicInTouchApp());
}
