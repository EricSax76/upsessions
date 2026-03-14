import 'package:equatable/equatable.dart';

import '../models/venue_entity.dart';

class PublicVenuesState extends Equatable {
  const PublicVenuesState({
    this.venues = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.nextCursor,
    this.city = '',
    this.province = '',
    this.errorMessage,
  });

  final List<VenueEntity> venues;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final String city;
  final String province;
  final String? errorMessage;

  PublicVenuesState copyWith({
    List<VenueEntity>? venues,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? nextCursor = _noChange,
    String? city,
    String? province,
    Object? errorMessage = _noChange,
  }) {
    return PublicVenuesState(
      venues: venues ?? this.venues,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor == _noChange
          ? this.nextCursor
          : nextCursor as String?,
      city: city ?? this.city,
      province: province ?? this.province,
      errorMessage: errorMessage == _noChange
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    venues,
    isLoading,
    isLoadingMore,
    hasMore,
    nextCursor,
    city,
    province,
    errorMessage,
  ];
}

const Object _noChange = Object();
