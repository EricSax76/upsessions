import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

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

class OnboardingStoryLayout extends StatelessWidget {
  const OnboardingStoryLayout({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.step,
    required this.totalSteps,
    required this.onContinue,
    required this.onSkip,
    this.primaryLabel,
  });

  final String title;
  final String description;
  final IconData icon;
  final int step;
  final int totalSteps;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final String? primaryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final resolvedPrimaryLabel = primaryLabel ?? loc.next;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(loc.skip),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 96, color: theme.colorScheme.primary),
                    const SizedBox(height: 32),
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  totalSteps,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: index + 1 == step ? 32 : 12,
                    decoration: BoxDecoration(
                      color: index + 1 == step
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onContinue,
                child: Text(resolvedPrimaryLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
