import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/modules/musicians/models/artist_image_info.dart';
import 'package:upsessions/modules/musicians/application/affinity_flow.dart';

import 'package:upsessions/modules/auth/models/profile_entity.dart';
import 'package:upsessions/modules/musicians/repositories/affinity_options_repository.dart';
import 'package:upsessions/modules/musicians/repositories/artist_image_repository.dart';

part 'profile_form_state.dart';

class ProfileFormCubit extends Cubit<ProfileFormState> {
  ProfileFormCubit({
    required ProfileEntity profile,
    required AffinityOptionsRepository affinityRepository,
    required ArtistImageRepository artistImageRepository,
  }) : _affinityRepository = affinityRepository,
       _artistImageRepository = artistImageRepository,
       super(
         ProfileFormState(
           bio: profile.bio,
           location: profile.location,
           influences: Map.from(profile.influences),
         ),
       ) {
    unawaited(_primeExistingInfluencesImages(profile.influences));
  }

  final AffinityOptionsRepository _affinityRepository;
  final ArtistImageRepository _artistImageRepository;

  void bioChanged(String value) {
    emit(state.copyWith(bio: value));
  }

  void locationChanged(String value) {
    emit(state.copyWith(location: value));
  }

  Future<void> styleChanged(String? style) async {
    final normalized = style?.trim();

    if (normalized == null || normalized.isEmpty) {
      emit(state.copyWithStyle(selectedStyle: null));
      emit(
        state.copyWith(
          suggestedArtists: [],
          artistImagesByName: const {},
          isLoadingSuggestions: false,
        ),
      );
      return;
    }

    emit(state.copyWithStyle(selectedStyle: normalized));
    emit(state.copyWith(isLoadingSuggestions: true, suggestedArtists: []));

    try {
      final options = await _affinityRepository.fetchArtistOptionsForStyle(
        normalized,
      );
      final artistImagesByName = await _artistImageRepository.resolveArtists(
        options,
      );
      // Check if style is still selected to avoid race condition overwrite
      if (state.selectedStyle == normalized) {
        emit(
          state.copyWith(
            suggestedArtists: options,
            artistImagesByName: artistImagesByName,
            isLoadingSuggestions: false,
          ),
        );
      }
    } catch (e) {
      if (state.selectedStyle == normalized) {
        emit(
          state.copyWith(
            isLoadingSuggestions: false,
            artistImagesByName: const {},
          ),
        );
      }
    }
  }

  void addInfluence(String artist) {
    final style = state.selectedStyle;
    if (style == null) return;
    final normalizedArtist = artist.trim();
    if (normalizedArtist.isEmpty) {
      return;
    }
    final updated = AffinityFlow.addInfluence(
      influences: state.influences,
      style: style,
      artist: normalizedArtist,
    );
    if (identical(updated, state.influences)) return;
    emit(state.copyWith(influences: updated));
    unawaited(_resolveArtistImageIfNeeded(normalizedArtist));
  }

  void removeInfluence(String style, String artist) {
    final updated = AffinityFlow.removeInfluence(
      influences: state.influences,
      style: style,
      artist: artist,
    );
    if (identical(updated, state.influences)) return;
    emit(state.copyWith(influences: updated));
  }

  ProfileEntity getUpdatedProfile(ProfileEntity original) {
    return original.copyWith(
      bio: state.bio.trim(),
      location: state.location.trim(),
      influences: state.influences,
    );
  }

  Future<void> _resolveArtistImageIfNeeded(String artist) async {
    final key = normalizeArtistName(artist);
    if (key.isEmpty || state.artistImagesByName.containsKey(key)) {
      return;
    }

    final resolved = await _artistImageRepository.resolveArtists([artist]);
    final info = resolved[key];
    if (isClosed || info == null) {
      return;
    }

    if (state.artistImagesByName.containsKey(key)) {
      return;
    }

    final updated = Map<String, ArtistImageInfo>.from(state.artistImagesByName)
      ..[key] = info;
    emit(state.copyWith(artistImagesByName: updated));
  }

  Future<void> _primeExistingInfluencesImages(
    Map<String, List<String>> influences,
  ) async {
    final artistNames = influences.values
        .expand((artists) => artists)
        .where((artist) => artist.trim().isNotEmpty)
        .toSet();
    if (artistNames.isEmpty) {
      return;
    }

    final resolved = await _artistImageRepository.resolveArtists(artistNames);
    if (isClosed || resolved.isEmpty) {
      return;
    }

    final updated = Map<String, ArtistImageInfo>.from(state.artistImagesByName)
      ..addAll(resolved);
    emit(state.copyWith(artistImagesByName: updated));
  }
}
