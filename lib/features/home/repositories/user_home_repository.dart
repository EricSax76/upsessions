import 'package:upsessions/features/home/models/home_event_model.dart';
import 'package:upsessions/features/home/models/instrument_category_model.dart';
import 'package:upsessions/modules/announcements/models/announcement_entity.dart';
import 'package:upsessions/modules/musicians/models/musician_entity.dart';
import 'package:upsessions/modules/rehearsals/models/rehearsal_entity.dart';

import 'home_announcements_repository.dart';
import 'home_events_repository.dart';
import 'home_metadata_repository.dart';
import 'home_musicians_repository.dart';
import 'home_rehearsals_repository.dart';

/// Transitional facade.
///
/// New code should prefer domain-specific repositories directly.
class UserHomeRepository {
  UserHomeRepository({
    required HomeMusiciansRepository musiciansRepository,
    required HomeAnnouncementsRepository announcementsRepository,
    required HomeMetadataRepository metadataRepository,
    required HomeEventsRepository eventsRepository,
    required HomeRehearsalsRepository rehearsalsRepository,
  }) : _musiciansRepository = musiciansRepository,
       _announcementsRepository = announcementsRepository,
       _metadataRepository = metadataRepository,
       _eventsRepository = eventsRepository,
       _rehearsalsRepository = rehearsalsRepository;

  final HomeMusiciansRepository _musiciansRepository;
  final HomeAnnouncementsRepository _announcementsRepository;
  final HomeMetadataRepository _metadataRepository;
  final HomeEventsRepository _eventsRepository;
  final HomeRehearsalsRepository _rehearsalsRepository;

  Future<List<MusicianEntity>> fetchRecommendedMusicians() {
    return _musiciansRepository.fetchRecommendedMusicians();
  }

  Future<List<MusicianEntity>> fetchNewMusicians() {
    return _musiciansRepository.fetchNewMusicians();
  }

  Future<List<AnnouncementEntity>> fetchRecentAnnouncements() {
    return _announcementsRepository.fetchRecentAnnouncements();
  }

  Future<List<InstrumentCategoryModel>> fetchInstrumentCategories() {
    return _metadataRepository.fetchInstrumentCategories();
  }

  Future<List<String>> fetchProvinces() {
    return _metadataRepository.fetchProvinces();
  }

  Future<List<String>> fetchCitiesForProvince(String province) {
    return _metadataRepository.fetchCitiesForProvince(province);
  }

  Future<List<HomeEventModel>> fetchUpcomingEvents({int limit = 6}) {
    return _eventsRepository.fetchUpcomingEvents(limit: limit);
  }

  Future<List<RehearsalEntity>> fetchUpcomingRehearsals({int limit = 5}) {
    return _rehearsalsRepository.fetchUpcomingRehearsals(limit: limit);
  }
}
