import 'package:get_it/get_it.dart';

import '../../features/announcements/data/announcements_repository.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/media/data/media_repository.dart';
import '../../features/messaging/data/chat_repository.dart';
import '../../features/musicians/data/musicians_repository.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/user_home/data/user_home_repository.dart';
import 'cloud_functions_service.dart';
import 'firebase_initializer.dart';

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
    ..registerLazySingleton<ProfileRepository>(() => ProfileRepository())
    ..registerLazySingleton<ChatRepository>(() => ChatRepository())
    ..registerLazySingleton<MediaRepository>(() => MediaRepository());
}
