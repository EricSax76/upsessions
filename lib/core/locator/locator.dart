import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'package:upsessions/core/services/cloud_functions_service.dart';
import 'package:upsessions/core/services/firebase_initializer.dart';
import 'package:upsessions/core/services/push_notifications_service.dart';
import 'package:upsessions/core/services/analytics_service.dart';
import 'package:upsessions/core/services/remote_config_service.dart';
import 'package:upsessions/l10n/cubit/locale_cubit.dart';
import 'package:upsessions/core/theme/theme_cubit.dart';
import 'package:upsessions/modules/announcements/repositories/announcements_repository.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/auth/repositories/profile_repository.dart';
import 'package:upsessions/features/media/repositories/media_repository.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/features/events/repositories/events_repository.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'package:upsessions/home/repositories/user_home_repository.dart';
import 'package:upsessions/features/contacts/controllers/liked_musicians_controller.dart';
import 'package:upsessions/features/contacts/repositories/contacts_repository.dart';
import 'package:upsessions/modules/rehearsals/use_cases/create_rehearsal_use_case.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/setlist_repository.dart';
import 'package:upsessions/features/notifications/repositories/invite_notifications_repository.dart';
import 'package:upsessions/modules/studios/repositories/firestore_studios_repository.dart';
import 'package:upsessions/modules/studios/repositories/studios_repository.dart';
import 'package:upsessions/modules/studios/services/studio_image_service.dart';

final GetIt getIt = GetIt.instance;
final Set<String> _loggedLocateTypes = <String>{};

Future<void> setupServiceLocator() async {
  if (getIt.isRegistered<FirebaseInitializer>()) {
    return;
  }

  getIt
    ..registerLazySingleton<FirebaseInitializer>(
      () => const FirebaseInitializer(),
    )
    ..registerLazySingleton<AuthRepository>(() => AuthRepository())
    ..registerLazySingleton<CloudFunctionsService>(
      () => CloudFunctionsService(),
    )
    ..registerLazySingleton<PushNotificationsService>(
      () => PushNotificationsService(),
    )
    ..registerLazySingleton<AnalyticsService>(() => const AnalyticsService())
    ..registerLazySingleton<RemoteConfigService>(
      () => const RemoteConfigService(),
    )
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit())
    ..registerLazySingleton<ThemeCubit>(() => ThemeCubit())
    ..registerLazySingleton<MusiciansRepository>(() => MusiciansRepository())
    ..registerLazySingleton<AnnouncementsRepository>(
      () => AnnouncementsRepository(),
    )
    ..registerLazySingleton<UserHomeRepository>(
      () => UserHomeRepository(authRepository: getIt<AuthRepository>()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepository(authRepository: getIt<AuthRepository>()),
    )
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepository(
        authRepository: getIt<AuthRepository>(),
        cloudFunctionsService: getIt<CloudFunctionsService>(),
      ),
    )
    ..registerLazySingleton<MediaRepository>(() => MediaRepository())
    ..registerLazySingleton<EventsRepository>(
      () => EventsRepository(authRepository: getIt<AuthRepository>()),
    )
    ..registerLazySingleton<ContactsRepository>(() => ContactsRepository())
    ..registerLazySingleton<GroupsRepository>(
      () => GroupsRepository(authRepository: getIt<AuthRepository>()),
    )
    ..registerLazySingleton<RehearsalsRepository>(() => RehearsalsRepository())
    ..registerLazySingleton<InviteNotificationsRepository>(
      () => InviteNotificationsRepository(
        authRepository: getIt<AuthRepository>(),
      ),
    )
    ..registerLazySingleton<CreateRehearsalUseCase>(
      () => CreateRehearsalUseCase(
        groupsRepository: getIt<GroupsRepository>(),
        rehearsalsRepository: getIt<RehearsalsRepository>(),
      ),
    )
    ..registerLazySingleton<SetlistRepository>(
      () => SetlistRepository(authRepository: getIt<AuthRepository>()),
    )
    ..registerLazySingleton<StudiosRepository>(() => FirestoreStudiosRepository())
    ..registerLazySingleton<StudioImageService>(() => StudioImageService())
    ..registerLazySingleton<LikedMusiciansController>(
      () => LikedMusiciansController(
        contactsRepository: getIt<ContactsRepository>(),
        authRepository: getIt<AuthRepository>(),
      ),
    );
}

T locate<T extends Object>() {
  final instance = getIt<T>();
  assert(() {
    final typeName = T.toString();
    if (_loggedLocateTypes.add(typeName)) {
      debugPrintSynchronously('Locator -> $typeName');
    }
    return true;
  }());
  return instance;
}
