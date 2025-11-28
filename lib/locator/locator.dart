import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'package:upsessions/core/services/cloud_functions_service.dart';
import 'package:upsessions/core/services/firebase_initializer.dart';
import 'package:upsessions/features/announcements/data/announcements_repository.dart';
import 'package:upsessions/features/auth/data/auth_repository.dart';
import 'package:upsessions/features/auth/data/profile_repository.dart';
import 'package:upsessions/features/media/data/media_repository.dart';
import 'package:upsessions/features/messaging/data/chat_repository.dart';
import 'package:upsessions/features/musicians/data/musicians_repository.dart';
import 'package:upsessions/features/user_home/data/user_home_repository.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  if (getIt.isRegistered<FirebaseInitializer>()) {
    return;
  }

  getIt
    ..registerLazySingleton<FirebaseInitializer>(() => const FirebaseInitializer())
    ..registerLazySingleton<AuthRepository>(() => AuthRepository())
    ..registerLazySingleton<CloudFunctionsService>(() => CloudFunctionsService())
    ..registerLazySingleton<MusiciansRepository>(() => MusiciansRepository())
    ..registerLazySingleton<AnnouncementsRepository>(() => AnnouncementsRepository())
    ..registerLazySingleton<UserHomeRepository>(() => UserHomeRepository())
    ..registerLazySingleton<ProfileRepository>(() => ProfileRepository(authRepository: getIt<AuthRepository>()))
    ..registerLazySingleton<ChatRepository>(() => ChatRepository())
    ..registerLazySingleton<MediaRepository>(() => MediaRepository());
}

T locate<T extends Object>() {
  final instance = getIt<T>();
  assert(() {
    debugPrintSynchronously('Locator -> ${T.toString()}');
    return true;
  }());
  return instance;
}
