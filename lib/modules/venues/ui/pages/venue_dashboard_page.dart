import 'package:flutter/material.dart';
import 'package:upsessions/core/constants/app_routes.dart';

import 'manager_venues_page.dart';

class VenueDashboardPage extends StatelessWidget {
  const VenueDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ManagerVenuesPage(
      createVenueRoute: AppRoutes.venuesDashboardVenueForm,
      editVenueRoutePathBuilder: AppRoutes.venuesDashboardVenueEditPath,
      headingTitle: 'Mis Venues',
    );
  }
}
