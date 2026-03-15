import 'package:flutter/material.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import 'manager_venues_page.dart';

class VenueDashboardPage extends StatelessWidget {
  const VenueDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagerVenuesPage(
      createVenueRoute: AppRoutes.venuesDashboardVenueForm,
      editVenueRoutePathBuilder: AppRoutes.venuesDashboardVenueEditPath,
      headingTitle: AppLocalizations.of(context).venueManagerHeadingTitle,
    );
  }
}
