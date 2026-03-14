import 'package:bloc/bloc.dart';

import '../../auth/repositories/auth_repository.dart';
import '../repositories/venues_repository.dart';
import 'venues_catalog_state.dart';

class VenuesCatalogCubit extends Cubit<VenuesCatalogState> {
  VenuesCatalogCubit({
    required VenuesRepository venuesRepository,
    required AuthRepository authRepository,
  }) : _venuesRepository = venuesRepository,
       _authRepository = authRepository,
       super(const VenuesCatalogState());

  final VenuesRepository _venuesRepository;
  final AuthRepository _authRepository;

  void _safeEmit(VenuesCatalogState next) {
    if (!isClosed) emit(next);
  }

  Future<void> loadSelectableVenues({bool refresh = false}) async {
    if (!refresh && state.isLoading) return;
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final ownerId = _authRepository.currentUser?.id ?? '';
      if (ownerId.isEmpty) {
        throw Exception('No autenticado');
      }
      final venues = await _venuesRepository.getSelectableVenues(
        ownerId: ownerId,
      );
      _safeEmit(
        state.copyWith(isLoading: false, venues: venues, errorMessage: null),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'No se pudieron cargar los locales: $e',
        ),
      );
    }
  }
}
