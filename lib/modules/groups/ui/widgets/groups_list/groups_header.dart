import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../../core/widgets/section_title.dart';

class GroupsHeader extends StatelessWidget {
  const GroupsHeader({
    super.key,
    required this.groupCount,
    required this.visibleCount,
  });

  final int groupCount;
  final int visibleCount;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final showCount = groupCount > 0;
    final label = visibleCount == groupCount
        ? '$groupCount grupos'
        : '$visibleCount de $groupCount';
    return SectionHeader(
      title: loc.navRehearsals,
      subtitle: 'Tus grupos activos para organizar ensayos.',
      label: showCount ? label : null,
    );
  }
}
