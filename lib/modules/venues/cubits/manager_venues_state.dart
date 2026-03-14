import 'package:equatable/equatable.dart';

import '../models/venue_entity.dart';

class ManagerVenuesState extends Equatable {
  const ManagerVenuesState({
    this.venues = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.nextCursor,
    this.errorMessage,
  });

  final List<VenueEntity> venues;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final String? errorMessage;

  ManagerVenuesState copyWith({
    List<VenueEntity>? venues,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? nextCursor = _noChange,
    Object? errorMessage = _noChange,
  }) {
    return ManagerVenuesState(
      venues: venues ?? this.venues,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor == _noChange
          ? this.nextCursor
          : nextCursor as String?,
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
    errorMessage,
  ];
}

const Object _noChange = Object();
