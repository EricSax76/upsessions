import 'package:equatable/equatable.dart';

import '../../modules/musicians/models/musician_entity.dart';
import '../models/announcement_model.dart';
import '../models/instrument_category_model.dart';
import '../models/home_event_model.dart';
import '../../modules/rehearsals/models/rehearsal_entity.dart';

enum UserHomeStatus { initial, loading, ready, failure }

class UserHomeState extends Equatable {
  const UserHomeState({
    this.status = UserHomeStatus.initial,
    this.province = '',
    this.city = '',
    this.instrument = '',
    this.style = '',
    this.profileType = '',
    this.gender = '',
    this.recommended = const [],
    this.newMusicians = const [],
    this.announcements = const [],
    this.categories = const [],
    this.provinces = const [],
    this.cities = const [],

    this.events = const [],
    this.upcomingRehearsals = const [],
    this.errorMessage,
  });

  static const Object _unset = Object();

  final UserHomeStatus status;
  final String province;
  final String city;
  final String instrument;
  final String style;
  final String profileType;
  final String gender;
  final List<MusicianEntity> recommended;
  final List<MusicianEntity> newMusicians;
  final List<AnnouncementModel> announcements;
  final List<InstrumentCategoryModel> categories;
  final List<String> provinces;
  final List<String> cities;

  final List<HomeEventModel> events;
  final List<RehearsalEntity> upcomingRehearsals;
  final String? errorMessage;

  bool get isLoading => status == UserHomeStatus.loading;

  UserHomeState copyWith({
    UserHomeStatus? status,
    String? province,
    String? city,
    String? instrument,
    String? style,
    String? profileType,
    String? gender,
    List<MusicianEntity>? recommended,
    List<MusicianEntity>? newMusicians,
    List<AnnouncementModel>? announcements,
    List<InstrumentCategoryModel>? categories,
    List<String>? provinces,
    List<String>? cities,
    List<HomeEventModel>? events,
    List<RehearsalEntity>? upcomingRehearsals,
    Object? errorMessage = _unset,
  }) {
    return UserHomeState(
      status: status ?? this.status,
      province: province ?? this.province,
      city: city ?? this.city,
      instrument: instrument ?? this.instrument,
      style: style ?? this.style,
      profileType: profileType ?? this.profileType,
      gender: gender ?? this.gender,
      recommended: recommended ?? this.recommended,
      newMusicians: newMusicians ?? this.newMusicians,
      announcements: announcements ?? this.announcements,
      categories: categories ?? this.categories,
      provinces: provinces ?? this.provinces,
      cities: cities ?? this.cities,
      events: events ?? this.events,
      upcomingRehearsals: upcomingRehearsals ?? this.upcomingRehearsals,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    province,
    city,
    instrument,
    style,
    profileType,
    gender,
    recommended,
    newMusicians,
    announcements,
    categories,
    provinces,
    cities,
    events,
    upcomingRehearsals,
    errorMessage,
  ];
}
