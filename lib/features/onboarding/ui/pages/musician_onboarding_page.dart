import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_routes.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/auth/repositories/profile_repository.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';

import '../../../../modules/musicians/repositories/affinity_options_repository.dart';
import '../../cubits/musician_onboarding_cubit.dart';
import '../../cubits/musician_onboarding_state.dart';
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
  });

  final AffinityOptionsRepository affinityOptionsRepository;

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
  final _bioController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedPhoto;
  bool _isUploadingPhoto = false;

  @override
  void dispose() {
    _nameController.dispose();
    _instrumentController.dispose();
    _cityController.dispose();
    _stylesController.dispose();
    _yearsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  List<String> get _parsedStyles => _stylesController.text
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  int get _parsedExperienceYears => int.tryParse(_yearsController.text) ?? 0;

  String? get _bioOrNull {
    final value = _bioController.text.trim();
    return value.isEmpty ? null : value;
  }

  String? get _selectedPhotoName {
    final photo = _selectedPhoto;
    if (photo == null) return null;
    final value = photo.name.trim();
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
            final isBusy = state.isSaving || _isUploadingPhoto;

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
        formKey: _basicInfoKey,
        nameController: _nameController,
        instrumentController: _instrumentController,
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
        affinityOptionsRepository: widget.affinityOptionsRepository,
      ),
      MusicianExtrasStep(
        formKey: _extrasKey,
        bioController: _bioController,
        selectedPhotoName: _selectedPhotoName,
        onPickPhoto: _pickPhoto,
        onClearPhoto: () => setState(() => _selectedPhoto = null),
      ),
    ];
  }

  Future<void> _handleContinue({
    required MusicianOnboardingCubit cubit,
    required int totalSteps,
    required String musicianId,
  }) async {
    if (_isUploadingPhoto) return;
    if (!_validateCurrentStep(cubit.state.currentStep)) return;

    if (cubit.state.currentStep < totalSteps - 1) {
      cubit.nextStep();
      return;
    }

    await cubit.submit(
      musicianId: musicianId,
      name: _nameController.text.trim(),
      instrument: _instrumentController.text.trim(),
      city: _cityController.text.trim(),
      styles: _parsedStyles,
      experienceYears: _parsedExperienceYears,
      bio: _bioOrNull,
    );

    if (!mounted || cubit.state.status != MusicianOnboardingStatus.saved) {
      return;
    }

    final selectedPhoto = _selectedPhoto;
    if (selectedPhoto != null) {
      setState(() => _isUploadingPhoto = true);
      try {
        final bytes = await selectedPhoto.readAsBytes();
        final extension = _extensionFromFileName(selectedPhoto.name);
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
        if (mounted) {
          setState(() => _isUploadingPhoto = false);
        }
      }
    }

    if (!mounted) return;
    context.go(AppRoutes.userHome);
  }

  Future<void> _pickPhoto() async {
    if (_isUploadingPhoto) return;
    final source = await _pickSource();
    if (source == null || !mounted) return;

    final file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 75,
      maxHeight: 1200,
      maxWidth: 1200,
    );
    if (file == null || !mounted) return;

    setState(() {
      _selectedPhoto = file;
    });
  }

  Future<ImageSource?> _pickSource() {
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

  String _extensionFromFileName(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toLowerCase();
    }
    return 'jpg';
  }
}
