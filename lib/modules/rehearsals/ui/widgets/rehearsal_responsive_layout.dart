import 'package:flutter/material.dart';

import '../../../../core/widgets/gap.dart';

/// Responsive layout wrapper for rehearsal pages.
/// Handles the main content + sidebar pattern common in desktop views.
class RehearsalResponsiveLayout extends StatelessWidget {
  const RehearsalResponsiveLayout({
    super.key,
    required this.header,
    required this.mainContent,
    this.sidebar,
    this.padding,
  });

  final Widget? header;
  final Widget mainContent;
  final Widget? sidebar;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width >= 1200;
        final showSidebar = isWide && sidebar != null;
        
        final horizontalPadding = isWide ? 48.0 : 16.0;
        final verticalPadding = isWide ? 48.0 : 24.0;

        return Container(
          color: colorScheme.surfaceContainerLow,
          child: CustomScrollView(
            slivers: [
              if (header != null)
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: verticalPadding,
                    left: horizontalPadding,
                    right: horizontalPadding,
                    bottom: 32.0,
                  ),
                  sliver: SliverAppBar(
                    floating: true,
                    snap: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    toolbarHeight: 220, // Approximate height to fit the hero section
                    flexibleSpace: FlexibleSpaceBar(
                      background: header!,
                    ),
                  ),
                ),
              SliverPadding(
                padding: padding ??
                    EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: verticalPadding,
                    ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: mainContent,
                              ),
                              if (showSidebar) ...[
                                const Gap(32),
                                Expanded(
                                  flex: 2,
                                  child: sidebar!,
                                ),
                              ],
                            ],
                          ),
                          const Gap(48),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
