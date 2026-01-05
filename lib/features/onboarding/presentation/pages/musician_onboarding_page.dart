import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import 'package:upsessions/modules/auth/data/auth_repository.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import '../controllers/musician_onboarding_controller.dart';
import '../widgets/musician_onboarding_missing_session_view.dart';
import '../widgets/steps/musician_basic_info_step.dart';
import '../widgets/steps/musician_experience_step.dart';
import '../widgets/steps/musician_extras_step.dart';

class MusicianOnboardingPage extends StatefulWidget {
  const MusicianOnboardingPage({super.key});

  @override
  State<MusicianOnboardingPage> createState() => _MusicianOnboardingPageState();
}

class _MusicianOnboardingPageState extends State<MusicianOnboardingPage> {
  late final MusicianOnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MusicianOnboardingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    final user = authRepository.currentUser;

    if (user == null) {
      return const MusicianOnboardingMissingSessionView();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final steps = _buildSteps();
        final progress = (_controller.currentStep + 1) / steps.length;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Cuéntanos sobre ti y tu pasión por la música'),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 16),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: steps[_controller.currentStep],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (_controller.currentStep > 0)
                        OutlinedButton(
                          onPressed: _controller.isSaving
                              ? null
                              : _controller.previousStep,
                          child: const Text('Atrás'),
                        ),
                      if (_controller.currentStep > 0)
                        const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _controller.isSaving
                              ? null
                              : () => _handleContinue(steps.length, user.id),
                          child: Text(
                            _controller.currentStep == steps.length - 1
                                ? 'Finalizar'
                                : 'Continuar',
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_controller.isSaving) ...[
                    const SizedBox(height: 12),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSteps() {
    return [
      MusicianBasicInfoStep(controller: _controller),
      MusicianExperienceStep(controller: _controller),
      MusicianExtrasStep(controller: _controller),
    ];
  }

  Future<void> _handleContinue(int totalSteps, String musicianId) async {
    if (!_controller.validateCurrentStep()) {
      return;
    }

    if (_controller.currentStep < totalSteps - 1) {
      _controller.nextStep();
      return;
    }

    final repository = context.read<MusiciansRepository>();

    try {
      await _controller.submit(repository: repository, musicianId: musicianId);
      if (!mounted) return;
      context.go(AppRoutes.userHome);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos guardar tu perfil: $error')),
      );
    }
  }
}
