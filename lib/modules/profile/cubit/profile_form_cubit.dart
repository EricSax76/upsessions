import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/core/utils/age_gate_utils.dart';
import 'package:upsessions/modules/musicians/models/artist_image_info.dart';
import 'package:upsessions/modules/musicians/models/musician_string_utils.dart';
import 'package:upsessions/modules/musicians/application/affinity_flow.dart';

import 'package:upsessions/modules/auth/models/profile_entity.dart';
import 'package:upsessions/modules/musicians/repositories/affinity_options_repository.dart';
import 'package:upsessions/modules/musicians/repositories/artist_image_repository.dart';

part 'profile_form_state.dart';

class ProfileFormCubit extends Cubit<ProfileFormState> {
  static const int _initialSuggestionImageBatchSize = 24;

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
           availableForHire: profile.availableForHire,
           birthDate: profile.birthDate,
           legalGuardianEmail: profile.legalGuardianEmail ?? '',
           legalGuardianConsent: profile.legalGuardianConsent,
         ),
       ) {
    unawaited(_primeExistingInfluencesImages(profile.influences));
  }

  final AffinityOptionsRepository _affinityRepository;
  final ArtistImageRepository _artistImageRepository;
  int _styleRequestId = 0;

  void bioChanged(String value) {
    emit(state.copyWith(bio: value));
  }

  void availableForHireChanged(bool value) {
    emit(state.copyWith(availableForHire: value));
  }

  void locationChanged(String value) {
    emit(state.copyWith(location: value));
  }

  void birthDateChanged(DateTime? value) {
    final isMinor = isMusicianMinor(value);
    emit(
      state.copyWith(
        birthDate: value,
        legalGuardianEmail: isMinor ? state.legalGuardianEmail : '',
        legalGuardianConsent: isMinor ? state.legalGuardianConsent : false,
      ),
    );
  }

  void legalGuardianEmailChanged(String value) {
    emit(state.copyWith(legalGuardianEmail: value));
  }

  void legalGuardianConsentChanged(bool value) {
    emit(state.copyWith(legalGuardianConsent: value));
  }

  bool get isMinor => isMusicianMinor(state.birthDate);

  String? validateAgeGate() {
    return validateMusicianAgeGate(
      birthDate: state.birthDate,
      legalGuardianEmail: state.legalGuardianEmail,
      legalGuardianConsent: state.legalGuardianConsent,
    );
  }

  Future<void> styleChanged(String? style) async {
    final normalized = style?.trim();
    final requestId = ++_styleRequestId;

    if (normalized == null || normalized.isEmpty) {
      emit(state.copyWithStyle(selectedStyle: null));
      emit(state.copyWith(suggestedArtists: [], isLoadingSuggestions: false));
      return;
    }

    emit(state.copyWithStyle(selectedStyle: normalized));
    emit(state.copyWith(isLoadingSuggestions: true, suggestedArtists: []));

    try {
      final options = await _affinityRepository.fetchArtistOptionsForStyle(
        normalized,
      );
      if (!_isStyleRequestActive(requestId, normalized)) {
        return;
      }

      emit(
        state.copyWith(suggestedArtists: options, isLoadingSuggestions: false),
      );
      unawaited(
        _resolveSuggestionImagesInBackground(
          options: options,
          style: normalized,
          requestId: requestId,
        ),
      );
    } catch (_) {
      if (!_isStyleRequestActive(requestId, normalized)) {
        return;
      }
      emit(state.copyWith(isLoadingSuggestions: false));
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
    final isMinor = isMusicianMinor(state.birthDate);
    final guardianEmail = state.legalGuardianEmail.trim();
    return original.copyWith(
      bio: state.bio.trim(),
      location: state.location.trim(),
      influences: state.influences,
      availableForHire: state.availableForHire,
      birthDate: state.birthDate,
      ageConsent: true,
      legalGuardianEmail: isMinor ? guardianEmail : null,
      legalGuardianConsent: isMinor && state.legalGuardianConsent,
      legalGuardianConsentAt: isMinor && state.legalGuardianConsent
          ? DateTime.now()
          : null,
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

    _mergeArtistImages(<String, ArtistImageInfo>{key: info});
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

    _mergeArtistImages(resolved);
  }

  Future<void> _resolveSuggestionImagesInBackground({
    required List<String> options,
    required String style,
    required int requestId,
  }) async {
    if (options.isEmpty) {
      return;
    }

    final prioritized = options.take(_initialSuggestionImageBatchSize).toList();
    final remaining = options.skip(_initialSuggestionImageBatchSize).toList();

    final initialResolved = await _artistImageRepository.resolveArtists(
      prioritized,
    );
    if (!_isStyleRequestActive(requestId, style)) {
      return;
    }
    _mergeArtistImages(initialResolved);

    if (remaining.isEmpty) {
      return;
    }

    final remainingResolved = await _artistImageRepository.resolveArtists(
      remaining,
    );
    if (!_isStyleRequestActive(requestId, style)) {
      return;
    }
    _mergeArtistImages(remainingResolved);
  }

  bool _isStyleRequestActive(int requestId, String style) {
    return !isClosed &&
        requestId == _styleRequestId &&
        state.selectedStyle == style;
  }

  void _mergeArtistImages(Map<String, ArtistImageInfo> resolved) {
    if (resolved.isEmpty) {
      return;
    }

    final updated = Map<String, ArtistImageInfo>.from(state.artistImagesByName)
      ..addAll(resolved);
    emit(state.copyWith(artistImagesByName: updated));
  }
}
