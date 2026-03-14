import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../../core/widgets/loading_indicator.dart';
import '../../../cubits/group_cubit.dart';
import '../../../cubits/group_state.dart';
import 'group_header.dart';
import 'group_info_tab.dart';

class GroupPageView extends StatelessWidget {
  const GroupPageView({
    super.key,
    required this.groupId,
    required this.rehearsalsTab,
  });

  final String groupId;
  final Widget rehearsalsTab;

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
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 140, // Approximate height to fit the reduced group header
                  flexibleSpace: FlexibleSpaceBar(
                    background: GroupHeader(group: group),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    minHeight: 72.0,
                    maxHeight: 72.0,
                    child: Material(
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
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                rehearsalsTab,
                GroupInfoTab(group: group),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxExtent ||
        minHeight != oldDelegate.minExtent ||
        child != oldDelegate.child;
  }
}
