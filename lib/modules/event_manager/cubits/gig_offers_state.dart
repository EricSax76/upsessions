import 'package:equatable/equatable.dart';
import '../models/gig_offer_entity.dart';

class GigOffersState extends Equatable {
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
    String? errorMessage,
  }) {
    return GigOffersState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [offers, isLoading, errorMessage];
}
