import 'package:flutter/material.dart';

import '../../../models/venue_entity.dart';
import '../public_venue_card.dart';
import 'public_venues_load_more_footer.dart';

class PublicVenuesList extends StatelessWidget {
  const PublicVenuesList({
    super.key,
    required this.venues,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final List<VenueEntity> venues;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      itemCount: venues.length + 1,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == venues.length) {
          return PublicVenuesLoadMoreFooter(
            hasMore: hasMore,
            isLoadingMore: isLoadingMore,
            onLoadMore: onLoadMore,
          );
        }

        return PublicVenueCard(venue: venues[index]);
      },
    );
  }
}
