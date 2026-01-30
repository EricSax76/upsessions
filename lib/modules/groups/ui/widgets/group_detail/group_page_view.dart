import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../rehearsals/ui/pages/group_rehearsals_page.dart';
import '../../../models/group_dtos.dart';
import '../../../controllers/group_page_controller.dart';
import 'group_header.dart';
import 'group_info_tab.dart';

class GroupPageView extends StatelessWidget {
  const GroupPageView({
    super.key,
    required this.groupId,
    required this.controller,
  });

  final String groupId;
  final GroupPageController controller;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<GroupDoc>(
      stream: controller.watchGroup(groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final group = snapshot.data;
        if (group == null) {
          return const Center(child: Text('Grupo no encontrado'));
        }

        return Column(
          children: [
            GroupHeader(group: group, controller: controller),
            Material(
              color: colorScheme.surface,
              child: TabBar(
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    text: loc.navRehearsals,
                    icon: const Icon(Icons.event_available),
                  ),
                  const Tab(
                    text: 'Información',
                    icon: Icon(Icons.info_outline),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  GroupRehearsalsView(
                    groupId: groupId,
                    showHeader: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                  ),
                  GroupInfoTab(group: group),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
