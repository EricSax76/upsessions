part of 'musician_detail_cubit.dart';

class MusicianDetailState extends Equatable {
  const MusicianDetailState({
    this.musician,
    this.currentUserId = '',
    this.isOwnProfile = false,
    this.isLoading = false,
    this.isContacting = false,
    this.areAffinityArtistsLoading = false,
    this.spotifyAffinityByArtist = const <String, ArtistImageInfo>{},
    this.loadErrorMessage,
    this.contactErrorMessage,
    this.navigateToThreadId,
  });

  static const Object _valueUnchanged = Object();

  final MusicianEntity? musician;
  final String currentUserId;
  final bool isOwnProfile;
  final bool isLoading;
  final bool isContacting;
  final bool areAffinityArtistsLoading;
  final Map<String, ArtistImageInfo> spotifyAffinityByArtist;
  final String? loadErrorMessage;
  final String? contactErrorMessage;
  final String? navigateToThreadId;

  MusicianDetailState copyWith({
    MusicianEntity? musician,
    String? currentUserId,
    bool? isOwnProfile,
    bool? isLoading,
    bool? isContacting,
    bool? areAffinityArtistsLoading,
    Map<String, ArtistImageInfo>? spotifyAffinityByArtist,
    Object? loadErrorMessage = _valueUnchanged,
    Object? contactErrorMessage = _valueUnchanged,
    Object? navigateToThreadId = _valueUnchanged,
  }) {
    return MusicianDetailState(
      musician: musician ?? this.musician,
      currentUserId: currentUserId ?? this.currentUserId,
      isOwnProfile: isOwnProfile ?? this.isOwnProfile,
      isLoading: isLoading ?? this.isLoading,
      isContacting: isContacting ?? this.isContacting,
      areAffinityArtistsLoading:
          areAffinityArtistsLoading ?? this.areAffinityArtistsLoading,
      spotifyAffinityByArtist:
          spotifyAffinityByArtist ?? this.spotifyAffinityByArtist,
      loadErrorMessage: identical(loadErrorMessage, _valueUnchanged)
          ? this.loadErrorMessage
          : loadErrorMessage as String?,
      contactErrorMessage: identical(contactErrorMessage, _valueUnchanged)
          ? this.contactErrorMessage
          : contactErrorMessage as String?,
      navigateToThreadId: identical(navigateToThreadId, _valueUnchanged)
          ? this.navigateToThreadId
          : navigateToThreadId as String?,
    );
  }

  @override
  List<Object?> get props => [
    musician,
    currentUserId,
    isOwnProfile,
    isLoading,
    isContacting,
    areAffinityArtistsLoading,
    _spotifyAffinitySignature,
    loadErrorMessage,
    contactErrorMessage,
    navigateToThreadId,
  ];

  List<String> get _spotifyAffinitySignature {
    final entries = spotifyAffinityByArtist.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries
        .map(
          (entry) =>
              '${entry.key}|${entry.value.imageUrl ?? ''}|${entry.value.spotifyUrl ?? ''}',
        )
        .toList(growable: false);
  }
}
