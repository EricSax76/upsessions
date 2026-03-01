import 'package:bloc/bloc.dart';
import '../repositories/gig_offers_repository.dart';
import 'gig_offers_state.dart';

class GigOffersCubit extends Cubit<GigOffersState> {
  GigOffersCubit({
    required GigOffersRepository repository,
  })  : _repository = repository,
        super(const GigOffersState());

  final GigOffersRepository _repository;

  void _safeEmit(GigOffersState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadOffers() async {
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final offers = await _repository.fetchManagerOffers();
      _safeEmit(state.copyWith(isLoading: false, offers: offers));
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> deleteOffer(String offerId) async {
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.deleteOffer(offerId);
      final updated = state.offers.where((o) => o.id != offerId).toList();
      _safeEmit(state.copyWith(isLoading: false, offers: updated));
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
