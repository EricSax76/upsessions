import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/modules/musicians/application/affinity_flow.dart';

import 'package:upsessions/modules/auth/models/profile_entity.dart';
import 'package:upsessions/modules/musicians/repositories/affinity_options_repository.dart';

part 'profile_form_state.dart';

class ProfileFormCubit extends Cubit<ProfileFormState> {
  ProfileFormCubit({
    required ProfileEntity profile,
    required AffinityOptionsRepository affinityRepository,
  }) : _affinityRepository = affinityRepository,
       super(
         ProfileFormState(
           bio: profile.bio,
           location: profile.location,
           influences: Map.from(profile.influences),
         ),
       );

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
      final options = await _affinityRepository.fetchArtistOptionsForStyle(
        normalized,
      );
      // Check if style is still selected to avoid race condition overwrite
      if (state.selectedStyle == normalized) {
        emit(
          state.copyWith(
            suggestedArtists: options,
            isLoadingSuggestions: false,
          ),
        );
      }
    } catch (e) {
      if (state.selectedStyle == normalized) {
        emit(state.copyWith(isLoadingSuggestions: false));
      }
    }
  }

  void addInfluence(String artist) {
    final style = state.selectedStyle;
    if (style == null) return;
    final updated = AffinityFlow.addInfluence(
      influences: state.influences,
      style: style,
      artist: artist,
    );
    if (identical(updated, state.influences)) return;
    emit(state.copyWith(influences: updated));
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
}
