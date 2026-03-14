import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:upsessions/core/utils/age_gate_utils.dart';

class MusicianOnboardingFormController extends ChangeNotifier {
  final basicInfoKey = GlobalKey<FormState>();
  final experienceKey = GlobalKey<FormState>();
  final extrasKey = GlobalKey<FormState>();
  final influencesKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final instrumentController = TextEditingController();
  final legalGuardianEmailController = TextEditingController();
  final cityController = TextEditingController();
  final stylesController = TextEditingController();
  final yearsController = TextEditingController(text: '0');
  final bioController = TextEditingController();

  final _imagePicker = ImagePicker();

  DateTime? _birthDate;
  bool _legalGuardianConsent = false;
  XFile? _selectedPhoto;
  bool _isUploadingPhoto = false;

  DateTime? get birthDate => _birthDate;
  bool get legalGuardianConsent => _legalGuardianConsent;
  XFile? get selectedPhoto => _selectedPhoto;
  bool get isUploadingPhoto => _isUploadingPhoto;

  bool get isMinor => isMusicianMinor(_birthDate);

  String get birthDateLabel {
    final date = _birthDate;
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  List<String> get parsedStyles => stylesController.text
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  int get parsedExperienceYears => int.tryParse(yearsController.text) ?? 0;

  String? get bioOrNull {
    final value = bioController.text.trim();
    return value.isEmpty ? null : value;
  }

  String? get selectedPhotoName {
    final photo = _selectedPhoto;
    if (photo == null) return null;
    final value = photo.name.trim();
    return value.isEmpty ? null : value;
  }

  void setBirthDate(DateTime? value) {
    _birthDate = value;
    if (!isMusicianMinor(value)) {
      legalGuardianEmailController.clear();
      _legalGuardianConsent = false;
    }
    notifyListeners();
  }

  void setLegalGuardianConsent(bool value) {
    _legalGuardianConsent = value;
    notifyListeners();
  }

  void clearSelectedPhoto() {
    _selectedPhoto = null;
    notifyListeners();
  }

  void setUploadingPhoto(bool value) {
    _isUploadingPhoto = value;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    if (_isUploadingPhoto) return;
    final file = await _imagePicker.pickImage(
      source: source,
      imageQuality: 75,
      maxHeight: 1200,
      maxWidth: 1200,
    );
    if (file == null) return;
    _selectedPhoto = file;
    notifyListeners();
  }

  bool validateStep(int step) {
    switch (step) {
      case 0:
        return basicInfoKey.currentState?.validate() ?? false;
      case 1:
        return experienceKey.currentState?.validate() ?? false;
      case 2:
        return true;
      case 3:
        return extrasKey.currentState?.validate() ?? true;
      default:
        return true;
    }
  }

  String extensionFromFileName(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toLowerCase();
    }
    return 'jpg';
  }

  @override
  void dispose() {
    nameController.dispose();
    instrumentController.dispose();
    legalGuardianEmailController.dispose();
    cityController.dispose();
    stylesController.dispose();
    yearsController.dispose();
    bioController.dispose();
    super.dispose();
  }
}
