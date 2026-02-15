part of 'musician_search_cubit.dart';

class MusicianSearchState extends Equatable {
  const MusicianSearchState({
    this.results = const [],
    this.isLoading = false,
    this.query = '',
    this.errorMessage,
    this.instrument = '',
    this.style = '',
    this.province = '',
    this.city = '',
    this.profileType = '',
    this.gender = '',
    this.provinces = const [],
    this.cities = const [],
    this.areFiltersLoading = false,
  });

  final List<MusicianEntity> results;
  final bool isLoading;
  final String query;
  final String? errorMessage;

  // Filters
  final String instrument;
  final String style;
  final String province;
  final String city;
  final String profileType;
  final String gender;
  final List<String> provinces;
  final List<String> cities;
  final bool areFiltersLoading;

  MusicianSearchState copyWith({
    List<MusicianEntity>? results,
    bool? isLoading,
    String? query,
    String? errorMessage,
    String? instrument,
    String? style,
    String? province,
    String? city,
    String? profileType,
    String? gender,
    List<String>? provinces,
    List<String>? cities,
    bool? areFiltersLoading,
  }) {
    return MusicianSearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      errorMessage: errorMessage ?? this.errorMessage,
      instrument: instrument ?? this.instrument,
      style: style ?? this.style,
      province: province ?? this.province,
      city: city ?? this.city,
      profileType: profileType ?? this.profileType,
      gender: gender ?? this.gender,
      provinces: provinces ?? this.provinces,
      cities: cities ?? this.cities,
      areFiltersLoading: areFiltersLoading ?? this.areFiltersLoading,
    );
  }

  @override
  List<Object?> get props => [
        results,
        isLoading,
        query,
        errorMessage,
        instrument,
        style,
        province,
        city,
        profileType,
        gender,
        provinces,
        cities,
        areFiltersLoading,
      ];
}
