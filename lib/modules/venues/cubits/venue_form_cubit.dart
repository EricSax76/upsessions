import 'package:bloc/bloc.dart';

import '../models/venue_entity.dart';
import '../repositories/venues_repository.dart';
import 'venue_form_state.dart';

class VenueFormCubit extends Cubit<VenueFormState> {
  VenueFormCubit({required VenuesRepository venuesRepository})
    : _venuesRepository = venuesRepository,
      super(const VenueFormState());

  final VenuesRepository _venuesRepository;

  void _safeEmit(VenueFormState next) {
    if (!isClosed) emit(next);
  }

  Future<void> saveVenue(VenueEntity venue) async {
    _safeEmit(
      state.copyWith(isSaving: true, success: false, errorMessage: null),
    );

    try {
      await _venuesRepository.saveDraft(venue);
      _safeEmit(state.copyWith(isSaving: false, success: true));
    } catch (error) {
      _safeEmit(
        state.copyWith(
          isSaving: false,
          success: false,
          errorMessage: 'No se pudo guardar el local: $error',
        ),
      );
    }
  }
}
