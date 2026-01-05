import 'package:flutter/material.dart';

class MusicianSearchLayout extends StatelessWidget {
  const MusicianSearchLayout({
    super.key,
    required this.topBar,
    required this.filterPanelBuilder,
    required this.results,
  });

  final Widget topBar;
  final Widget Function(BuildContext context, bool isWide) filterPanelBuilder;
  final Widget results;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: topBar,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;
              final filterPanel = filterPanelBuilder(context, isWide);

              if (!isWide) {
                final maxFilterHeight = constraints.maxHeight * 0.6;
                return Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxFilterHeight),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: SingleChildScrollView(child: filterPanel),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: results,
                      ),
                    ),
                  ],
                );
              }

              final filterWidth = constraints.maxWidth * 0.32;
              return Row(
                children: [
                  SizedBox(
                    width: filterWidth,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: filterPanel,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: results,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
