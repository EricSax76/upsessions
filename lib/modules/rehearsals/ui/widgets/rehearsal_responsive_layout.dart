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

        return Container(
          color: colorScheme.surfaceContainerLow,
          child: SingleChildScrollView(
            padding: padding ??
                EdgeInsets.symmetric(
                  vertical: isWide ? 48 : 24,
                  horizontal: isWide ? 48 : 16,
                ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (header != null) ...[
                      header!,
                      const Gap(48),
                    ],
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
        );
      },
    );
  }
}
