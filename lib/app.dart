import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_initializer.dart';
import 'features/auth/application/auth_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/profile_repository.dart';
import 'features/musicians/data/musicians_repository.dart';
import 'package:upsessions/locator.dart';
import 'router/app_router.dart';

class MusicInTouchApp extends StatelessWidget {
  const MusicInTouchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => locate<FirebaseInitializer>()),
        RepositoryProvider(create: (_) => locate<AuthRepository>()),
        RepositoryProvider(create: (_) => locate<ProfileRepository>()),
        RepositoryProvider(create: (_) => locate<MusiciansRepository>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(
              authRepository: context.read<AuthRepository>(),
              profileRepository: context.read<ProfileRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Solo Músicos',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: router.onGenerateRoute,
        ),
      ),
    );
  }
}
