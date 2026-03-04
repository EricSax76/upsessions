import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/core/services/analytics_service.dart';
import 'package:upsessions/core/services/cookie_consent_service.dart';

import 'app.dart';
import 'core/services/firebase_initializer.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'l10n/cubit/locale_cubit.dart';
import 'core/services/remote_config_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  debugPrintSynchronously('Locator inicializado');
  await locate<CookieConsentService>().init();
  await locate<FirebaseInitializer>().init();
  locate<AnalyticsService>();
  await locate<RemoteConfigService>().init();
  runApp(
    BlocProvider(create: (_) => locate<LocaleCubit>(), child: UpsessionsApp()),
  );
}
