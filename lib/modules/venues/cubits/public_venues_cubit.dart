import 'package:bloc/bloc.dart';

import '../models/venue_entity.dart';
import '../repositories/venues_repository.dart';
import 'public_venues_state.dart';

class PublicVenuesCubit extends Cubit<PublicVenuesState> {
  PublicVenuesCubit({required VenuesRepository venuesRepository})
    : _venuesRepository = venuesRepository,
      super(const PublicVenuesState());

  final VenuesRepository _venuesRepository;

  static const int _pageLimit = 24;

  void _safeEmit(PublicVenuesState next) {
    if (!isClosed) emit(next);
  }

  Future<void> loadVenues({
    bool refresh = false,
    String? city,
    String? province,
  }) async {
    if (!refresh && state.isLoading) return;

    final resolvedCity = (city ?? state.city).trim();
    final resolvedProvince = (province ?? state.province).trim();

    _safeEmit(
      state.copyWith(
        isLoading: true,
        isLoadingMore: false,
        errorMessage: null,
        city: resolvedCity,
        province: resolvedProvince,
        nextCursor: null,
      ),
    );

    try {
      final page = await _venuesRepository.getPublicVenuesPage(
        city: resolvedCity.isEmpty ? null : resolvedCity,
        province: resolvedProvince.isEmpty ? null : resolvedProvince,
        limit: _pageLimit,
      );

      _safeEmit(
        state.copyWith(
          isLoading: false,
          venues: page.items,
          hasMore: page.hasMore,
          nextCursor: page.nextCursor,
          errorMessage: null,
        ),
      );
    } catch (error) {
      _safeEmit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'No se pudieron cargar los locales: $error',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    final cursor = (state.nextCursor ?? '').trim();
    if (cursor.isEmpty) return;

    _safeEmit(state.copyWith(isLoadingMore: true, errorMessage: null));

    try {
      final page = await _venuesRepository.getPublicVenuesPage(
        cursor: cursor,
        city: state.city.trim().isEmpty ? null : state.city.trim(),
        province: state.province.trim().isEmpty ? null : state.province.trim(),
        limit: _pageLimit,
      );

      final merged = _mergeById(state.venues, page.items);

      _safeEmit(
        state.copyWith(
          isLoadingMore: false,
          venues: merged,
          hasMore: page.hasMore,
          nextCursor: page.nextCursor,
          errorMessage: null,
        ),
      );
    } catch (error) {
      _safeEmit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: 'No se pudieron cargar más locales: $error',
        ),
      );
    }
  }

  Future<void> applyFilters({String city = '', String province = ''}) async {
    await loadVenues(refresh: true, city: city, province: province);
  }

  List<VenueEntity> _mergeById(
    List<VenueEntity> first,
    List<VenueEntity> second,
  ) {
    final byId = <String, VenueEntity>{};
    for (final venue in first) {
      byId[venue.id] = venue;
    }
    for (final venue in second) {
      byId[venue.id] = venue;
    }

    final merged = byId.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return merged;
  }
}
