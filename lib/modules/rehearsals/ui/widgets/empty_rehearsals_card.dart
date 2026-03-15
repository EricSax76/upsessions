import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state_card.dart';
import '../../../../l10n/app_localizations.dart';

class EmptyRehearsalsCard extends StatelessWidget {
  const EmptyRehearsalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return EmptyStateCard(
      icon: Icons.event_available_outlined,
      title: loc.rehearsalsEmptyTitle,
      subtitle: loc.rehearsalsEmptySubtitle,
    );
  }
}
