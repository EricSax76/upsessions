import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';

class MusicianOnboardingStepCard extends StatelessWidget {
  const MusicianOnboardingStepCard({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SectionCard(title: title, subtitle: description, child: child),
        )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
