import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/firebase_initializer.dart';
import '../../core/services/push_notifications_service.dart';
import '../../modules/auth/cubits/auth_cubit.dart';
import '../../modules/auth/data/auth_repository.dart';
import '../../modules/auth/data/profile_repository.dart';
import '../../modules/musicians/repositories/musicians_repository.dart';
import 'package:upsessions/core/locator/locator.dart';
import '../../router/app_router.dart';
import '../../core/services/app_links_service.dart';
import '../../modules/profile/cubit/profile_cubit.dart';

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
        RepositoryProvider(create: (_) => locate<PushNotificationsService>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(
              authRepository: context.read<AuthRepository>(),
              pushNotificationsService:
                  context.read<PushNotificationsService>(),
            ),
          ),
          BlocProvider(
            create: (context) => ProfileCubit(
              profileRepository: context.read<ProfileRepository>(),
              authCubit: context.read<AuthCubit>(),
            ),
          ),
        ],
        child: AppLinksListener(
          router: _appRouter.router,
          child: MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: _appRouter.router,
          ),
        ),
      ),
    );
  }
}
