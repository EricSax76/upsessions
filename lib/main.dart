import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'home/data/repositories/app.dart';
import 'core/services/firebase_initializer.dart';
import 'package:upsessions/core/locator/locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  debugPrintSynchronously('Locator inicializado');
  await locate<FirebaseInitializer>().init();
  runApp(UpsessionsApp());
}
