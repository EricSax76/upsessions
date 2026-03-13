import 'package:equatable/equatable.dart';
import '../models/gig_offer_entity.dart';

class GigOffersState extends Equatable {
  static const Object _unset = Object();

  const GigOffersState({
    this.offers = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  final List<GigOfferEntity> offers;
  final bool isLoading;
  final String? errorMessage;

  GigOffersState copyWith({
    List<GigOfferEntity>? offers,
    bool? isLoading,
    Object? errorMessage = _unset,
  }) {
    return GigOffersState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [offers, isLoading, errorMessage];
}
