import 'package:flutter/material.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

class MusicInTouchApp extends StatelessWidget {
  const MusicInTouchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();
    return MaterialApp(
      title: 'Solo Músicos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: router.onGenerateRoute,
    );
  }
}
