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
    this.birthDate,
    this.legalGuardianEmail = '',
    this.legalGuardianConsent = false,
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
  final DateTime? birthDate;
  final String legalGuardianEmail;
  final bool legalGuardianConsent;

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
    Object? birthDate = _unset,
    String? legalGuardianEmail,
    bool? legalGuardianConsent,
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
      birthDate: identical(birthDate, _unset)
          ? this.birthDate
          : birthDate as DateTime?,
      legalGuardianEmail: legalGuardianEmail ?? this.legalGuardianEmail,
      legalGuardianConsent: legalGuardianConsent ?? this.legalGuardianConsent,
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
      birthDate: birthDate,
      legalGuardianEmail: legalGuardianEmail,
      legalGuardianConsent: legalGuardianConsent,
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
    birthDate,
    legalGuardianEmail,
    legalGuardianConsent,
  ];
}
