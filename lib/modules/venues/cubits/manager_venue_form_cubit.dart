import 'package:bloc/bloc.dart';

import '../../auth/repositories/auth_repository.dart';
import '../models/venue_entity.dart';
import '../repositories/venues_repository.dart';
import '../ui/forms/venue_form_draft.dart';
import 'manager_venue_form_state.dart';

class ManagerVenueFormCubit extends Cubit<ManagerVenueFormState> {
  ManagerVenueFormCubit({
    required VenuesRepository venuesRepository,
    required AuthRepository authRepository,
    VenueFormDraft? draft,
  }) : _venuesRepository = venuesRepository,
       _authRepository = authRepository,
       draft = draft ?? VenueFormDraft(),
       super(const ManagerVenueFormState());

  final VenuesRepository _venuesRepository;
  final AuthRepository _authRepository;
  final VenueFormDraft draft;

  Future<void> initialize({String? venueId, VenueEntity? initialVenue}) async {
    if (initialVenue != null) {
      draft.fillFromVenue(initialVenue);
      emit(
        state.copyWith(
          editingVenue: initialVenue,
          isPublic: initialVenue.isPublic,
          requestedVenueId: initialVenue.id,
          isLoading: false,
          loadingError: null,
        ),
      );
      return;
    }

    final normalizedVenueId = (venueId ?? '').trim();
    if (normalizedVenueId.isEmpty) {
      emit(
        state.copyWith(
          requestedVenueId: null,
          editingVenue: null,
          isPublic: true,
          isLoading: false,
          loadingError: null,
        ),
      );
      return;
    }

    emit(state.copyWith(requestedVenueId: normalizedVenueId));
    await _loadVenue(normalizedVenueId);
  }

  void setIsPublic(bool value) {
    if (value == state.isPublic) return;
    emit(state.copyWith(isPublic: value));
  }

  Future<void> retryLoad() async {
    final venueId = (state.requestedVenueId ?? '').trim();
    if (venueId.isEmpty) return;
    await _loadVenue(venueId);
  }

  Future<void> saveVenue() async {
    if (state.isSaving) return;

    final managerId = _authRepository.currentUser?.id.trim() ?? '';
    if (managerId.isEmpty) {
      emit(
        state.copyWith(
          saveSuccess: false,
          feedbackMessage: 'Debes iniciar sesión para gestionar locales.',
        ),
      );
      return;
    }

    if (state.editingVenue?.isStudioBacked ?? false) {
      emit(
        state.copyWith(
          saveSuccess: false,
          feedbackMessage:
              'Este local viene de studios y no se edita desde aquí.',
        ),
      );
      return;
    }

    final venue = draft.toVenueEntity(
      ownerId: managerId,
      isPublic: state.isPublic,
      initialVenue: state.editingVenue,
    );

    emit(
      state.copyWith(isSaving: true, saveSuccess: false, feedbackMessage: null),
    );

    try {
      final savedVenue = await _venuesRepository.saveDraft(venue);
      emit(
        state.copyWith(
          isSaving: false,
          saveSuccess: true,
          editingVenue: savedVenue,
          isPublic: savedVenue.isPublic,
          requestedVenueId: savedVenue.id,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSaving: false,
          saveSuccess: false,
          feedbackMessage: 'No se pudo guardar el local: $error',
        ),
      );
    }
  }

  void clearTransientFeedback() {
    if (state.feedbackMessage == null && !state.saveSuccess) return;
    emit(state.copyWith(feedbackMessage: null, saveSuccess: false));
  }

  Future<void> _loadVenue(String venueId) async {
    emit(
      state.copyWith(
        isLoading: true,
        loadingError: null,
        feedbackMessage: null,
        saveSuccess: false,
      ),
    );

    try {
      final venue = await _venuesRepository.getVenueById(venueId);
      if (venue == null) {
        throw Exception('Local no encontrado');
      }
      draft.fillFromVenue(venue);
      emit(
        state.copyWith(
          isLoading: false,
          editingVenue: venue,
          isPublic: venue.isPublic,
          loadingError: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          loadingError: 'No se pudo cargar el local: $error',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    draft.dispose();
    return super.close();
  }
}
