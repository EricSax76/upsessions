import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import '../../cubits/musician_onboarding_cubit.dart';
import '../../cubits/musician_onboarding_state.dart';
import '../widgets/musician_onboarding_missing_session_view.dart';
import '../widgets/musician_basic_info_step.dart';
import '../widgets/musician_experience_step.dart';
import '../widgets/musician_extras_step.dart';
import '../widgets/musician_influences_step.dart';

class MusicianOnboardingPage extends StatefulWidget {
  const MusicianOnboardingPage({super.key});

  @override
  State<MusicianOnboardingPage> createState() => _MusicianOnboardingPageState();
}

class _MusicianOnboardingPageState extends State<MusicianOnboardingPage> {
  final _basicInfoKey = GlobalKey<FormState>();
  final _experienceKey = GlobalKey<FormState>();
  final _extrasKey = GlobalKey<FormState>();
  final _influencesKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _instrumentController = TextEditingController();
  final _cityController = TextEditingController();
  final _stylesController = TextEditingController();
  final _yearsController = TextEditingController(text: '0');
  final _photoUrlController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _instrumentController.dispose();
    _cityController.dispose();
    _stylesController.dispose();
    _yearsController.dispose();
    _photoUrlController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  List<String> get _parsedStyles => _stylesController.text
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  int get _parsedExperienceYears =>
      int.tryParse(_yearsController.text) ?? 0;

  String? get _photoUrlOrNull {
    final value = _photoUrlController.text.trim();
    return value.isEmpty ? null : value;
  }

  String? get _bioOrNull {
    final value = _bioController.text.trim();
    return value.isEmpty ? null : value;
  }

  bool _validateCurrentStep(int step) {
    switch (step) {
      case 0:
        return _basicInfoKey.currentState?.validate() ?? false;
      case 1:
        return _experienceKey.currentState?.validate() ?? false;
      case 2:
        return true;
      case 3:
        return _extrasKey.currentState?.validate() ?? true;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    final user = authRepository.currentUser;

    if (user == null) {
      return const MusicianOnboardingMissingSessionView();
    }

    return BlocProvider(
      create: (_) => MusicianOnboardingCubit(),
      child: BlocListener<MusicianOnboardingCubit, MusicianOnboardingState>(
        listenWhen: (prev, curr) =>
            curr.status == MusicianOnboardingStatus.saved ||
            curr.status == MusicianOnboardingStatus.error,
        listener: (context, state) {
          if (state.status == MusicianOnboardingStatus.saved) {
            context.go(AppRoutes.userHome);
          } else if (state.status == MusicianOnboardingStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'No pudimos guardar tu perfil: ${state.errorMessage}'),
              ),
            );
          }
        },
        child: BlocBuilder<MusicianOnboardingCubit, MusicianOnboardingState>(
          builder: (context, state) {
            final cubit = context.read<MusicianOnboardingCubit>();
            final steps = _buildSteps(cubit);
            final progress = (state.currentStep + 1) / steps.length;

            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Text(
                    'Cuéntanos sobre ti y tu pasión por la música'),
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
                          child: steps[state.currentStep],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (state.currentStep > 0)
                            OutlinedButton(
                              onPressed:
                                  state.isSaving ? null : cubit.previousStep,
                              child: const Text('Atrás'),
                            ),
                          if (state.currentStep > 0)
                            const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: state.isSaving
                                  ? null
                                  : () => _handleContinue(
                                        context,
                                        steps.length,
                                        user.id,
                                      ),
                              child: Text(
                                state.currentStep == steps.length - 1
                                    ? 'Finalizar'
                                    : 'Continuar',
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (state.isSaving) ...[
                        const SizedBox(height: 12),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildSteps(MusicianOnboardingCubit cubit) {
    return [
      MusicianBasicInfoStep(
        formKey: _basicInfoKey,
        nameController: _nameController,
        instrumentController: _instrumentController,
        cityController: _cityController,
        stylesController: _stylesController,
      ),
      MusicianExperienceStep(
        formKey: _experienceKey,
        cityController: _cityController,
        stylesController: _stylesController,
        yearsController: _yearsController,
      ),
      MusicianInfluencesStep(
        formKey: _influencesKey,
        cubit: cubit,
      ),
      MusicianExtrasStep(
        formKey: _extrasKey,
        photoUrlController: _photoUrlController,
        bioController: _bioController,
      ),
    ];
  }

  void _handleContinue(
      BuildContext context, int totalSteps, String musicianId) {
    final cubit = context.read<MusicianOnboardingCubit>();

    if (!_validateCurrentStep(cubit.state.currentStep)) return;

    if (cubit.state.currentStep < totalSteps - 1) {
      cubit.nextStep();
      return;
    }

    final repository = context.read<MusiciansRepository>();
    cubit.submit(
      repository: repository,
      musicianId: musicianId,
      name: _nameController.text.trim(),
      instrument: _instrumentController.text.trim(),
      city: _cityController.text.trim(),
      styles: _parsedStyles,
      experienceYears: _parsedExperienceYears,
      photoUrl: _photoUrlOrNull,
      bio: _bioOrNull,
    );
  }
}
