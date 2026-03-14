import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_routes.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/auth/repositories/profile_repository.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';

import '../../../../modules/musicians/repositories/affinity_options_repository.dart';
import '../../../../modules/musicians/repositories/artist_image_repository.dart';
import '../../cubits/musician_onboarding_cubit.dart';
import '../../cubits/musician_onboarding_state.dart';
import '../controllers/musician_onboarding_form_controller.dart';
import '../widgets/musician_onboarding_missing_session_view.dart';
import 'musician_identity_step.dart';
import '../widgets/musician_experience_step.dart';
import '../widgets/musician_extras_step.dart';
import '../widgets/musician_influences_step.dart';
import '../widgets/premium_onboarding_scaffold.dart';

class MusicianOnboardingPage extends StatefulWidget {
  const MusicianOnboardingPage({
    super.key,
    required this.affinityOptionsRepository,
    required this.artistImageRepository,
  });

  final AffinityOptionsRepository affinityOptionsRepository;
  final ArtistImageRepository artistImageRepository;

  @override
  State<MusicianOnboardingPage> createState() => _MusicianOnboardingPageState();
}

class _MusicianOnboardingPageState extends State<MusicianOnboardingPage> {
  late final MusicianOnboardingFormController _form;

  @override
  void initState() {
    super.initState();
    _form = MusicianOnboardingFormController();
    _form.addListener(_onFormChanged);
  }

  void _onFormChanged() => setState(() {});

  @override
  void dispose() {
    _form.removeListener(_onFormChanged);
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthRepository>().currentUser;

    if (user == null) {
      return const MusicianOnboardingMissingSessionView();
    }

    return BlocProvider(
      create: (_) => MusicianOnboardingCubit(
        repository: context.read<MusiciansRepository>(),
      ),
      child: BlocListener<MusicianOnboardingCubit, MusicianOnboardingState>(
        listenWhen: (prev, curr) =>
            curr.status == MusicianOnboardingStatus.saved ||
            curr.status == MusicianOnboardingStatus.error,
        listener: (context, state) {
          if (state.status == MusicianOnboardingStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'No pudimos guardar tu perfil: ${state.errorMessage}',
                ),
              ),
            );
          }
        },
        child: BlocBuilder<MusicianOnboardingCubit, MusicianOnboardingState>(
          builder: (context, state) {
            final cubit = context.read<MusicianOnboardingCubit>();
            final steps = _buildSteps(cubit);
            final progress = (state.currentStep + 1) / steps.length;
            final isBusy = state.isSaving || _form.isUploadingPhoto;

            return PremiumOnboardingScaffold(
              title: 'Cuéntanos sobre ti y tu pasión por la música',
              progress: progress,
              isSaving: isBusy,
              continueButtonText: state.currentStep == steps.length - 1
                  ? 'Finalizar'
                  : 'Continuar',
              onContinue: () => _handleContinue(
                cubit: cubit,
                totalSteps: steps.length,
                musicianId: user.id,
              ),
              content: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(state.currentStep),
                  child: steps[state.currentStep],
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
      MusicianIdentityStep(
        formKey: _form.basicInfoKey,
        nameController: _form.nameController,
        instrumentController: _form.instrumentController,
        birthDate: _form.birthDate,
        birthDateLabel: _form.birthDateLabel,
        onBirthDateChanged: _form.setBirthDate,
        legalGuardianEmailController: _form.legalGuardianEmailController,
        legalGuardianConsent: _form.legalGuardianConsent,
        onLegalGuardianConsentChanged: _form.setLegalGuardianConsent,
      ),
      MusicianExperienceStep(
        formKey: _form.experienceKey,
        cityController: _form.cityController,
        stylesController: _form.stylesController,
        yearsController: _form.yearsController,
      ),
      MusicianInfluencesStep(
        formKey: _form.influencesKey,
        cubit: cubit,
        affinityOptionsRepository: widget.affinityOptionsRepository,
        artistImageRepository: widget.artistImageRepository,
      ),
      MusicianExtrasStep(
        formKey: _form.extrasKey,
        bioController: _form.bioController,
        selectedPhotoName: _form.selectedPhotoName,
        onPickPhoto: _pickPhoto,
        onClearPhoto: _form.clearSelectedPhoto,
        availableForHire: cubit.state.availableForHire,
        onAvailableForHireChanged: cubit.toggleAvailableForHire,
      ),
    ];
  }

  Future<void> _handleContinue({
    required MusicianOnboardingCubit cubit,
    required int totalSteps,
    required String musicianId,
  }) async {
    if (_form.isUploadingPhoto) return;
    if (!_form.validateStep(cubit.state.currentStep)) return;

    if (cubit.state.currentStep < totalSteps - 1) {
      cubit.nextStep();
      return;
    }

    await cubit.submit(
      musicianId: musicianId,
      name: _form.nameController.text.trim(),
      instrument: _form.instrumentController.text.trim(),
      city: _form.cityController.text.trim(),
      styles: _form.parsedStyles,
      experienceYears: _form.parsedExperienceYears,
      birthDate: _form.birthDate,
      legalGuardianEmail: _form.isMinor
          ? _form.legalGuardianEmailController.text.trim()
          : '',
      legalGuardianConsent: _form.isMinor && _form.legalGuardianConsent,
      bio: _form.bioOrNull,
    );

    if (!mounted || cubit.state.status != MusicianOnboardingStatus.saved) {
      return;
    }

    final selectedPhoto = _form.selectedPhoto;
    if (selectedPhoto != null) {
      _form.setUploadingPhoto(true);
      try {
        final bytes = await selectedPhoto.readAsBytes();
        final extension = _form.extensionFromFileName(selectedPhoto.name);
        if (!mounted) return;
        await context.read<ProfileRepository>().uploadProfilePhoto(
          userId: musicianId,
          bytes: bytes,
          fileExtension: extension,
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No pudimos subir tu foto: $error')),
        );
        return;
      } finally {
        _form.setUploadingPhoto(false);
      }
    }

    if (!mounted) return;
    context.go(AppRoutes.userHome);
  }

  Future<void> _pickPhoto() async {
    final source = await _showImageSourcePicker();
    if (source == null || !mounted) return;
    await _form.pickImage(source);
  }

  Future<ImageSource?> _showImageSourcePicker() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Seleccionar de la galería'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Usar la cámara'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }
}
