import '../models/venue_entity.dart';

class VenuesPage {
  const VenuesPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<VenueEntity> items;
  final bool hasMore;
  final String? nextCursor;
}

abstract class VenuesRepository {
  Future<void> createVenue(VenueEntity venue);
  Future<void> updateVenue(VenueEntity venue);
  Future<VenueEntity> saveDraft(VenueEntity venue);
  Future<void> deactivateVenue(String venueId);
  Future<VenueEntity?> getVenueById(String venueId);

  Future<VenuesPage> getOwnerVenuesPage({
    required String ownerId,
    String? cursor,
    int limit = 20,
  });

  Future<VenuesPage> getPublicVenuesPage({
    String? cursor,
    int limit = 20,
    String? city,
    String? province,
  });

  Future<List<VenueEntity>> getSelectableVenues({
    required String ownerId,
    int limit = 100,
  });
}
