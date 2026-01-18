import 'package:flutter/material.dart';

import '../../../../../core/widgets/adaptive_search_layout.dart';

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
    return AdaptiveSearchLayout(
      topBar: topBar,
      filterPanelBuilder: filterPanelBuilder,
      results: results,
    );
  }
}
