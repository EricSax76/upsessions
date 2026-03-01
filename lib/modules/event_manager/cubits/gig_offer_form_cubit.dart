import 'package:bloc/bloc.dart';
import '../models/gig_offer_entity.dart';
import '../repositories/gig_offers_repository.dart';
import 'gig_offer_form_state.dart';

class GigOfferFormCubit extends Cubit<GigOfferFormState> {
  GigOfferFormCubit({
    required GigOffersRepository repository,
  })  : _repository = repository,
        super(const GigOfferFormState());

  final GigOffersRepository _repository;

  void _safeEmit(GigOfferFormState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> saveOffer(GigOfferEntity offer) async {
    _safeEmit(state.copyWith(isSaving: true, errorMessage: null, success: false));
    try {
      await _repository.saveOffer(offer);
      _safeEmit(state.copyWith(isSaving: false, success: true));
    } catch (e) {
      _safeEmit(state.copyWith(isSaving: false, errorMessage: e.toString()));
    }
  }
}
