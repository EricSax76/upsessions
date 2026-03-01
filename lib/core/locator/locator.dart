import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'package:upsessions/core/services/cloud_functions_service.dart';
import 'package:upsessions/features/events/services/image_upload_service.dart';
import 'package:upsessions/core/services/firebase_initializer.dart';
import 'package:upsessions/core/services/push_notifications_service.dart';
import 'package:upsessions/core/services/analytics_service.dart';
import 'package:upsessions/core/services/remote_config_service.dart';
import 'package:upsessions/l10n/cubit/locale_cubit.dart';
import 'package:upsessions/core/theme/theme_cubit.dart';
import 'package:upsessions/modules/announcements/repositories/announcements_repository.dart';
import 'package:upsessions/modules/announcements/services/announcement_image_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/auth/repositories/profile_repository.dart';
import 'package:upsessions/features/media/repositories/media_repository.dart';
import 'package:upsessions/modules/messaging/repositories/chat_repository.dart';
import 'package:upsessions/features/events/repositories/events_repository.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'package:upsessions/modules/musicians/repositories/affinity_options_repository.dart';
import 'package:upsessions/modules/musicians/repositories/artist_image_repository.dart';
import 'package:upsessions/features/home/repositories/home_announcements_repository.dart';
import 'package:upsessions/features/home/repositories/home_events_repository.dart';
import 'package:upsessions/features/home/repositories/home_metadata_repository.dart';
import 'package:upsessions/features/home/repositories/home_musicians_repository.dart';
import 'package:upsessions/features/home/repositories/home_rehearsals_repository.dart';
import 'package:upsessions/features/home/repositories/user_home_repository.dart';
import 'package:upsessions/modules/contacts/cubits/liked_musicians_cubit.dart';
import 'package:upsessions/modules/contacts/repositories/contacts_repository.dart';
import 'package:upsessions/modules/rehearsals/use_cases/create_rehearsal_use_case.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/setlist_repository.dart';
import 'package:upsessions/modules/notifications/repositories/invite_notifications_repository.dart';
import 'package:upsessions/modules/studios/repositories/firestore_studios_repository.dart';
import 'package:upsessions/modules/studios/repositories/studios_repository.dart';
import 'package:upsessions/modules/studios/services/studio_image_service.dart';
import 'package:upsessions/modules/matching/repositories/matching_repository.dart';
import 'package:upsessions/modules/event_manager/repositories/event_manager_repository.dart';
import 'package:upsessions/modules/event_manager/repositories/manager_events_repository.dart';
import 'package:upsessions/modules/event_manager/repositories/jam_sessions_repository.dart';
import 'package:upsessions/modules/event_manager/repositories/musician_requests_repository.dart';
import 'package:upsessions/modules/event_manager/repositories/gig_offers_repository.dart';

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
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance)
    ..registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance)
    ..registerLazySingleton<FirebaseFunctions>(
      () => FirebaseFunctions.instanceFor(region: 'europe-west3'),
    )
    ..registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance)
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepository(firebaseAuth: getIt<FirebaseAuth>()),
    )
    ..registerLazySingleton<CloudFunctionsService>(
      () => CloudFunctionsService(functions: getIt<FirebaseFunctions>()),
    )
    ..registerLazySingleton<PushNotificationsService>(
      () => PushNotificationsService(
        messaging: getIt<FirebaseMessaging>(),
        firestore: getIt<FirebaseFirestore>(),
      ),
    )
    ..registerLazySingleton<AnalyticsService>(() => const AnalyticsService())
    ..registerLazySingleton<RemoteConfigService>(
      () => const RemoteConfigService(),
    )
    ..registerLazySingleton<LocaleCubit>(() => LocaleCubit())
    ..registerLazySingleton<ThemeCubit>(() => ThemeCubit())
    ..registerLazySingleton<MusiciansRepository>(
      () => MusiciansRepository(firestore: getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<AffinityOptionsRepository>(
      () => AffinityOptionsRepository(firestore: getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<ArtistImageRepository>(
      () => ArtistImageRepository(functions: getIt<FirebaseFunctions>()),
    )
    ..registerLazySingleton<AnnouncementsRepository>(
      () => AnnouncementsRepository(firestore: getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<AnnouncementImageService>(
      () => AnnouncementImageService(storage: getIt<FirebaseStorage>()),
    )
    ..registerLazySingleton<HomeMusiciansRepository>(
      () => HomeMusiciansRepository(firestore: getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<HomeAnnouncementsRepository>(
      () => HomeAnnouncementsRepository(firestore: getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<HomeMetadataRepository>(
      () => HomeMetadataRepository(firestore: getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<HomeEventsRepository>(
      () => HomeEventsRepository(firestore: getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<HomeRehearsalsRepository>(
      () => HomeRehearsalsRepository(
        firestore: getIt<FirebaseFirestore>(),
        authRepository: getIt<AuthRepository>(),
      ),
    )
    ..registerLazySingleton<UserHomeRepository>(
      () => UserHomeRepository(
        musiciansRepository: getIt<HomeMusiciansRepository>(),
        announcementsRepository: getIt<HomeAnnouncementsRepository>(),
        metadataRepository: getIt<HomeMetadataRepository>(),
        eventsRepository: getIt<HomeEventsRepository>(),
        rehearsalsRepository: getIt<HomeRehearsalsRepository>(),
      ),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepository(
        authRepository: getIt<AuthRepository>(),
        firestore: getIt<FirebaseFirestore>(),
        storage: getIt<FirebaseStorage>(),
      ),
    )
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepository(
        firestore: getIt<FirebaseFirestore>(),
        authRepository: getIt<AuthRepository>(),
        cloudFunctionsService: getIt<CloudFunctionsService>(),
      ),
    )
    ..registerLazySingleton<MediaRepository>(
      () => MediaRepository(
        firestore: getIt<FirebaseFirestore>(),
        storage: getIt<FirebaseStorage>(),
      ),
    )
    ..registerLazySingleton<EventsRepository>(
      () => EventsRepository(
        firestore: getIt<FirebaseFirestore>(),
        authRepository: getIt<AuthRepository>(),
      ),
    )
    ..registerLazySingleton<ContactsRepository>(
      () => ContactsRepository(firestore: getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<GroupsRepository>(
      () => GroupsRepository(
        firestore: getIt<FirebaseFirestore>(),
        authRepository: getIt<AuthRepository>(),
        storage: getIt<FirebaseStorage>(),
      ),
    )
    ..registerLazySingleton<RehearsalsRepository>(
      () => RehearsalsRepository(
        firestore: getIt<FirebaseFirestore>(),
        authRepository: getIt<AuthRepository>(),
      ),
    )
    ..registerLazySingleton<InviteNotificationsRepository>(
      () => InviteNotificationsRepository(
        firestore: getIt<FirebaseFirestore>(),
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
      () => SetlistRepository(
        authRepository: getIt<AuthRepository>(),
        firestore: getIt<FirebaseFirestore>(),
        storage: getIt<FirebaseStorage>(),
      ),
    )
    ..registerLazySingleton<StudiosRepository>(
      () => FirestoreStudiosRepository(firestore: getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<StudioImageService>(
      () => StudioImageService(storage: getIt<FirebaseStorage>()),
    )
    ..registerLazySingleton<ImageUploadService>(
      () => ImageUploadService(storage: getIt<FirebaseStorage>()),
    )
    ..registerLazySingleton<LikedMusiciansCubit>(
      () => LikedMusiciansCubit(
        contactsRepository: getIt<ContactsRepository>(),
        authRepository: getIt<AuthRepository>(),
      ),
    )
    ..registerLazySingleton<MatchingRepository>(
      () => MatchingRepository(firestore: getIt<FirebaseFirestore>()),
    )
    ..registerLazySingleton<EventManagerRepository>(
      () => EventManagerRepository(
        firestore: getIt<FirebaseFirestore>(),
        storage: getIt<FirebaseStorage>(),
      ),
    )
    ..registerLazySingleton<ManagerEventsRepository>(
      () => ManagerEventsRepository(
        firestore: getIt<FirebaseFirestore>(),
        authRepository: getIt<AuthRepository>(),
      ),
    )
    ..registerLazySingleton<JamSessionsRepository>(
      () => JamSessionsRepository(
        firestore: getIt<FirebaseFirestore>(),
        authRepository: getIt<AuthRepository>(),
      ),
    )
    ..registerLazySingleton<MusicianRequestsRepository>(
      () => MusicianRequestsRepository(
        firestore: getIt<FirebaseFirestore>(),
        authRepository: getIt<AuthRepository>(),
      ),
    )
    ..registerLazySingleton<GigOffersRepository>(
      () => GigOffersRepository(
        firestore: getIt<FirebaseFirestore>(),
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
