import 'package:equatable/equatable.dart';

import '../models/venue_entity.dart';

class VenuesCatalogState extends Equatable {
  const VenuesCatalogState({
    this.venues = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<VenueEntity> venues;
  final bool isLoading;
  final String? errorMessage;

  VenuesCatalogState copyWith({
    List<VenueEntity>? venues,
    bool? isLoading,
    String? errorMessage,
  }) {
    return VenuesCatalogState(
      venues: venues ?? this.venues,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [venues, isLoading, errorMessage];
}
