import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';

class CollaborateOnboardingPage extends StatelessWidget {
  const CollaborateOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingStoryLayout(
      title: 'Conecta con músicos reales',
      description:
          'Descubre instrumentistas y productores disponibles para sesiones en vivo o remotas.',
      icon: Icons.group_work_outlined,
      step: 1,
      totalSteps: 3,
      onContinue: () => context.go(AppRoutes.onboardingStoryTwo),
    );
  }
}

class ShowcaseOnboardingPage extends StatelessWidget {
  const ShowcaseOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingStoryLayout(
      title: 'Muestra tu talento',
      description: 'Comparte tu música',
      icon: Icons.mic_none_outlined,
      step: 2,
      totalSteps: 3,
      onContinue: () => context.go(AppRoutes.onboardingStoryThree),
    );
  }
}

class BookOnboardingPage extends StatelessWidget {
  const BookOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingStoryLayout(
      title: 'Tu centro de reservas musical',
      description:
          'Coordina disponibilidad, contratos y pagos en pocos clicks.',
      icon: Icons.calendar_today_outlined,
      step: 3,
      totalSteps: 3,
      primaryLabel: 'Iniciar sesión',
      onContinue: () => context.go(AppRoutes.login),
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
    this.primaryLabel = 'Siguiente',
  });

  final String title;
  final String description;
  final IconData icon;
  final int step;
  final int totalSteps;
  final VoidCallback onContinue;
  final String primaryLabel;

  void _skip(BuildContext context) {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  onPressed: () => _skip(context),
                  child: const Text('Saltar'),
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
              FilledButton(onPressed: onContinue, child: Text(primaryLabel)),
            ],
          ),
        ),
      ),
    );
  }
}
