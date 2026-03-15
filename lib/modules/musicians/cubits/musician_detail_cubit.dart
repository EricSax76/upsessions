import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../features/messaging/repositories/chat_repository.dart';
import '../../groups/repositories/groups_repository.dart';
import '../models/artist_image_info.dart';
import '../models/musician_entity.dart';
import '../models/musician_string_utils.dart';
import '../repositories/artist_image_repository.dart';
import '../repositories/musicians_repository.dart';

part 'musician_detail_state.dart';

class MusicianDetailCubit extends Cubit<MusicianDetailState> {
  MusicianDetailCubit({
    required ChatRepository chatRepository,
    required this.groupsRepository,
    required MusiciansRepository musiciansRepository,
    required ArtistImageRepository artistImageRepository,
  }) : _chatRepository = chatRepository,
       _musiciansRepository = musiciansRepository,
       _artistImageRepository = artistImageRepository,
       super(const MusicianDetailState());

  final ChatRepository _chatRepository;
  final MusiciansRepository _musiciansRepository;
  final ArtistImageRepository _artistImageRepository;
  final GroupsRepository groupsRepository;

  String _spotifyAffinityCacheKey = '';
  Future<Map<String, ArtistImageInfo>>? _spotifyAffinityFuture;

  Future<void> loadMusician(
    MusicianEntity musician, {
    String? currentUserId,
  }) async {
    final normalizedCurrentUserId = _normalizeCurrentUserId(currentUserId);
    emit(
      state.copyWith(
        isLoading: true,
        musician: musician,
        currentUserId: normalizedCurrentUserId,
        isOwnProfile: isOwnProfile(musician, normalizedCurrentUserId),
        loadErrorMessage: null,
      ),
    );

    try {
      final found = await _musiciansRepository.findById(musician.id);
      final resolvedMusician = found ?? musician;
      emit(
        state.copyWith(
          isLoading: false,
          musician: resolvedMusician,
          isOwnProfile: isOwnProfile(resolvedMusician, normalizedCurrentUserId),
          loadErrorMessage: null,
        ),
      );
      await _resolveSpotifyAffinityArtists(resolvedMusician.influences);
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          musician: musician,
          isOwnProfile: isOwnProfile(musician, normalizedCurrentUserId),
          loadErrorMessage: 'No pudimos cargar el perfil del músico.',
        ),
      );
      await _resolveSpotifyAffinityArtists(musician.influences);
    }
  }

  void updateCurrentUser(String? currentUserId) {
    final normalizedCurrentUserId = _normalizeCurrentUserId(currentUserId);
    if (normalizedCurrentUserId == state.currentUserId) {
      return;
    }

    final musician = state.musician;
    emit(
      state.copyWith(
        currentUserId: normalizedCurrentUserId,
        isOwnProfile: musician == null
            ? false
            : isOwnProfile(musician, normalizedCurrentUserId),
      ),
    );
  }

  String getParticipantId(MusicianEntity musician) {
    final ownerId = musician.ownerId.trim();
    return ownerId.isNotEmpty ? ownerId : musician.id.trim();
  }

  bool isOwnProfile(MusicianEntity musician, String? currentUserId) {
    final currentId = _normalizeCurrentUserId(currentUserId);
    if (currentId.isEmpty) {
      return false;
    }

    final ownerId = musician.ownerId.trim();
    final musicianId = musician.id.trim();
    return ownerId == currentId || musicianId == currentId;
  }

  Future<void> contactCurrentMusician() async {
    final musician = state.musician;
    if (musician == null || state.isContacting) {
      return;
    }
    await contactMusician(musician, currentUserId: state.currentUserId);
  }

  Future<void> contactMusician(
    MusicianEntity musician, {
    String? currentUserId,
  }) async {
    final participantId = getParticipantId(musician);
    final currentId = _normalizeCurrentUserId(
      currentUserId ?? state.currentUserId,
    );
    if (currentId.isNotEmpty && participantId == currentId) {
      emit(
        state.copyWith(
          isContacting: false,
          contactErrorMessage: 'No puedes iniciar un chat contigo mismo.',
          navigateToThreadId: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isContacting: true,
        contactErrorMessage: null,
        navigateToThreadId: null,
      ),
    );
    try {
      final thread = await _chatRepository.ensureThreadWithParticipant(
        participantId: participantId,
        participantName: musician.name,
      );
      emit(
        state.copyWith(
          isContacting: false,
          contactErrorMessage: null,
          navigateToThreadId: thread.id,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isContacting: false,
          contactErrorMessage: e.toString(),
          navigateToThreadId: null,
        ),
      );
    }
  }

  void consumeNavigation() {
    if (state.navigateToThreadId == null) {
      return;
    }
    emit(state.copyWith(navigateToThreadId: null));
  }

  void clearContactError() {
    if (state.contactErrorMessage == null) {
      return;
    }
    emit(state.copyWith(contactErrorMessage: null));
  }

  Future<void> _resolveSpotifyAffinityArtists(
    Map<String, List<String>> influences,
  ) async {
    if (influences.isEmpty) {
      emit(
        state.copyWith(
          areAffinityArtistsLoading: false,
          spotifyAffinityByArtist: const <String, ArtistImageInfo>{},
        ),
      );
      return;
    }

    emit(state.copyWith(areAffinityArtistsLoading: true));
    try {
      final resolved = await _spotifyAffinityFutureFor(influences);
      emit(
        state.copyWith(
          areAffinityArtistsLoading: false,
          spotifyAffinityByArtist: resolved,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          areAffinityArtistsLoading: false,
          spotifyAffinityByArtist: const <String, ArtistImageInfo>{},
        ),
      );
    }
  }

  Future<Map<String, ArtistImageInfo>> _spotifyAffinityFutureFor(
    Map<String, List<String>> influences,
  ) {
    final artists = _flattenUniqueAffinityArtists(influences);
    if (artists.isEmpty) {
      return Future.value(const <String, ArtistImageInfo>{});
    }

    final cacheKey =
        artists
            .map(normalizeArtistName)
            .where((key) => key.isNotEmpty)
            .toList(growable: false)
          ..sort();
    final joinedKey = cacheKey.join('|');

    if (_spotifyAffinityFuture != null &&
        joinedKey == _spotifyAffinityCacheKey) {
      return _spotifyAffinityFuture!;
    }

    _spotifyAffinityCacheKey = joinedKey;
    _spotifyAffinityFuture = _artistImageRepository.resolveArtists(artists);
    return _spotifyAffinityFuture!;
  }

  List<String> _flattenUniqueAffinityArtists(
    Map<String, List<String>> influences,
  ) {
    final uniqueByKey = <String, String>{};
    final sortedStyles = influences.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    for (final style in sortedStyles) {
      final artists = influences[style] ?? const <String>[];
      for (final rawArtist in artists) {
        final artist = rawArtist.trim();
        if (artist.isEmpty) {
          continue;
        }
        final key = normalizeArtistName(artist);
        if (key.isEmpty) {
          continue;
        }
        uniqueByKey.putIfAbsent(key, () => artist);
      }
    }

    return uniqueByKey.values.toList(growable: false);
  }

  String _normalizeCurrentUserId(String? currentUserId) {
    return currentUserId?.trim() ?? '';
  }

  @override
  Future<void> close() {
    _spotifyAffinityFuture = null;
    return super.close();
  }
}
