import 'package:flutter/foundation.dart';

import 'package:upsessions/locator.dart';
import '../data/announcement_model.dart';
import '../data/instrument_category_model.dart';
import '../data/musician_card_model.dart';
import '../data/user_home_repository.dart';

class UserHomeController extends ChangeNotifier {
  UserHomeController({UserHomeRepository? repository})
    : _repository = repository ?? locate<UserHomeRepository>();

  final UserHomeRepository _repository;
  bool _isDisposed = false;

  bool _loading = false;
  String _province = 'CDMX';
  String _city = 'Ciudad de México';
  String _instrument = 'Voz';
  String _style = 'Soul';
  String _profileType = 'Solista';
  String _gender = 'Cualquiera';

  List<MusicianCardModel> _recommended = const [];
  List<MusicianCardModel> _newMusicians = const [];
  List<AnnouncementModel> _announcements = const [];
  List<InstrumentCategoryModel> _categories = const [];
  List<String> _provinces = const [];

  bool get isLoading => _loading;
  String get province => _province;
  String get city => _city;
  String get instrument => _instrument;
  String get style => _style;
  String get profileType => _profileType;
  String get gender => _gender;
  List<MusicianCardModel> get recommended => _recommended;
  List<MusicianCardModel> get newMusicians => _newMusicians;
  List<AnnouncementModel> get announcements => _announcements;
  List<InstrumentCategoryModel> get categories => _categories;
  List<String> get provinces => _provinces;

  Future<void> loadHome() async {
    _setLoading(true);
    _recommended = await _repository.fetchRecommendedMusicians();
    _newMusicians = await _repository.fetchNewMusicians();
    _announcements = await _repository.fetchRecentAnnouncements();
    _categories = await _repository.fetchInstrumentCategories();
    _provinces = await _repository.fetchProvinces();
    _setLoading(false);
  }

  void selectProvince(String value) {
    _province = value;
    _safeNotify();
  }

  void selectCity(String value) {
    _city = value;
    _safeNotify();
  }

  void selectInstrument(String value) {
    _instrument = value;
    _safeNotify();
  }

  void selectStyle(String value) {
    _style = value;
    _safeNotify();
  }

  void selectProfileType(String value) {
    _profileType = value;
    _safeNotify();
  }

  void selectGender(String value) {
    _gender = value;
    _safeNotify();
  }

  void _setLoading(bool value) {
    if (_isDisposed) {
      return;
    }
    _loading = value;
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
    super.dispose();
  }
}
