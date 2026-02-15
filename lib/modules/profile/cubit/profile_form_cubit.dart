import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:upsessions/modules/auth/models/profile_entity.dart';
import 'package:upsessions/modules/musicians/repositories/affinity_options_repository.dart';

part 'profile_form_state.dart';

class ProfileFormCubit extends Cubit<ProfileFormState> {
  ProfileFormCubit({
    required ProfileEntity profile,
    required AffinityOptionsRepository affinityRepository,
  })  : _affinityRepository = affinityRepository,
        super(ProfileFormState(
          bio: profile.bio,
          location: profile.location,
          influences: Map.from(profile.influences),
        ));

  final AffinityOptionsRepository _affinityRepository;

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
      emit(state.copyWith(suggestedArtists: [], isLoadingSuggestions: false));
      return;
    }

    emit(state.copyWithStyle(selectedStyle: normalized));
    emit(state.copyWith(isLoadingSuggestions: true, suggestedArtists: []));

    try {
      final options = await _affinityRepository.fetchArtistOptionsForStyle(normalized);
      // Check if style is still selected to avoid race condition overwrite
      if (state.selectedStyle == normalized) {
         emit(state.copyWith(suggestedArtists: options, isLoadingSuggestions: false));
      }
    } catch (e) {
       if (state.selectedStyle == normalized) {
         emit(state.copyWith(isLoadingSuggestions: false));
       }
    }
  }

  void addInfluence(String artist) {
    final style = state.selectedStyle;
    if (style == null || artist.trim().isEmpty) return;

    final currentArtists = List<String>.from(state.influences[style] ?? []);
    if (currentArtists.any((a) => a.toLowerCase() == artist.toLowerCase())) return;

    currentArtists.add(artist.trim());
    
    final newInfluences = Map<String, List<String>>.from(state.influences);
    newInfluences[style] = currentArtists;

    emit(state.copyWith(influences: newInfluences));
  }

  void removeInfluence(String style, String artist) {
    final currentArtists = List<String>.from(state.influences[style] ?? []);
    currentArtists.remove(artist);

    final newInfluences = Map<String, List<String>>.from(state.influences);
    if (currentArtists.isEmpty) {
      newInfluences.remove(style);
    } else {
      newInfluences[style] = currentArtists;
    }

    emit(state.copyWith(influences: newInfluences));
  }

  ProfileEntity getUpdatedProfile(ProfileEntity original) {
    return original.copyWith(
      bio: state.bio.trim(),
      location: state.location.trim(),
      influences: state.influences,
    );
  }
}
