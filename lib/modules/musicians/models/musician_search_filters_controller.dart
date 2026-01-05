import 'package:flutter/foundation.dart';

import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/home/repositories/user_home_repository.dart';

class MusicianSearchFiltersController extends ChangeNotifier {
  MusicianSearchFiltersController({UserHomeRepository? repository})
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

  List<String> _provinces = const [];
  List<String> _cities = const [];

  bool get isLoading => _loading;
  String get province => _province;
  String get city => _city;
  String get instrument => _instrument;
  String get style => _style;
  String get profileType => _profileType;
  String get gender => _gender;
  List<String> get provinces => _provinces;
  List<String> get cities => _cities;

  Future<void> load() async {
    _setLoading(true);
    _provinces = await _repository.fetchProvinces();
    if (_provinces.isEmpty) {
      _province = '';
      _cities = const [];
      _city = '';
    }
    _setLoading(false);
  }

  void selectProvince(String value) {
    _province = value;
    _city = '';
    _cities = const [];
    _safeNotify();
    _loadCitiesForProvince(value);
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

  void resetFilters() {
    _instrument = '';
    _style = '';
    _profileType = '';
    _gender = '';
    _province = '';
    _city = '';
    _cities = const [];
    _safeNotify();
  }

  Future<void> _loadCitiesForProvince(String value) async {
    if (value.trim().isEmpty) {
      _cities = const [];
      _city = '';
      _safeNotify();
      return;
    }
    final cities = await _repository.fetchCitiesForProvince(value);
    _cities = cities;
    _city = _cities.isNotEmpty ? _cities.first : '';
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
