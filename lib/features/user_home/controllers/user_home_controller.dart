import 'package:flutter/foundation.dart';

import '../../../core/services/service_locator.dart';
import '../data/announcement_model.dart';
import '../data/instrument_category_model.dart';
import '../data/musician_card_model.dart';
import '../data/user_home_repository.dart';

class UserHomeController extends ChangeNotifier {
  UserHomeController({UserHomeRepository? repository}) : _repository = repository ?? getIt<UserHomeRepository>();

  final UserHomeRepository _repository;

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
    notifyListeners();
  }

  void selectCity(String value) {
    _city = value;
    notifyListeners();
  }

  void selectInstrument(String value) {
    _instrument = value;
    notifyListeners();
  }

  void selectStyle(String value) {
    _style = value;
    notifyListeners();
  }

  void selectProfileType(String value) {
    _profileType = value;
    notifyListeners();
  }

  void selectGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
