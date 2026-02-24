import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';

class PremiumOnboardingScaffold extends StatelessWidget {
  const PremiumOnboardingScaffold({
    super.key,
    required this.title,
    required this.progress,
    required this.content,
    required this.onContinue,
    required this.continueButtonText,
    this.isSaving = false,
  });

  final String title;
  final double progress;
  final Widget content;
  final VoidCallback? onContinue;
  final String continueButtonText;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final normalizedProgress = progress.clamp(0.0, 1.0).toDouble();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: normalizedProgress,
                  minHeight: 6,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(child: content),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: FilledButton(
                onPressed: isSaving ? null : onContinue,
                child: isSaving
                    ? SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Text(continueButtonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
