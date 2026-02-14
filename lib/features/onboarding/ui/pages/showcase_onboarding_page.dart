import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../widgets/onboarding_story_layout.dart';

class ShowcaseOnboardingPage extends StatelessWidget {
  const ShowcaseOnboardingPage({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return OnboardingStoryLayout(
      title: loc.onboardingShowcaseTitle,
      description: loc.onboardingShowcaseDescription,
      icon: Icons.mic_none_outlined,
      step: 2,
      totalSteps: 3,
      onContinue: onContinue,
      onSkip: onSkip,
    );
  }
}
