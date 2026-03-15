import 'package:flutter/material.dart';

import '../../../models/venue_entity.dart';
import '../manager_venue_card.dart';
import 'manager_venues_header.dart';
import 'manager_venues_load_more_footer.dart';

class ManagerVenuesList extends StatelessWidget {
  const ManagerVenuesList({
    super.key,
    required this.headingTitle,
    required this.venues,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onEdit,
    required this.onDeactivate,
  });

  final String headingTitle;
  final List<VenueEntity> venues;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final ValueChanged<VenueEntity> onEdit;
  final ValueChanged<VenueEntity> onDeactivate;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: venues.length + 2,
      separatorBuilder: (context, index) {
        if (index == 0 || index == venues.length + 1) {
          return const SizedBox.shrink();
        }
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return ManagerVenuesHeader(title: headingTitle);
        }

        if (index == venues.length + 1) {
          return ManagerVenuesLoadMoreFooter(
            hasMore: hasMore,
            isLoadingMore: isLoadingMore,
            onLoadMore: onLoadMore,
          );
        }

        final venue = venues[index - 1];
        return ManagerVenueCard(
          venue: venue,
          onTap: () => onEdit(venue),
          onEdit: () => onEdit(venue),
          onDeactivate: () => onDeactivate(venue),
        );
      },
    );
  }
}
