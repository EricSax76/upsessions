part of 'profile_form_cubit.dart';

enum ProfileFormStatus { initial, loading, success, failure }

class ProfileFormState extends Equatable {
  static const Object _unset = Object();

  const ProfileFormState({
    this.status = ProfileFormStatus.initial,
    this.bio = '',
    this.location = '',
    this.influences = const {},
    this.selectedStyle,
    this.suggestedArtists = const [],
    this.artistImagesByName = const {},
    this.isLoadingSuggestions = false,
    this.errorMessage,
    this.availableForHire = false,
  });

  final ProfileFormStatus status;
  final String bio;
  final String location;
  final Map<String, List<String>> influences;
  final String? selectedStyle;
  final List<String> suggestedArtists;
  final Map<String, ArtistImageInfo> artistImagesByName;
  final bool isLoadingSuggestions;
  final String? errorMessage;
  final bool availableForHire;

  ProfileFormState copyWith({
    ProfileFormStatus? status,
    String? bio,
    String? location,
    Map<String, List<String>>? influences,
    Object? selectedStyle = _unset,
    List<String>? suggestedArtists,
    Map<String, ArtistImageInfo>? artistImagesByName,
    bool? isLoadingSuggestions,
    String? errorMessage,
    bool? availableForHire,
  }) {
    return ProfileFormState(
      status: status ?? this.status,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      influences: influences ?? this.influences,
      selectedStyle: identical(selectedStyle, _unset)
          ? this.selectedStyle
          : selectedStyle as String?,
      suggestedArtists: suggestedArtists ?? this.suggestedArtists,
      artistImagesByName: artistImagesByName ?? this.artistImagesByName,
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      errorMessage: errorMessage ?? this.errorMessage,
      availableForHire: availableForHire ?? this.availableForHire,
    );
  }

  // Helper for nullable selectedStyle update
  ProfileFormState copyWithStyle({required String? selectedStyle}) {
    return ProfileFormState(
      status: status,
      bio: bio,
      location: location,
      influences: influences,
      selectedStyle: selectedStyle,
      suggestedArtists: suggestedArtists,
      artistImagesByName: artistImagesByName,
      isLoadingSuggestions: isLoadingSuggestions,
      errorMessage: errorMessage,
      availableForHire: availableForHire,
    );
  }

  @override
  List<Object?> get props => [
    status,
    bio,
    location,
    influences,
    selectedStyle,
    suggestedArtists,
    artistImagesByName,
    isLoadingSuggestions,
    errorMessage,
    availableForHire,
  ];
}
