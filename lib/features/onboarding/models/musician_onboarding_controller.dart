import 'package:flutter/widgets.dart';

import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';

class MusicianOnboardingController extends ChangeNotifier {
  final basicInfoKey = GlobalKey<FormState>();
  final experienceKey = GlobalKey<FormState>();
  final extrasKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final instrumentController = TextEditingController();
  final cityController = TextEditingController();
  final stylesController = TextEditingController();
  final yearsController = TextEditingController(text: '0');
  final photoUrlController = TextEditingController();
  final bioController = TextEditingController();

  bool _isDisposed = false;
  int _currentStep = 0;
  bool _isSaving = false;

  int get currentStep => _currentStep;
  bool get isSaving => _isSaving;

  void previousStep() {
    if (_currentStep <= 0) {
      return;
    }
    _currentStep -= 1;
    _safeNotify();
  }

  void nextStep() {
    _currentStep += 1;
    _safeNotify();
  }

  bool validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return basicInfoKey.currentState?.validate() ?? false;
      case 1:
        return experienceKey.currentState?.validate() ?? false;
      case 2:
        return extrasKey.currentState?.validate() ?? true;
      default:
        return true;
    }
  }

  List<String> get parsedStyles => stylesController.text
      .split(',')
      .map((style) => style.trim())
      .where((style) => style.isNotEmpty)
      .toList();

  int get parsedExperienceYears => int.tryParse(yearsController.text) ?? 0;

  String? get photoUrlOrNull {
    final value = photoUrlController.text.trim();
    return value.isEmpty ? null : value;
  }

  String? get bioOrNull {
    final value = bioController.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> submit({
    required MusiciansRepository repository,
    required String musicianId,
  }) async {
    if (!(extrasKey.currentState?.validate() ?? true)) {
      return;
    }

    _setSaving(true);
    try {
      await repository.saveProfile(
        musicianId: musicianId,
        name: nameController.text.trim(),
        instrument: instrumentController.text.trim(),
        city: cityController.text.trim(),
        styles: parsedStyles,
        experienceYears: parsedExperienceYears,
        photoUrl: photoUrlOrNull,
        bio: bioOrNull,
      );
    } finally {
      _setSaving(false);
    }
  }

  void _setSaving(bool value) {
    if (_isDisposed) {
      return;
    }
    _isSaving = value;
    _safeNotify();
  }

  void _safeNotify() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    nameController.dispose();
    instrumentController.dispose();
    cityController.dispose();
    stylesController.dispose();
    yearsController.dispose();
    photoUrlController.dispose();
    bioController.dispose();
    super.dispose();
  }
}
