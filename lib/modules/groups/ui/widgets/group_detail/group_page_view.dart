import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../../core/widgets/loading_indicator.dart';
import '../../../../rehearsals/ui/pages/group_rehearsals_page.dart';
import '../../../cubits/group_cubit.dart';
import '../../../cubits/group_state.dart';
import 'group_header.dart';
import 'group_info_tab.dart';

class GroupPageView extends StatelessWidget {
  const GroupPageView({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<GroupCubit, GroupState>(
      builder: (context, state) {
        if (state is GroupLoading) {
          return const LoadingIndicator();
        }
        if (state is GroupError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is GroupLoaded) {
          final group = state.group;
          return Column(
            children: [
              GroupHeader(group: group),
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
        }
        return const SizedBox.shrink();
      },
    );
  }
}
