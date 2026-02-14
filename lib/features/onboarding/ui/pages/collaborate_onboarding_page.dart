import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../widgets/onboarding_story_layout.dart';

class CollaborateOnboardingPage extends StatelessWidget {
  const CollaborateOnboardingPage({
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
      title: loc.onboardingCollaborateTitle,
      description: loc.onboardingCollaborateDescription,
      icon: Icons.group_work_outlined,
      step: 1,
      totalSteps: 3,
      onContinue: onContinue,
      onSkip: onSkip,
    );
  }
}
