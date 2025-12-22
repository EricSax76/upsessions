import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/firebase_initializer.dart';
import '../../../modules/auth/cubits/auth_cubit.dart';
import '../../../modules/auth/data/auth_repository.dart';
import '../../../modules/auth/data/profile_repository.dart';
import '../../../modules/musicians/data/musicians_repository.dart';
import 'package:upsessions/core/locator/locator.dart';
import '../../../router/app_router.dart';
import '../../../core/services/app_links_service.dart';

class UpsessionsApp extends StatelessWidget {
  UpsessionsApp({super.key});

  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
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
        child: AppLinksListener(
          router: _appRouter.router,
          child: MaterialApp.router(
            title: 'UPSESSIONS',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: _appRouter.router,
          ),
        ),
      ),
    );
  }
}
