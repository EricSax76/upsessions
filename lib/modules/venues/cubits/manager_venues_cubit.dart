import 'package:bloc/bloc.dart';

import '../../auth/repositories/auth_repository.dart';
import '../models/venue_entity.dart';
import '../repositories/venues_repository.dart';
import 'manager_venues_state.dart';

class ManagerVenuesCubit extends Cubit<ManagerVenuesState> {
  ManagerVenuesCubit({
    required VenuesRepository venuesRepository,
    required AuthRepository authRepository,
  }) : _venuesRepository = venuesRepository,
       _authRepository = authRepository,
       super(const ManagerVenuesState());

  final VenuesRepository _venuesRepository;
  final AuthRepository _authRepository;

  static const int _pageLimit = 24;

  void _safeEmit(ManagerVenuesState next) {
    if (!isClosed) emit(next);
  }

  Future<void> loadVenues({bool refresh = false}) async {
    if (!refresh && state.isLoading) return;

    _safeEmit(
      state.copyWith(
        isLoading: true,
        isLoadingMore: false,
        errorMessage: null,
        nextCursor: refresh ? null : state.nextCursor,
      ),
    );

    try {
      final ownerId = _authRepository.currentUser?.id ?? '';
      if (ownerId.isEmpty) {
        throw Exception('No autenticado');
      }

      final page = await _venuesRepository.getOwnerVenuesPage(
        ownerId: ownerId,
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
          isLoadingMore: false,
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
      final ownerId = _authRepository.currentUser?.id ?? '';
      if (ownerId.isEmpty) {
        throw Exception('No autenticado');
      }

      final page = await _venuesRepository.getOwnerVenuesPage(
        ownerId: ownerId,
        cursor: cursor,
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

  Future<void> deactivateVenue(VenueEntity venue) async {
    if (venue.id.trim().isEmpty) return;
    _safeEmit(state.copyWith(errorMessage: null));

    try {
      if (venue.isStudioBacked) {
        throw Exception(
          'Los locales sincronizados desde studios no se pueden editar.',
        );
      }

      await _venuesRepository.deactivateVenue(venue.id);
      final updated = state.venues
          .where((item) => item.id != venue.id)
          .toList();
      _safeEmit(state.copyWith(venues: updated, errorMessage: null));
    } catch (error) {
      _safeEmit(state.copyWith(errorMessage: 'No se pudo desactivar: $error'));
    }
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
