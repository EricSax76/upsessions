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

class MockVenuesRepository implements VenuesRepository {
  final List<VenueEntity> _venues = [];

  @override
  Future<void> createVenue(VenueEntity venue) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _venues.add(venue);
  }

  @override
  Future<void> updateVenue(VenueEntity venue) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final index = _venues.indexWhere((item) => item.id == venue.id);
    if (index >= 0) {
      _venues[index] = venue;
    }
  }

  @override
  Future<VenueEntity> saveDraft(VenueEntity venue) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (venue.id.trim().isEmpty) {
      final created = venue.copyWith(id: 'venue-${_venues.length + 1}');
      _venues.add(created);
      return created;
    }
    final index = _venues.indexWhere((item) => item.id == venue.id);
    if (index >= 0) {
      _venues[index] = venue;
      return venue;
    }
    _venues.add(venue);
    return venue;
  }

  @override
  Future<void> deactivateVenue(String venueId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final index = _venues.indexWhere((item) => item.id == venueId);
    if (index < 0) return;
    _venues[index] = _venues[index].copyWith(isActive: false);
  }

  @override
  Future<VenueEntity?> getVenueById(String venueId) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    try {
      return _venues.firstWhere((item) => item.id == venueId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<VenuesPage> getOwnerVenuesPage({
    required String ownerId,
    String? cursor,
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _pageFrom(
      source: _venues.where((item) => item.ownerId == ownerId && item.isActive),
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<VenuesPage> getPublicVenuesPage({
    String? cursor,
    int limit = 20,
    String? city,
    String? province,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final normalizedCity = (city ?? '').trim().toLowerCase();
    final normalizedProvince = (province ?? '').trim().toLowerCase();

    return _pageFrom(
      source: _venues.where((item) {
        if (!item.isActive || !item.isPublic) return false;
        if (normalizedCity.isNotEmpty &&
            item.city.trim().toLowerCase() != normalizedCity) {
          return false;
        }
        if (normalizedProvince.isNotEmpty &&
            item.province.trim().toLowerCase() != normalizedProvince) {
          return false;
        }
        return true;
      }),
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<List<VenueEntity>> getSelectableVenues({
    required String ownerId,
    int limit = 100,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final selected = <String, VenueEntity>{};
    for (final venue in _venues) {
      if (!venue.isActive) continue;
      if (venue.ownerId == ownerId || venue.isPublic) {
        selected[venue.id] = venue;
      }
    }
    final list = selected.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (list.length <= limit) return list;
    return list.sublist(0, limit);
  }

  VenuesPage _pageFrom({
    required Iterable<VenueEntity> source,
    String? cursor,
    int limit = 20,
  }) {
    final safeLimit = limit <= 0 ? 20 : limit;
    final sorted = source.toList()..sort((a, b) => a.id.compareTo(b.id));
    final normalizedCursor = (cursor ?? '').trim();
    var startIndex = 0;
    if (normalizedCursor.isNotEmpty) {
      final index = sorted.indexWhere((item) => item.id == normalizedCursor);
      if (index >= 0) {
        startIndex = index + 1;
      }
    }

    if (startIndex >= sorted.length) {
      return const VenuesPage(items: <VenueEntity>[], hasMore: false);
    }

    final endExclusive = (startIndex + safeLimit).clamp(0, sorted.length);
    final items = sorted.sublist(startIndex, endExclusive);
    final hasMore = endExclusive < sorted.length;
    final nextCursor = hasMore && items.isNotEmpty ? items.last.id : null;
    return VenuesPage(items: items, hasMore: hasMore, nextCursor: nextCursor);
  }
}
