import 'package:flutter/material.dart';

import 'app.dart';
import 'core/services/firebase_initializer.dart';
import 'core/services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  await getIt<FirebaseInitializer>().init();
  runApp(const MusicInTouchApp());
}
