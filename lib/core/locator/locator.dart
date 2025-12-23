import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'package:upsessions/core/services/cloud_functions_service.dart';
import 'package:upsessions/core/services/firebase_initializer.dart';
import 'package:upsessions/features/announcements/data/announcements_repository.dart';
import 'package:upsessions/modules/auth/data/auth_repository.dart';
import 'package:upsessions/modules/auth/data/profile_repository.dart';
import 'package:upsessions/features/media/data/repositories/media_repository.dart';
import 'package:upsessions/features/messaging/data/chat_repository.dart';
import 'package:upsessions/features/events/data/events_repository.dart';
import 'package:upsessions/modules/musicians/data/musicians_repository.dart';
import 'package:upsessions/home/data/repositories/user_home_repository.dart';
import 'package:upsessions/features/contacts/application/liked_musicians_controller.dart';
import 'package:upsessions/features/contacts/data/contacts_repository.dart';
import 'package:upsessions/features/rehearsals/data/groups_repository.dart';
import 'package:upsessions/features/rehearsals/data/rehearsals_repository.dart';
import 'package:upsessions/features/rehearsals/data/setlist_repository.dart';

final GetIt getIt = GetIt.instance;

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
    ..registerLazySingleton<MusiciansRepository>(() => MusiciansRepository())
    ..registerLazySingleton<AnnouncementsRepository>(
      () => AnnouncementsRepository(),
    )
    ..registerLazySingleton<UserHomeRepository>(() => UserHomeRepository())
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepository(authRepository: getIt<AuthRepository>()),
    )
    ..registerLazySingleton<ChatRepository>(() => ChatRepository())
    ..registerLazySingleton<MediaRepository>(() => MediaRepository())
    ..registerLazySingleton<EventsRepository>(
      () => EventsRepository(authRepository: getIt<AuthRepository>()),
    )
    ..registerLazySingleton<ContactsRepository>(() => ContactsRepository())
    ..registerLazySingleton<GroupsRepository>(
      () => GroupsRepository(authRepository: getIt<AuthRepository>()),
    )
    ..registerLazySingleton<RehearsalsRepository>(
      () => RehearsalsRepository(),
    )
    ..registerLazySingleton<SetlistRepository>(
      () => SetlistRepository(),
    )
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
    debugPrintSynchronously('Locator -> ${T.toString()}');
    return true;
  }());
  return instance;
}
