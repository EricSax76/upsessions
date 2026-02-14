import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../widgets/onboarding_story_layout.dart';

class BookOnboardingPage extends StatelessWidget {
  const BookOnboardingPage({
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
      title: loc.onboardingBookTitle,
      description: loc.onboardingBookDescription,
      icon: Icons.calendar_today_outlined,
      step: 3,
      totalSteps: 3,
      primaryLabel: loc.login,
      onContinue: onContinue,
      onSkip: onSkip,
    );
  }
}
