import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_routes.dart';
import 'core/services/firebase_initializer.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/musicians/data/musicians_repository.dart';
import 'router/app_router.dart';

class MusicInTouchApp extends StatelessWidget {
  const MusicInTouchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => const FirebaseInitializer()),
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => MusiciansRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthCubit(authRepository: context.read<AuthRepository>())),
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
