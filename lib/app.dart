import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/core/services/app_links_service.dart';
import 'package:upsessions/core/services/cloud_functions_service.dart';
import 'package:upsessions/core/services/firebase_initializer.dart';
import 'package:upsessions/core/services/push_notifications_service.dart';
import 'package:upsessions/core/theme/app_theme.dart';
import 'package:upsessions/core/theme/theme_cubit.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:upsessions/l10n/cubit/locale_cubit.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/auth/repositories/profile_repository.dart';
import 'package:upsessions/modules/contacts/cubits/liked_musicians_cubit.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'package:upsessions/modules/musicians/repositories/affinity_options_repository.dart';
import 'package:upsessions/modules/musicians/repositories/artist_image_repository.dart';
import 'package:upsessions/modules/profile/cubit/profile_cubit.dart';
import 'package:upsessions/modules/studios/repositories/studios_repository.dart';
import 'package:upsessions/features/home/repositories/home_announcements_repository.dart';
import 'package:upsessions/features/home/repositories/home_events_repository.dart';
import 'package:upsessions/features/home/repositories/home_metadata_repository.dart';
import 'package:upsessions/features/home/repositories/home_musicians_repository.dart';
import 'package:upsessions/features/home/repositories/home_rehearsals_repository.dart';
import 'package:upsessions/features/home/repositories/user_home_repository.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/messaging/repositories/chat_repository.dart';
import 'package:upsessions/modules/notifications/repositories/invite_notifications_repository.dart';
import 'package:upsessions/features/events/repositories/events_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';
import 'package:upsessions/modules/rehearsals/use_cases/create_rehearsal_use_case.dart';
import 'package:upsessions/modules/announcements/repositories/announcements_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/setlist_repository.dart';
import 'package:upsessions/features/media/repositories/media_repository.dart';
import 'package:upsessions/router/app_router.dart';

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
        RepositoryProvider(create: (_) => locate<StudiosRepository>()),
        RepositoryProvider(create: (_) => locate<HomeMusiciansRepository>()),
        RepositoryProvider(
          create: (_) => locate<HomeAnnouncementsRepository>(),
        ),
        RepositoryProvider(create: (_) => locate<HomeMetadataRepository>()),
        RepositoryProvider(create: (_) => locate<HomeEventsRepository>()),
        RepositoryProvider(create: (_) => locate<HomeRehearsalsRepository>()),
        RepositoryProvider(create: (_) => locate<UserHomeRepository>()),
        RepositoryProvider(create: (_) => locate<PushNotificationsService>()),
        RepositoryProvider(create: (_) => locate<GroupsRepository>()),
        RepositoryProvider(create: (_) => locate<ChatRepository>()),
        RepositoryProvider(
          create: (_) => locate<InviteNotificationsRepository>(),
        ),
        RepositoryProvider(create: (_) => locate<EventsRepository>()),
        RepositoryProvider(create: (_) => locate<RehearsalsRepository>()),
        RepositoryProvider(
          create: (context) => CreateRehearsalUseCase(
            groupsRepository: context.read<GroupsRepository>(),
            rehearsalsRepository: context.read<RehearsalsRepository>(),
          ),
        ),
        RepositoryProvider(create: (_) => locate<AnnouncementsRepository>()),
        RepositoryProvider(create: (_) => locate<SetlistRepository>()),
        RepositoryProvider(create: (_) => locate<MediaRepository>()),
        RepositoryProvider(create: (_) => locate<AffinityOptionsRepository>()),
        RepositoryProvider(create: (_) => locate<ArtistImageRepository>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(
              authRepository: context.read<AuthRepository>(),
              studiosRepository: context.read<StudiosRepository>(),
              pushNotificationsService: context
                  .read<PushNotificationsService>(),
              cloudFunctionsService: locate<CloudFunctionsService>(),
            ),
          ),
          BlocProvider(
            create: (context) => ProfileCubit(
              profileRepository: context.read<ProfileRepository>(),
              authCubit: context.read<AuthCubit>(),
            ),
          ),
          BlocProvider(create: (_) => locate<LikedMusiciansCubit>()),
          BlocProvider(create: (_) => locate<ThemeCubit>()),
        ],
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return AppLinksListener(
                  router: _appRouter.router,
                  child: MaterialApp.router(
                    onGenerateTitle: (context) =>
                        AppLocalizations.of(context).appName,
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light,
                    darkTheme: AppTheme.dark,
                    themeMode: themeMode,
                    themeAnimationDuration: Duration.zero,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    locale: locale,
                    routerConfig: _appRouter.router,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
