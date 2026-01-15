import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/services/firebase_initializer.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'l10n/locale_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  debugPrintSynchronously('Locator inicializado');
  await locate<FirebaseInitializer>().init();
  runApp(BlocProvider(create: (_) => LocaleCubit(), child: UpsessionsApp()));
}
