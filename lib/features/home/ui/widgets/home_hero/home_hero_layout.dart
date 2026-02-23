import 'package:flutter/material.dart';

import 'home_hero_compact.dart';
import 'home_hero_expanded.dart';
import 'home_hero_view_model.dart';

class HomeHeroLayout extends StatelessWidget {
  const HomeHeroLayout({
    super.key,
    required this.isCompact,
    required this.viewModel,
  });

  final bool isCompact;
  final HomeHeroViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return HomeHeroCompact(viewModel: viewModel);
    }
    return HomeHeroExpanded(viewModel: viewModel);
  }
}
