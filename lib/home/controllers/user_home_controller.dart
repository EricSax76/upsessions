import 'package:flutter/foundation.dart';

import 'package:upsessions/core/locator/locator.dart';
import '../data/models/announcement_model.dart';
import '../data/models/instrument_category_model.dart';
import '../data/models/musician_card_model.dart';
import '../data/models/home_event_model.dart';
import '../data/repositories/user_home_repository.dart';

class UserHomeController extends ChangeNotifier {
  UserHomeController({UserHomeRepository? repository})
    : _repository = repository ?? locate<UserHomeRepository>();

  final UserHomeRepository _repository;
  bool _isDisposed = false;

  bool _loading = false;
  String _province = '';
  String _city = '';
  String _instrument = '';
  String _style = '';
  String _profileType = '';
  String _gender = '';

  List<MusicianCardModel> _recommended = const [];
  List<MusicianCardModel> _newMusicians = const [];
  List<AnnouncementModel> _announcements = const [];
  List<InstrumentCategoryModel> _categories = const [];
  List<String> _provinces = const [];
  List<String> _cities = const [];
  List<HomeEventModel> _events = const [];

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
  List<String> get cities => _cities;
  List<HomeEventModel> get events => _events;

  Future<void> loadHome() async {
    _setLoading(true);
    _recommended = await _repository.fetchRecommendedMusicians();
    _newMusicians = await _repository.fetchNewMusicians();
    _announcements = await _repository.fetchRecentAnnouncements();
    _categories = await _repository.fetchInstrumentCategories();
    _events = await _repository.fetchUpcomingEvents();
    _provinces = await _repository.fetchProvinces();
    if (_provinces.isNotEmpty) {
      _province = _provinces.first;
    }
    await _loadCitiesForProvince(_province);
    _setLoading(false);
  }

  void selectProvince(String value) {
    _province = value;
    _loadCitiesForProvince(value);
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

  Future<void> _loadCitiesForProvince(String value) async {
    final cities = await _repository.fetchCitiesForProvince(value);
    _cities = cities;
    if (_cities.isNotEmpty) {
      _city = _cities.first;
    }
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
