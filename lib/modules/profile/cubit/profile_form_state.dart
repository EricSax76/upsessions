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
    this.isLoadingSuggestions = false,
    this.errorMessage,
  });

  final ProfileFormStatus status;
  final String bio;
  final String location;
  final Map<String, List<String>> influences;
  final String? selectedStyle;
  final List<String> suggestedArtists;
  final bool isLoadingSuggestions;
  final String? errorMessage;

  ProfileFormState copyWith({
    ProfileFormStatus? status,
    String? bio,
    String? location,
    Map<String, List<String>>? influences,
    Object? selectedStyle = _unset,
    List<String>? suggestedArtists,
    bool? isLoadingSuggestions,
    String? errorMessage,
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
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helper for nullable selectedStyle update
  ProfileFormState copyWithStyle({
    required String? selectedStyle,
  }) {
     return ProfileFormState(
      status: status,
      bio: bio,
      location: location,
      influences: influences,
      selectedStyle: selectedStyle,
      suggestedArtists: suggestedArtists,
      isLoadingSuggestions: isLoadingSuggestions,
      errorMessage: errorMessage,
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
    isLoadingSuggestions,
    errorMessage,
  ];
}
